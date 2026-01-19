import Foundation
import Metal

public class RippleShader: Shader {
    public var name: String { "ripple" }

    public var needsAnimation: Bool { true }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "touchPoint", type: .float2, defaultValue: [0.5, 0.5]),
            ShaderParameter(name: "touchTime", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "frequency", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "damping", type: .float, defaultValue: 0.8),
            ShaderParameter(name: "rippleVariant", type: .float, defaultValue: 0.0),
            ShaderParameter(name: "speed", type: .float, defaultValue: 300.0),
            ShaderParameter(name: "ringWidth", type: .float, defaultValue: 40.0),
            ShaderParameter(name: "slowdownFactor", type: .float, defaultValue: 0.5),
            ShaderParameter(name: "displacementStrength", type: .float, defaultValue: 0.05),
            ShaderParameter(name: "highlightStrength", type: .float, defaultValue: 0.1),
            ShaderParameter(name: "color", type: .float3, defaultValue: [1.0, 1.0, 1.0]),
            ShaderParameter(name: "time", type: .float, defaultValue: 0.0)
        ]
    }

    public init() {
        ShaderRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "Ripple",
            subdirectory: "Shaders",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "rippleFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: false
        )
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: ShaderContext) {
        encoder.setFragmentTexture(context.inputTexture, index: 0)

        struct RippleParameters {
            var intensity: Float
            var time: Float
            var touchPoint: SIMD2<Float>
            var touchTime: Float
            var frequency: Float
            var damping: Float
            var rippleVariant: Float
            var speed: Float
            var ringWidth: Float
            var slowdownFactor: Float
            var displacementStrength: Float
            var highlightStrength: Float
            var rippleColor: SIMD3<Float>
        }

        let touchPoint = extractFloat2(from: context.parameters, arrayName: "touchPoint", xName: nil, yName: nil, defaultValue: SIMD2<Float>(0.5, 0.5))
        let rippleColor = extractFloat3(from: context.parameters, arrayName: "color", rName: nil, gName: nil, bName: nil, defaultValue: SIMD3<Float>(1.0, 1.0, 1.0))

        let variantValue: Float
        if let variantStr = context.parameters["rippleVariant"] as? String {
            switch variantStr {
            case "realistic":
                variantValue = 1.0
            default:
                variantValue = 0.0
            }
        } else {
            variantValue = (context.parameters["rippleVariant"] as? Float) ?? 0.0
        }

        var params = RippleParameters(
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            time: (context.parameters["time"] as? Float) ?? 0.0,
            touchPoint: touchPoint,
            touchTime: (context.parameters["touchTime"] as? Float) ?? 0.0,
            frequency: (context.parameters["frequency"] as? Float) ?? 1.0,
            damping: (context.parameters["damping"] as? Float) ?? 0.8,
            rippleVariant: variantValue,
            speed: (context.parameters["speed"] as? Float) ?? 300.0,
            ringWidth: (context.parameters["ringWidth"] as? Float) ?? 40.0,
            slowdownFactor: (context.parameters["slowdownFactor"] as? Float) ?? 0.5,
            displacementStrength: (context.parameters["displacementStrength"] as? Float) ?? 0.05,
            highlightStrength: (context.parameters["highlightStrength"] as? Float) ?? 0.1,
            rippleColor: rippleColor
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<RippleParameters>.stride, index: 0)
    }
}
