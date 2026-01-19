import Metal
import MetalKit

public class SparklesOverlay: Overlay {
    public var name: String { "sparkles" }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "density", type: .float, defaultValue: 3.0),
            ShaderParameter(name: "size", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "speed", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "color", type: .float3, defaultValue: [1.0, 1.0, 1.0]),
            ShaderParameter(name: "colorize", type: .bool, defaultValue: true),
            ShaderParameter(name: "twinkleSpeed", type: .float, defaultValue: 0.5),
            ShaderParameter(name: "brightnessMultiplier", type: .float, defaultValue: 2.5),
        ]
    }

    public var needsAnimation: Bool { true }

    private var time: Float = 0.0

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "Sparkles",
            subdirectory: "Overlays",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "sparklesFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: true
        )
    }

    public func update(deltaTime: TimeInterval) {
        time += Float(deltaTime)
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext) {
        struct SparklesParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var density: Float
            var size: Float
            var speed: Float
            var colorize: Float
            var twinkleSpeed: Float
            var brightnessMultiplier: Float
            var color: SIMD3<Float>
        }

        let color = extractFloat3(
            from: context.parameters,
            arrayName: "color",
            rName: "colorR",
            gName: "colorG",
            bName: "colorB",
            defaultValue: SIMD3<Float>(1.0, 1.0, 1.0)
        )

        var params = SparklesParameters(
            time: time,
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            density: (context.parameters["density"] as? Float) ?? 3.0,
            size: (context.parameters["size"] as? Float) ?? 1.0,
            speed: (context.parameters["speed"] as? Float) ?? 1.0,
            colorize: ((context.parameters["colorize"] as? Bool) ?? true) ? 1.0 : 0.0,
            twinkleSpeed: (context.parameters["twinkleSpeed"] as? Float) ?? 0.5,
            brightnessMultiplier: (context.parameters["brightnessMultiplier"] as? Float) ?? 2.5,
            color: color
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<SparklesParameters>.stride, index: 0)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}
