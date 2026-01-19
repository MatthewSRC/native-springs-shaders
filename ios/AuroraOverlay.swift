import Foundation
import Metal

public class AuroraOverlay: Overlay {
    public var name: String { "aurora" }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "direction", type: .float2, defaultValue: [0.0, 1.0]),
            ShaderParameter(name: "color", type: .float3, defaultValue: [0.6, 0.8, 1.0]),
            ShaderParameter(name: "borderFade", type: .float, defaultValue: 0.0)
        ]
    }

    public var needsAnimation: Bool { true }

    private var time: Float = 0.0

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "Aurora",
            subdirectory: "Overlays",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "auroraFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: true
        )
    }

    public func update(deltaTime: Double) {
        time += Float(deltaTime)
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext) {
        struct AuroraParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var movementDirection: SIMD2<Float>
            var borderFade: Float
            var colorTint: SIMD3<Float>
        }

        let movementDirection = extractFloat2(
            from: context.parameters,
            arrayName: "direction",
            xName: "directionX",
            yName: "directionY",
            defaultValue: SIMD2<Float>(0.0, 1.0)
        )

        let colorTint = extractFloat3(
            from: context.parameters,
            arrayName: "color",
            rName: "colorR",
            gName: "colorG",
            bName: "colorB",
            defaultValue: SIMD3<Float>(0.6, 0.8, 1.0)
        )

        var params = AuroraParameters(
            time: time,
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            movementDirection: movementDirection,
            borderFade: (context.parameters["borderFade"] as? Float) ?? 1.0,
            colorTint: colorTint
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<AuroraParameters>.stride, index: 0)
    }
}
