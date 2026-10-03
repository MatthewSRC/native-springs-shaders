import Foundation
import Metal

public class BlobOverlay: Overlay {
    public var name: String { "blob" }

    private enum Look: Int, CaseIterable {
        case radius, breathAmount, breathPeriod, thickness, twist
        case iridescence, shimmer, symmetry, core, brightness
        case saturation, motion, speaking
    }

    /// Look targets resolved in src/utils/blobLook.ts, with idle defaults.
    private static let spec = ConversationalLookSpec(
        keys: [
            "radius", "breathAmount", "breathPeriod", "thickness", "twist",
            "iridescence", "shimmer", "symmetry", "core", "brightness",
            "saturation", "motion", "speaking",
        ],
        defaults: [
            1.5, 0.06, 5.0, 1.0, 2.0,
            0.15, 0.0, 0.0, 0.0, 1.0,
            1.0, 0.6, 0.0,
        ],
        defaultColor: SIMD3<Float>(0.4, 0.6, 1.0),
        defaultSecondaryColor: SIMD3<Float>(0.9, 0.4, 0.8),
        motionIndex: Look.motion.rawValue,
        breathPeriodIndex: Look.breathPeriod.rawValue,
        speakingIndex: Look.speaking.rawValue,
        // Arrive by growing out of a small, dark seed
        arrival: [Look.radius.rawValue: 0.6, Look.brightness.rawValue: 0.0]
    )

    public var parameters: [ShaderParameter] { Self.spec.shaderParameters }

    public var needsAnimation: Bool { true }

    // Raymarching every native pixel is expensive and the glow stays soft at lower resolution
    public var renderScale: CGFloat { 0.5 }

    private let animators = ConversationalAnimators(spec: BlobOverlay.spec)

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        let library = try MetalLibraryLoader.loadLibrary(
            resourceName: "Blob",
            subdirectory: "Overlays",
            bundle: Bundle(for: type(of: self)),
            device: device
        )

        guard let vertexFunction = library.makeFunction(name: "fullscreenVertex") else {
            throw ShaderError.compilationFailed("fullscreenVertex not found")
        }
        guard let fragmentFunction = library.makeFunction(name: "blobFragment") else {
            throw ShaderError.compilationFailed("blobFragment not found")
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
        struct BlobParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var color: SIMD3<Float>
            var secondaryColor: SIMD3<Float>
            var scale: Float
            var radius: Float
            var thickness: Float
            var twist: Float
            var iridescence: Float
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

        var params = BlobParameters(
            time: f.time,
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            color: f.color,
            secondaryColor: f.secondaryColor,
            scale: (context.parameters["scale"] as? Float) ?? 1.0,
            radius: max(l(.radius) + l(.breathAmount) * f.breath + 0.06 * f.speak
                + 0.04 * f.flash + 0.1 * f.exhale + 0.08 * f.nudge, 0.1),
            thickness: max(l(.thickness) + 0.35 * f.flash + 0.2 * f.exhale, 0.05),
            twist: max(l(.twist) + 0.4 * f.speak + 0.5 * f.exhale, 0),
            iridescence: l(.iridescence),
            shimmer: l(.shimmer),
            symmetry: l(.symmetry),
            core: l(.core),
            brightness: max(l(.brightness) * (1 + 1.2 * l(.breathAmount) * f.breath)
                + 0.3 * f.speak + 0.5 * f.flash + 0.4 * f.exhale, 0),
            saturation: l(.saturation),
            rippleProgress: f.rippleProgress,
            rippleStrength: f.rippleActive ? 1 : 0
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<BlobParameters>.stride, index: 0)
    }
}
