import Foundation
import Metal

public class GlitchShader: Shader {
    public var name: String { "glitch" }

    public var needsAnimation: Bool { true }

    public var parameters: [ShaderParameter] {
        [
            ShaderParameter(name: "intensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "chromaticAberration", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "scanlineIntensity", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "glitchFrequency", type: .float, defaultValue: 0.15),
            ShaderParameter(name: "blockSize", type: .float, defaultValue: 50.0),
            ShaderParameter(name: "grainIntensity", type: .float, defaultValue: 0.04),
            ShaderParameter(name: "vignetteStrength", type: .float, defaultValue: 0.5),
            ShaderParameter(name: "chromaticSpread", type: .float, defaultValue: 1.0),
            ShaderParameter(name: "time", type: .float, defaultValue: 0.0)
        ]
    }

    public init() {
        ShaderRegistry.shared.register(self)
    }

    public func compile(device: MTLDevice) throws -> MTLRenderPipelineState {
        return try MetalLibraryLoader.loadAndCompilePipeline(
            resourceName: "Glitch",
            subdirectory: "Shaders",
            vertexFunctionName: "fullscreenVertex",
            fragmentFunctionName: "glitchFragment",
            bundle: Bundle(for: type(of: self)),
            device: device,
            enableBlending: false
        )
    }

    public func encode(encoder: MTLRenderCommandEncoder, context: ShaderContext) {
        encoder.setFragmentTexture(context.inputTexture, index: 0)

        struct GlitchParameters {
            var intensity: Float
            var time: Float
            var chromaticAberration: Float
            var scanlineIntensity: Float
            var glitchFrequency: Float
            var blockSize: Float
            var grainIntensity: Float
            var vignetteStrength: Float
            var chromaticSpread: Float
        }

        var params = GlitchParameters(
            intensity: (context.parameters["intensity"] as? Float) ?? 1.0,
            time: (context.parameters["time"] as? Float) ?? 0.0,
            chromaticAberration: (context.parameters["chromaticAberration"] as? Float) ?? 1.0,
            scanlineIntensity: (context.parameters["scanlineIntensity"] as? Float) ?? 1.0,
            glitchFrequency: (context.parameters["glitchFrequency"] as? Float) ?? 0.15,
            blockSize: (context.parameters["blockSize"] as? Float) ?? 50.0,
            grainIntensity: (context.parameters["grainIntensity"] as? Float) ?? 0.04,
            vignetteStrength: (context.parameters["vignetteStrength"] as? Float) ?? 0.5,
            chromaticSpread: (context.parameters["chromaticSpread"] as? Float) ?? 1.0
        )

        encoder.setFragmentBytes(&params, length: MemoryLayout<GlitchParameters>.stride, index: 0)
    }
}
