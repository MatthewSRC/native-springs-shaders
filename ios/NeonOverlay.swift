import Foundation
import Metal

public class NeonOverlay: Overlay {
    public var name: String { "neon" }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "borderWidth", type: .float, defaultValue: 3.0),
            ShaderParameter(name: "cornerRadius", type: .float, defaultValue: 16.0),
            ShaderParameter(name: "color", type: .float3, defaultValue: [0.0, 1.0, 0.9]),
            ShaderParameter(name: "secondaryColor", type: .float3, defaultValue: [1.0, 0.0, 0.8]),
            ShaderParameter(name: "glowSize", type: .float, defaultValue: 4.0),
            ShaderParameter(name: "glowFalloff", type: .float, defaultValue: 1.2),
            ShaderParameter(name: "flowSpeed", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "flowIntensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "pulseSpeed", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "pulseIntensity", type: .float, defaultValue: 0.2),
            ShaderParameter(name: "flickerIntensity", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "colorBlend", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "inset", type: .float, defaultValue: 0.0),
        ]
    }

    public var needsAnimation: Bool { true }

    private var time: Float = 0.0

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "Neon",
            subdirectory: "Overlays",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "neonFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: true
        )
    }

    public func update(deltaTime: TimeInterval) {
        time += Float(deltaTime)
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext) {
        struct NeonParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var borderWidth: Float
            var cornerRadius: Float
            var color: SIMD3<Float>
            var secondaryColor: SIMD3<Float>
            var glowSize: Float
            var glowFalloff: Float
            var flowSpeed: Float
            var flowIntensity: Float
            var pulseSpeed: Float
            var pulseIntensity: Float
            var flickerIntensity: Float
            var colorBlend: Float
            var inset: Float
        }

        let color = extractFloat3(
            from: context.parameters,
            arrayName: "color",
            rName: "colorR",
            gName: "colorG",
            bName: "colorB",
            defaultValue: SIMD3<Float>(0.0, 1.0, 0.9)
        )

        let secondaryColor = extractFloat3(
            from: context.parameters,
            arrayName: "secondaryColor",
            rName: "secondaryColorR",
            gName: "secondaryColorG",
            bName: "secondaryColorB",
            defaultValue: SIMD3<Float>(1.0, 0.0, 0.8)
        )

        var params = NeonParameters(
            time: time,
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            borderWidth: (context.parameters["borderWidth"] as? Float) ?? 4.0,
            cornerRadius: (context.parameters["cornerRadius"] as? Float) ?? 12.0,
            color: color,
            secondaryColor: secondaryColor,
            glowSize: (context.parameters["glowSize"] as? Float) ?? 3.0,
            glowFalloff: (context.parameters["glowFalloff"] as? Float) ?? 1.5,
            flowSpeed: (context.parameters["flowSpeed"] as? Float) ?? 1.0,
            flowIntensity: (context.parameters["flowIntensity"] as? Float) ?? 0.8,
            pulseSpeed: (context.parameters["pulseSpeed"] as? Float) ?? 1.0,
            pulseIntensity: (context.parameters["pulseIntensity"] as? Float) ?? 0.3,
            flickerIntensity: (context.parameters["flickerIntensity"] as? Float) ?? 0.0,
            colorBlend: (context.parameters["colorBlend"] as? Float) ?? 0.0,
            inset: (context.parameters["inset"] as? Float) ?? 0.0
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<NeonParameters>.stride, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}
