import Foundation
import Metal

public struct ShaderParameter {
    public let name: String
    public let type: ShaderParameterType
    public let defaultValue: Any?

    public init(name: String, type: ShaderParameterType, defaultValue: Any? = nil) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
}

public enum ShaderParameterType {
    case float
    case float2
    case float3
    case float4
    case int
    case bool
}

public struct ShaderContext {
    public let inputTexture: MTLTexture
    public let outputTexture: MTLTexture
    public let parameters: [String: Any]

    public init(inputTexture: MTLTexture, outputTexture: MTLTexture, parameters: [String: Any]) {
        self.inputTexture = inputTexture
        self.outputTexture = outputTexture
        self.parameters = parameters
    }
}

public protocol Shader: AnyObject {
    var name: String { get }

    var parameters: [ShaderParameter] { get }

    var needsAnimation: Bool { get }

    func compile(device: MTLDevice) throws -> MTLRenderPipelineState

    func encode(encoder: MTLRenderCommandEncoder, context: ShaderContext)
}

public extension Shader {
    var needsAnimation: Bool { false }
}
