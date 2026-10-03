import Foundation
import QuartzCore
import simd

/// Critically damped spring: eases in and out, stable for any frame time.
struct Spring {
    var value: Float
    var velocity: Float = 0

    init(_ value: Float) {
        self.value = value
    }

    mutating func step(to target: Float, smoothTime: Float, dt: Float) -> Float {
        let omega = 2.0 / max(smoothTime, 0.0001)
        let x = omega * dt
        let decay = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
        let change = value - target
        let temp = (velocity + omega * change) * dt
        velocity = (velocity - omega * temp) * decay
        value = target + (change + temp) * decay
        return value
    }
}

/// The look values a conversational overlay animates between states.
/// Targets are resolved in JS (see src/utils/conversational.ts).
struct ConversationalLookSpec {
    let keys: [String]
    let defaults: [Float]
    let defaultColor: SIMD3<Float>
    let defaultSecondaryColor: SIMD3<Float>
    let motionIndex: Int
    let breathPeriodIndex: Int
    let speakingIndex: Int
    /// Look values at mount, sprung toward the targets as an arrival animation
    let arrival: [Int: Float]

    var shaderParameters: [ShaderParameter] {
        var params = [
            ShaderParameter(name: "intensity", type: .float, defaultValue: Float(1.0)),
            ShaderParameter(name: "color", type: .float3, defaultValue: [defaultColor.x, defaultColor.y, defaultColor.z]),
            ShaderParameter(name: "secondaryColor", type: .float3, defaultValue: [defaultSecondaryColor.x, defaultSecondaryColor.y, defaultSecondaryColor.z]),
            ShaderParameter(name: "scale", type: .float, defaultValue: Float(1.0)),
            ShaderParameter(name: "speed", type: .float, defaultValue: Float(1.0)),
            ShaderParameter(name: "transitionTime", type: .float, defaultValue: Float(0.7)),
            ShaderParameter(name: "colorTransitionTime", type: .float, defaultValue: Float(0.8)),
            ShaderParameter(name: "speechLevel", type: .float, defaultValue: Float(-1.0)),
            ShaderParameter(name: "flashTrigger", type: .float, defaultValue: Float(0.0)),
            ShaderParameter(name: "exhaleTrigger", type: .float, defaultValue: Float(0.0)),
            ShaderParameter(name: "rippleTrigger", type: .float, defaultValue: Float(0.0)),
        ]
        for (key, value) in zip(keys, defaults) {
            params.append(ShaderParameter(name: key, type: .float, defaultValue: value))
        }
        return params
    }
}

/// One frame of animated values for a view.
struct ConversationalFrame {
    let look: [Float]
    let color: SIMD3<Float>
    let secondaryColor: SIMD3<Float>
    /// Animation clock, paced by `speed` and the look's motion
    let time: Float
    /// Breathing wave (-1 - 1)
    let breath: Float
    /// Speaking amount times the centered speech level
    let speak: Float
    /// Flash brighten-and-hold envelope (0 - 1)
    let flash: Float
    /// Exhale pulse envelope (0 - 1)
    let exhale: Float
    /// Ripple progress (0 - 1)
    let rippleProgress: Float
    let rippleActive: Bool
    /// Small outward push while the ripple starts (0 - 1)
    let nudge: Float
}

/// Animation state per view, so several overlays can sit in different states.
final class ConversationalAnimators {
    private final class ViewState {
        var lastTimestamp: CFTimeInterval
        var clock: Float = 0
        var animTime: Float = 0
        var breathPhase: Float = 0
        var look: [Spring]
        var colors: [Spring]
        var speechLevel = Spring(0)

        var lastTriggers: [Float]
        var momentStarts: [Float] = [-100, -100, -100]

        init(look: [Float], colors: [Float], triggers: [Float], now: CFTimeInterval) {
            lastTimestamp = now
            self.look = look.map { Spring($0) }
            self.colors = colors.map { Spring($0) }
            lastTriggers = triggers
        }
    }

    private static let triggerKeys = ["flashTrigger", "exhaleTrigger", "rippleTrigger"]

    private let spec: ConversationalLookSpec
    private var states: [Int: ViewState] = [:]

    init(spec: ConversationalLookSpec) {
        self.spec = spec
    }

    func release(viewId: Int) {
        states.removeValue(forKey: viewId)
    }

