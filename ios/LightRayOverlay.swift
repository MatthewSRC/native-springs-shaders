import Foundation
import Metal

public class LightRayOverlay: Overlay {
    public var name: String { "lightRay" }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "rayPosition", type: .float2, defaultValue: [0.7, -0.4]),
            ShaderParameter(name: "color", type: .float3, defaultValue: [1.0, 0.95, 0.8]),
            ShaderParameter(name: "speed", type: .float, defaultValue: 1.5),
            ShaderParameter(name: "numRays", type: .float, defaultValue: 2.0),
            ShaderParameter(name: "depthAttenuation", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "rayLength", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "rayDirection", type: .float2, defaultValue: [1.0, -0.116]),
            ShaderParameter(name: "rayWidth", type: .float, defaultValue: 1.0)
        ]
    }

    public var needsAnimation: Bool { true }

    private var time: Float = 0.0

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "LightRay",
            subdirectory: "Overlays",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "lightRayFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: true
        )
    }

    public func update(deltaTime: Double) {
        time += Float(deltaTime)
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext) {
        struct LightRayParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var rayPosition: SIMD2<Float>
            var speed: Float
            var numRays: Float
            var depthAttenuation: Float
            var rayLength: Float
            var rayDirection: SIMD2<Float>
            var rayWidth: Float
            var rayColor: SIMD3<Float>
        }

        let rayPosition = extractFloat2(
            from: context.parameters,
            arrayName: "rayPosition",
            xName: "rayPositionX",
            yName: "rayPositionY",
            defaultValue: SIMD2<Float>(0.7, -0.4)
        )

        let rayColor = extractFloat3(
            from: context.parameters,
            arrayName: "color",
            rName: "colorR",
            gName: "colorG",
            bName: "colorB",
            defaultValue: SIMD3<Float>(1.0, 0.95, 0.8)
        )

        let rayDirection = extractFloat2(
            from: context.parameters,
            arrayName: "rayDirection",
            xName: "rayDirectionX",
            yName: "rayDirectionY",
            defaultValue: SIMD2<Float>(1.0, -0.116)
        )

        var params = LightRayParameters(
            time: time,
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            rayPosition: rayPosition,
            speed: (context.parameters["speed"] as? Float) ?? 1.5,
            numRays: (context.parameters["numRays"] as? Float) ?? 2.0,
            depthAttenuation: (context.parameters["depthAttenuation"] as? Float) ?? 1.0,
            rayLength: (context.parameters["rayLength"] as? Float) ?? 1.0,
            rayDirection: rayDirection,
            rayWidth: (context.parameters["rayWidth"] as? Float) ?? 1.0,
            rayColor: rayColor
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<LightRayParameters>.stride, index: 0)
    }
}
