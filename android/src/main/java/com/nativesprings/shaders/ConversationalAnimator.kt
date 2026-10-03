package com.nativesprings.shaders

import java.util.concurrent.ConcurrentHashMap
import kotlin.math.PI
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sin

/** Critically damped spring: eases in and out, stable for any frame time. */
class Spring(var value: Float) {
    var velocity = 0f

    fun step(target: Float, smoothTime: Float, dt: Float): Float {
        val omega = 2f / max(smoothTime, 0.0001f)
        val x = omega * dt
        val decay = 1f / (1f + x + 0.48f * x * x + 0.235f * x * x * x)
        val change = value - target
        val temp = (velocity + omega * change) * dt
        velocity = (velocity - omega * temp) * decay
        value = target + (change + temp) * decay
        return value
    }
}

/**
 * The look values a conversational overlay animates between states.
 * Targets are resolved in JS (see src/utils/conversational.ts).
 */
class ConversationalLookSpec(
    val keys: Array<String>,
    val defaults: FloatArray,
    val defaultColor: FloatArray,
    val defaultSecondaryColor: FloatArray,
    val motionIndex: Int,
    val breathPeriodIndex: Int,
    val speakingIndex: Int,
    /** Look values at mount, sprung toward the targets as an arrival animation */
    val arrival: Map<Int, Float>
) {
    val shaderParameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("color", ShaderParameterType.FLOAT3, defaultColor.toList()),
        ShaderParameter("secondaryColor", ShaderParameterType.FLOAT3, defaultSecondaryColor.toList()),
        ShaderParameter("scale", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("speed", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("transitionTime", ShaderParameterType.FLOAT, 0.7f),
        ShaderParameter("colorTransitionTime", ShaderParameterType.FLOAT, 0.8f),
        ShaderParameter("speechLevel", ShaderParameterType.FLOAT, -1.0f),
        ShaderParameter("flashTrigger", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("exhaleTrigger", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("rippleTrigger", ShaderParameterType.FLOAT, 0.0f)
    ) + keys.zip(defaults.toList()).map { (key, value) ->
        ShaderParameter(key, ShaderParameterType.FLOAT, value)
    }
}

/** One frame of animated values for a view. */
class ConversationalFrame(
    val look: FloatArray,
    /** Primary color followed by secondary color, 6 channels */
    val colors: FloatArray,
    /** Animation clock, paced by `speed` and the look's motion */
    val time: Float,
    /** Breathing wave (-1 - 1) */
    val breath: Float,
    /** Speaking amount times the centered speech level */
    val speak: Float,
    /** Flash brighten-and-hold envelope (0 - 1) */
    val flash: Float,
    /** Exhale pulse envelope (0 - 1) */
    val exhale: Float,
    /** Ripple progress (0 - 1) */
    val rippleProgress: Float,
    val rippleActive: Boolean,
    /** Small outward push while the ripple starts (0 - 1) */
    val nudge: Float
)

/** Animation state per view, so several overlays can sit in different states. */
class ConversationalAnimators(private val spec: ConversationalLookSpec) {

    private class ViewState(look: FloatArray, colors: FloatArray, triggers: FloatArray) {
        var lastTimestamp = System.nanoTime()
        var clock = 0f
        var animTime = 0f
        var breathPhase = 0f
        val look = Array(look.size) { Spring(look[it]) }
        val colors = Array(colors.size) { Spring(colors[it]) }
        val speechLevel = Spring(0f)
        val lastTriggers = triggers.copyOf()
        val momentStarts = floatArrayOf(-100f, -100f, -100f)
    }

    // Each view renders on its own GL thread
    private val states = ConcurrentHashMap<Int, ViewState>()

    // Views have no deinit hook here, and detached screens (tabs) should keep their
    // state, so states that stop rendering for a while are dropped instead
    @Volatile private var lastSweep = System.nanoTime()

    fun release(viewId: Int) {
        states.remove(viewId)
    }

    fun advance(viewId: Int, p: Map<String, Any>): ConversationalFrame {
        fun value(key: String, fallback: Float): Float = (p[key] as? Number)?.toFloat() ?: fallback

        val targetLook = FloatArray(spec.keys.size) { value(spec.keys[it], spec.defaults[it]) }
        val colorTargets = p.extractFloat3("color", "colorR", "colorG", "colorB", spec.defaultColor) +
            p.extractFloat3(
                "secondaryColor", "secondaryColorR", "secondaryColorG", "secondaryColorB",
                spec.defaultSecondaryColor
            )
        val triggers = FloatArray(TRIGGER_KEYS.size) { value(TRIGGER_KEYS[it], 0f) }

        val state = states.getOrPut(viewId) {
            ViewState(targetLook, colorTargets, triggers).also { state ->
                spec.arrival.forEach { (index, start) -> state.look[index].value = start }
            }
        }

        val now = System.nanoTime()
        if (now - lastSweep > SWEEP_INTERVAL_NANOS) {
            lastSweep = now
            states.entries.removeIf { now - it.value.lastTimestamp > STALE_NANOS }
        }

        // Clamp so a paused or offscreen view resumes smoothly instead of jumping
        val dt = ((now - state.lastTimestamp) / 1_000_000_000.0).toFloat().coerceIn(0f, 0.1f)
        state.lastTimestamp = now
        state.clock += dt

        // Spring every look value and color channel toward its target
        val transitionTime = value("transitionTime", 0.7f)
        val look = FloatArray(targetLook.size) {
            state.look[it].step(targetLook[it], transitionTime, dt)
        }

        val colorTransitionTime = value("colorTransitionTime", 0.8f)
        val colors = FloatArray(colorTargets.size) {
            state.colors[it].step(colorTargets[it], colorTransitionTime, dt)
        }

        // Phases are integrated so pace changes never cause jumps
        state.animTime += dt * value("speed", 1.0f) * look[spec.motionIndex]
        state.breathPhase += dt * 2f * PI.toFloat() / max(look[spec.breathPeriodIndex], 0.5f)
        if (state.breathPhase > 2f * PI.toFloat()) {
            state.breathPhase -= 2f * PI.toFloat()
        }

        // Speaking pulse: app-provided level, or a soft speech-paced rhythm
        val speechTarget = value("speechLevel", -1f)
        val speechLevel = if (speechTarget >= 0f) {
            state.speechLevel.step(min(speechTarget, 1f), 0.08f, dt)
        } else {
            val c = state.clock
            val syllables = 0.5f + 0.5f * sin(c * 11.3f + 0.8f * sin(c * 3.1f))
            val phrase = 0.55f + 0.45f * sin(c * 1.7f + 1.1f)
            syllables * phrase
        }

        // One-shot moments restart when their trigger counter changes
        for (i in triggers.indices) {
            if (triggers[i] != state.lastTriggers[i]) {
                state.lastTriggers[i] = triggers[i]
                state.momentStarts[i] = state.clock
            }
        }

        // Flash: quick brighten, hold, gentle release
        val flashAge = state.clock - state.momentStarts[0]
        val flash = smoothstep(0f, 0.15f, flashAge) * (1f - smoothstep(0.95f, 1.75f, flashAge))

        // Exhale: slower pulse
        val exhaleAge = state.clock - state.momentStarts[1]
        val exhale = if (exhaleAge < 2.4f) sin(PI.toFloat() * exhaleAge / 2.4f).pow(2) else 0f

        // Ripple: single outward ripple with a small nudge
        val rippleAge = state.clock - state.momentStarts[2]
        val rippleActive = rippleAge < 1.8f

        return ConversationalFrame(
            look = look,
            colors = colors,
            time = state.animTime,
            breath = sin(state.breathPhase),
            speak = look[spec.speakingIndex] * (speechLevel - 0.35f),
            flash = flash,
            exhale = exhale,
            rippleProgress = min(rippleAge / 1.8f, 1f),
            rippleActive = rippleActive,
            nudge = if (rippleActive) sin(PI.toFloat() * min(rippleAge / 0.9f, 1f)) else 0f
        )
    }

    private fun smoothstep(edge0: Float, edge1: Float, x: Float): Float {
        val t = ((x - edge0) / (edge1 - edge0)).coerceIn(0f, 1f)
        return t * t * (3f - 2f * t)
    }

    companion object {
        private val TRIGGER_KEYS = arrayOf("flashTrigger", "exhaleTrigger", "rippleTrigger")
        private const val SWEEP_INTERVAL_NANOS = 10_000_000_000L
        private const val STALE_NANOS = 120_000_000_000L
    }
}
