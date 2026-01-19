import Foundation
import Metal

public class FireSparksOverlay: Overlay {
    public var name: String { "fireSparks" }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "direction", type: .float2, defaultValue: [0.7, -1.0]),
            ShaderParameter(name: "travelDistance", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "color", type: .float3, defaultValue: [1.0, 0.4, 0.05]),
            ShaderParameter(name: "particleSize", type: .float, defaultValue: 0.009),
            ShaderParameter(name: "animationSpeed", type: .float, defaultValue: 1.5),
            ShaderParameter(name: "smokeIntensity", type: .float, defaultValue: 0.8),
            ShaderParameter(name: "particleBloom", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "movementSpeed", type: .float, defaultValue: 1.0)
        ]
    }

    public var needsAnimation: Bool { true }

    private var time: Float = 0.0

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "FireSparks",
            subdirectory: "Overlays",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "fireSparksFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: true
        )
    }

    public func update(deltaTime: TimeInterval) {
        time += Float(deltaTime)
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext) {
        struct FireSparksParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var movementDirection: SIMD2<Float>
            var travelDistance: Float
            var particleSize: Float
            var animationSpeed: Float
            var smokeIntensity: Float
            var particleBloom: Float
            var movementSpeed: Float
            var sparkColor: SIMD3<Float>
        }

        let movementDirection = extractFloat2(
            from: context.parameters,
            arrayName: "direction",
            xName: "directionX",
            yName: "directionY",
            defaultValue: SIMD2<Float>(0.7, -1.0)
        )

        let sparkColor = extractFloat3(
            from: context.parameters,
            arrayName: "color",
            rName: "colorR",
            gName: "colorG",
            bName: "colorB",
            defaultValue: SIMD3<Float>(1.0, 0.4, 0.05)
        )

        var params = FireSparksParameters(
            time: time,
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            movementDirection: movementDirection,
            travelDistance: (context.parameters["travelDistance"] as? Float) ?? 1.0,
            particleSize: (context.parameters["particleSize"] as? Float) ?? 0.009,
            animationSpeed: (context.parameters["animationSpeed"] as? Float) ?? 1.5,
            smokeIntensity: (context.parameters["smokeIntensity"] as? Float) ?? 0.8,
            particleBloom: (context.parameters["particleBloom"] as? Float) ?? 1.0,
            movementSpeed: (context.parameters["movementSpeed"] as? Float) ?? 1.0,
            sparkColor: sparkColor
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<FireSparksParameters>.stride, index: 0)
    }
}
