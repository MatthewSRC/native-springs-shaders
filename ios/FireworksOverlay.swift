import Foundation
import Metal

public class FireworksOverlay: Overlay {
    public var name: String { "fireworks" }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "speed", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "minSize", type: .float, defaultValue: 0.2),
            ShaderParameter(name: "maxSize", type: .float, defaultValue: 0.6),
            ShaderParameter(name: "minDuration", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "maxDuration", type: .float, defaultValue: 2.5),
            ShaderParameter(name: "frequency", type: .float, defaultValue: 1.5),
            ShaderParameter(name: "color", type: .float3, defaultValue: [1.0, 0.5, 0.0]),
            ShaderParameter(name: "useCustomColor", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "sharpness", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "particleCount", type: .float, defaultValue: 50.0),
            ShaderParameter(name: "gravity", type: .float, defaultValue: 0.4)
        ]
    }

    public var needsAnimation: Bool { true }

    private var time: Float = 0.0

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "Fireworks",
            subdirectory: "Overlays",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "fireworksFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: true
        )
    }

    public func update(deltaTime: TimeInterval) {
        time += Float(deltaTime)
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext) {
        struct FireworksParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var speed: Float
            var minSize: Float
            var maxSize: Float
            var minDuration: Float
            var maxDuration: Float
            var frequency: Float
            var useCustomColor: Float
            var sharpness: Float
            var particleCount: Float
            var gravity: Float
            var customColor: SIMD3<Float>
        }

        let customColor = extractFloat3(
            from: context.parameters,
            arrayName: "color",
            rName: "colorR",
            gName: "colorG",
            bName: "colorB",
            defaultValue: SIMD3<Float>(1.0, 0.5, 0.0)
        )

        let useCustomColor = boolToFloat(from: context.parameters, key: "useCustomColor", defaultValue: false)

        var params = FireworksParameters(
            time: time,
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            speed: (context.parameters["speed"] as? Float) ?? 1.0,
            minSize: (context.parameters["minSize"] as? Float) ?? 0.2,
            maxSize: (context.parameters["maxSize"] as? Float) ?? 0.6,
            minDuration: (context.parameters["minDuration"] as? Float) ?? 1.0,
            maxDuration: (context.parameters["maxDuration"] as? Float) ?? 2.5,
            frequency: (context.parameters["frequency"] as? Float) ?? 1.5,
            useCustomColor: useCustomColor,
            sharpness: (context.parameters["sharpness"] as? Float) ?? 1.0,
            particleCount: (context.parameters["particleCount"] as? Float) ?? 50.0,
            gravity: (context.parameters["gravity"] as? Float) ?? 0.4,
            customColor: customColor
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<FireworksParameters>.stride, index: 0)
    }
}
