import Foundation
import Metal

public class LiquidMetalOverlay: Overlay {
    public var name: String { "liquidMetal" }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "borderWidth", type: .float, defaultValue: 4.0),
            ShaderParameter(name: "cornerRadius", type: .float, defaultValue: 12.0),
            ShaderParameter(name: "baseColor", type: .float3, defaultValue: [0.15, 0.15, 0.2]),
            ShaderParameter(name: "highlightColor", type: .float3, defaultValue: [0.9, 0.92, 1.0]),
            ShaderParameter(name: "flowSpeed", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "repetition", type: .float, defaultValue: 4.0),
            ShaderParameter(name: "distortion", type: .float, defaultValue: 0.3),
            ShaderParameter(name: "chromaticAberration", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "flowOffsetX", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "flowOffsetY", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "flowAngle", type: .float, defaultValue: 1.22),
            ShaderParameter(name: "specularIntensity", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "specularPositionX", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "specularPositionY", type: .float, defaultValue: -0.5),
            ShaderParameter(name: "specularSize", type: .float, defaultValue: 0.3),
            ShaderParameter(name: "roughness", type: .float, defaultValue: 0.0)
        ]
    }

    public var needsAnimation: Bool { true }

    private var time: Float = 0.0

    public init() {
        OverlayRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "LiquidMetal",
            subdirectory: "Overlays",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "liquidMetalFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: true
        )
    }

    public func update(deltaTime: Double) {
        time += Float(deltaTime)
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext) {
        struct LiquidMetalParameters {
            var time: Float
            var intensity: Float
            var viewSize: SIMD2<Float>
            var borderWidth: Float
            var cornerRadius: Float
            var baseColor: SIMD3<Float>
            var highlightColor: SIMD3<Float>
            var flowSpeed: Float
            var repetition: Float
            var distortion: Float
            var chromaticAberration: Float
            var flowOffset: SIMD2<Float>
            var flowAngle: Float
            var specularIntensity: Float
            var specularPosition: SIMD2<Float>
            var specularSize: Float
            var roughness: Float
        }

        let baseColor = extractFloat3(
            from: context.parameters,
            arrayName: "baseColor",
            rName: "baseColorR",
            gName: "baseColorG",
            bName: "baseColorB",
            defaultValue: SIMD3<Float>(0.15, 0.15, 0.2)
        )

        let highlightColor = extractFloat3(
            from: context.parameters,
            arrayName: "highlightColor",
            rName: "highlightColorR",
            gName: "highlightColorG",
            bName: "highlightColorB",
            defaultValue: SIMD3<Float>(0.9, 0.92, 1.0)
        )

        let flowOffsetX = (context.parameters["flowOffsetX"] as? Float) ?? 0.0
        let flowOffsetY = (context.parameters["flowOffsetY"] as? Float) ?? 0.0
        let specularPositionX = (context.parameters["specularPositionX"] as? Float) ?? 0.0
        let specularPositionY = (context.parameters["specularPositionY"] as? Float) ?? -0.5

        var params = LiquidMetalParameters(
            time: time,
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            viewSize: SIMD2<Float>(Float(context.viewSize.width), Float(context.viewSize.height)),
            borderWidth: (context.parameters["borderWidth"] as? Float) ?? 4.0,
            cornerRadius: (context.parameters["cornerRadius"] as? Float) ?? 12.0,
            baseColor: baseColor,
            highlightColor: highlightColor,
            flowSpeed: (context.parameters["flowSpeed"] as? Float) ?? 1.0,
            repetition: (context.parameters["repetition"] as? Float) ?? 4.0,
            distortion: (context.parameters["distortion"] as? Float) ?? 0.3,
            chromaticAberration: (context.parameters["chromaticAberration"] as? Float) ?? 1.0,
            flowOffset: SIMD2<Float>(flowOffsetX, flowOffsetY),
            flowAngle: (context.parameters["flowAngle"] as? Float) ?? 1.22,
            specularIntensity: (context.parameters["specularIntensity"] as? Float) ?? 0.0,
            specularPosition: SIMD2<Float>(specularPositionX, specularPositionY),
            specularSize: (context.parameters["specularSize"] as? Float) ?? 0.3,
            roughness: (context.parameters["roughness"] as? Float) ?? 0.0
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<LiquidMetalParameters>.stride, index: 0)
    }
}
