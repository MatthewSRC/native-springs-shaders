import Foundation
import Metal

public class CloudsOverlay: Overlay {
    public var name: String { "clouds" }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 0.6),
            ShaderParameter(name: "color", type: .float3, defaultValue: [0.15, 0.2, 0.55]),
            ShaderParameter(name: "secondaryColor", type: .float3, defaultValue: [0.25, 0.15, 0.5]),
            ShaderParameter(name: "tertiaryColor", type: .float3, defaultValue: [0.1, 0.3, 0.5]),
            ShaderParameter(name: "scale", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "speed", type: .float, defaultValue: 0.3),
            ShaderParameter(name: "softness", type: .float, defaultValue: 0.6),
            ShaderParameter(name: "blobCount", type: .float, defaultValue: 3.0),
        ]
    }

    public var needsAnimation: Bool { true }

    private var time: Float = 0.0

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "Clouds",
            subdirectory: "Overlays",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "cloudsFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: true
        )
    }

    public func update(deltaTime: TimeInterval) {
        time += Float(deltaTime)
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext) {
        struct CloudsParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var color: SIMD3<Float>
            var secondaryColor: SIMD3<Float>
            var tertiaryColor: SIMD3<Float>
            var scale: Float
            var speed: Float
            var softness: Float
            var blobCount: Float
        }

        let color = extractFloat3(
            from: context.parameters,
            arrayName: "color",
            rName: "colorR",
            gName: "colorG",
            bName: "colorB",
            defaultValue: SIMD3<Float>(0.15, 0.2, 0.55)
        )

        let secondaryColor = extractFloat3(
            from: context.parameters,
            arrayName: "secondaryColor",
            rName: "secondaryColorR",
            gName: "secondaryColorG",
            bName: "secondaryColorB",
            defaultValue: SIMD3<Float>(0.25, 0.15, 0.5)
        )

        let tertiaryColor = extractFloat3(
            from: context.parameters,
            arrayName: "tertiaryColor",
            rName: "tertiaryColorR",
            gName: "tertiaryColorG",
            bName: "tertiaryColorB",
            defaultValue: SIMD3<Float>(0.1, 0.3, 0.5)
        )

        var params = CloudsParameters(
            time: time,
            intensity: (context.parameters["intensity"] as? Float) ?? 0.6,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            color: color,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor,
            scale: (context.parameters["scale"] as? Float) ?? 1.0,
            speed: (context.parameters["speed"] as? Float) ?? 0.3,
            softness: (context.parameters["softness"] as? Float) ?? 0.6,
            blobCount: (context.parameters["blobCount"] as? Float) ?? 3.0
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<CloudsParameters>.stride, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}
