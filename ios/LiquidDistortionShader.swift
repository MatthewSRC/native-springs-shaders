import Foundation
import Metal

public class LiquidDistortionShader: Shader {
    public var name: String { "liquidDistortion" }

    public var needsAnimation: Bool { true }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "speed", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "waveScale", type: .float, defaultValue: 3.0),
            ShaderParameter(name: "time", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "turbulence", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "chromaticAberration", type: .float, defaultValue: 0.3),
            ShaderParameter(name: "liquidVariant", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "flowDirection", type: .float2, defaultValue: [0.7, -1.0]),
            ShaderParameter(name: "color", type: .float3, defaultValue: [0.85, 0.95, 1.0]),
            ShaderParameter(name: "shineStrength", type: .float, defaultValue: 0.15),
            ShaderParameter(name: "colorTintStrength", type: .float, defaultValue: 0.2)
        ]
    }

    public init() {
        ShaderRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "LiquidDistortion",
            subdirectory: "Shaders",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "liquidDistortionFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: false
        )
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: ShaderContext) {
        encoder.setFragmentTexture(context.inputTexture, index: 0)

        struct LiquidDistortionParameters {
            var intensity: Float
            var speed: Float
            var waveScale: Float
            var time: Float
            var turbulence: Float
            var chromaticAberration: Float
            var liquidVariant: Float
            var shineStrength: Float
            var colorTintStrength: Float
            var padding: Float
            var flowDirection: SIMD2<Float>
            var liquidColor: SIMD3<Float>
        }

        let variantValue: Float
        if let variantStr = context.parameters["liquidVariant"] as? String {
            switch variantStr {
            case "glass":
                variantValue = 1.0
            case "oil":
                variantValue = 2.0
            default:
                variantValue = 0.0
            }
        } else {
            variantValue = (context.parameters["liquidVariant"] as? Float) ?? 0.0
        }

        let flowDirection = extractFloat2(from: context.parameters, arrayName: "flowDirection", xName: "flowDirectionX", yName: "flowDirectionY", defaultValue: SIMD2<Float>(0.7, -1.0))
        let liquidColor = extractFloat3(from: context.parameters, arrayName: "color", rName: nil, gName: nil, bName: nil, defaultValue: SIMD3<Float>(0.85, 0.95, 1.0))

        var params = LiquidDistortionParameters(
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            speed: (context.parameters["speed"] as? Float) ?? 1.0,
            waveScale: (context.parameters["waveScale"] as? Float) ?? 3.0,
            time: (context.parameters["time"] as? Float) ?? 0.0,
            turbulence: (context.parameters["turbulence"] as? Float) ?? 1.0,
            chromaticAberration: (context.parameters["chromaticAberration"] as? Float) ?? 0.3,
            liquidVariant: variantValue,
            shineStrength: (context.parameters["shineStrength"] as? Float) ?? 0.15,
            colorTintStrength: (context.parameters["colorTintStrength"] as? Float) ?? 0.2,
            padding: 0.0,
            flowDirection: flowDirection,
            liquidColor: liquidColor
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<LiquidDistortionParameters>.stride, index: 0)
    }
}
