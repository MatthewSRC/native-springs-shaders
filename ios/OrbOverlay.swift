import Foundation
import Metal

public class OrbOverlay: Overlay {
    public var name: String { "orb" }

    private enum Look: Int, CaseIterable {
        case radius, breathAmount, breathPeriod, thickness, dispersion
        case spread, turbulence, chromatic, shimmer, symmetry
        case core, brightness, saturation, motion, speaking
    }

    /// Look targets resolved in src/utils/orbLook.ts, with idle defaults.
    private static let spec = ConversationalLookSpec(
        keys: [
            "radius", "breathAmount", "breathPeriod", "thickness", "dispersion",
            "spread", "turbulence", "chromatic", "shimmer", "symmetry",
            "core", "brightness", "saturation", "motion", "speaking",
        ],
        defaults: [
            0.23, 0.012, 5.0, 1.0, 1.0,
            14.0, 0.15, 1.0, 0.0, 0.0,
            0.0, 1.0, 1.0, 0.6, 0.0,
        ],
        defaultColor: SIMD3<Float>(1.0, 0.8, 0.4),
        defaultSecondaryColor: SIMD3<Float>(0.75, 0.8, 0.4),
        motionIndex: Look.motion.rawValue,
        breathPeriodIndex: Look.breathPeriod.rawValue,
        speakingIndex: Look.speaking.rawValue,
        // Arrive by zooming in and fading up from darkness
        arrival: [Look.radius.rawValue: 0.83, Look.brightness.rawValue: 0.0]
    )

    public var parameters: [ShaderParameter] { Self.spec.shaderParameters }

    public var needsAnimation: Bool { true }

    // Soft glow holds up well below native resolution
    public var renderScale: CGFloat { 0.75 }

    private let animators = ConversationalAnimators(spec: OrbOverlay.spec)

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        let library = try MetalLibraryLoader.loadLibrary(
            resourceName: "Orb",
            subdirectory: "Overlays",
            bundle: Bundle(for: type(of: self)),
            device: device
        )

        guard let vertexFunction = library.makeFunction(name: "fullscreenVertex") else {
            throw ShaderError.compilationFailed("fullscreenVertex not found")
        }
        guard let fragmentFunction = library.makeFunction(name: "orbFragment") else {
            throw ShaderError.compilationFailed("orbFragment not found")
        }

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        return try device.makeRenderPipelineState(descriptor: descriptor)
    }

    // Time is tracked per view in encode()
    public func update(deltaTime: TimeInterval) {}

    public func releaseView(viewId: Int) {
        animators.release(viewId: viewId)
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext) {
        struct OrbParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var color: SIMD3<Float>
            var secondaryColor: SIMD3<Float>
            var scale: Float
            var radius: Float
            var thickness: Float
            var dispersion: Float
            var spread: Float
            var turbulence: Float
            var chromatic: Float
            var shimmer: Float
            var symmetry: Float
            var core: Float
            var brightness: Float
            var saturation: Float
            var rippleProgress: Float
            var rippleStrength: Float
        }

        let f = animators.advance(viewId: context.viewId, parameters: context.parameters)
        func l(_ key: Look) -> Float { f.look[key.rawValue] }

        var params = OrbParameters(
            time: f.time,
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            color: f.color,
            secondaryColor: f.secondaryColor,
            scale: (context.parameters["scale"] as? Float) ?? 1.0,
            radius: l(.radius) + l(.breathAmount) * f.breath + 0.012 * f.speak
                + 0.008 * f.flash + 0.025 * f.exhale + 0.02 * f.nudge,
            thickness: max(l(.thickness) + 0.25 * f.flash - 0.15 * f.exhale, 0.1),
            dispersion: l(.dispersion) + 0.3 * f.speak,
            spread: l(.spread) - 6.0 * f.exhale,
            turbulence: l(.turbulence),
            chromatic: l(.chromatic),
            shimmer: l(.shimmer),
            symmetry: l(.symmetry),
            core: l(.core),
            brightness: max(l(.brightness) * (1 + 4 * l(.breathAmount) * f.breath)
                + 0.35 * f.speak + 0.55 * f.flash + 0.45 * f.exhale, 0),
            saturation: l(.saturation),
            rippleProgress: f.rippleProgress,
            rippleStrength: f.rippleActive ? 1 : 0
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<OrbParameters>.stride, index: 0)
    }
}