    func advance(viewId: Int, parameters p: [String: Any], now: CFTimeInterval = CACurrentMediaTime()) -> ConversationalFrame {
        func value(_ key: String, _ fallback: Float) -> Float {
            (p[key] as? Float) ?? fallback
        }

        let targetLook = zip(spec.keys, spec.defaults).map { value($0, $1) }
        let targetColor = extractFloat3(
            from: p,
            arrayName: "color",
            rName: "colorR",
            gName: "colorG",
            bName: "colorB",
            defaultValue: spec.defaultColor
        )
        let targetSecondaryColor = extractFloat3(
            from: p,
            arrayName: "secondaryColor",
            rName: "secondaryColorR",
            gName: "secondaryColorG",
            bName: "secondaryColorB",
            defaultValue: spec.defaultSecondaryColor
        )
        let colorTargets = [
            targetColor.x, targetColor.y, targetColor.z,
            targetSecondaryColor.x, targetSecondaryColor.y, targetSecondaryColor.z,
        ]
        let triggers = Self.triggerKeys.map { value($0, 0) }

        let state: ViewState
        if let existing = states[viewId] {
            state = existing
        } else {
            state = ViewState(look: targetLook, colors: colorTargets, triggers: triggers, now: now)
            for (index, start) in spec.arrival {
                state.look[index].value = start
            }
            states[viewId] = state
        }

        // Clamp so a paused or offscreen view resumes smoothly instead of jumping
        let dt = Float(min(max(now - state.lastTimestamp, 0), 0.1))
        state.lastTimestamp = now
        state.clock += dt

        // Spring every look value and color channel toward its target
        let transitionTime = value("transitionTime", 0.7)
        var look = [Float](repeating: 0, count: targetLook.count)
        for i in targetLook.indices {
            look[i] = state.look[i].step(to: targetLook[i], smoothTime: transitionTime, dt: dt)
        }

        let colorTransitionTime = value("colorTransitionTime", 0.8)
        var colors = [Float](repeating: 0, count: 6)
        for i in 0..<6 {
            colors[i] = state.colors[i].step(to: colorTargets[i], smoothTime: colorTransitionTime, dt: dt)
        }

        // Phases are integrated so pace changes never cause jumps
        state.animTime += dt * value("speed", 1.0) * look[spec.motionIndex]
        state.breathPhase += dt * 2.0 * Float.pi / max(look[spec.breathPeriodIndex], 0.5)
        if state.breathPhase > 2.0 * Float.pi {
            state.breathPhase -= 2.0 * Float.pi
        }

        // Speaking pulse: app-provided level, or a soft speech-paced rhythm
        let speechTarget = value("speechLevel", -1)
        let speechLevel: Float
        if speechTarget >= 0 {
            speechLevel = state.speechLevel.step(to: min(speechTarget, 1), smoothTime: 0.08, dt: dt)
        } else {
            let c = state.clock
            let syllables = 0.5 + 0.5 * sin(c * 11.3 + 0.8 * sin(c * 3.1))
            let phrase = 0.55 + 0.45 * sin(c * 1.7 + 1.1)
            speechLevel = syllables * phrase
        }

        // One-shot moments restart when their trigger counter changes
        for i in triggers.indices where triggers[i] != state.lastTriggers[i] {
            state.lastTriggers[i] = triggers[i]
            state.momentStarts[i] = state.clock
        }

        // Flash: quick brighten, hold, gentle release
        let flashAge = state.clock - state.momentStarts[0]
        let flash = smoothstep(0, 0.15, flashAge) * (1 - smoothstep(0.95, 1.75, flashAge))

        // Exhale: slower pulse
        let exhaleAge = state.clock - state.momentStarts[1]
        let exhale: Float = exhaleAge < 2.4 ? pow(sin(Float.pi * exhaleAge / 2.4), 2) : 0

        // Ripple: single outward ripple with a small nudge
        let rippleAge = state.clock - state.momentStarts[2]
        let rippleActive = rippleAge < 1.8

        return ConversationalFrame(
            look: look,
            color: SIMD3<Float>(colors[0], colors[1], colors[2]),
            secondaryColor: SIMD3<Float>(colors[3], colors[4], colors[5]),
            time: state.animTime,
            breath: sin(state.breathPhase),
            speak: look[spec.speakingIndex] * (speechLevel - 0.35),
            flash: flash,
            exhale: exhale,
            rippleProgress: min(rippleAge / 1.8, 1),
            rippleActive: rippleActive,
            nudge: rippleActive ? sin(Float.pi * min(rippleAge / 0.9, 1)) : 0
        )
    }

    private func smoothstep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
        let t = min(max((x - edge0) / (edge1 - edge0), 0), 1)
        return t * t * (3 - 2 * t)
    }
}
