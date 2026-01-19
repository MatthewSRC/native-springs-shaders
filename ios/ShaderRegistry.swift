import Foundation
import Metal

public class ShaderRegistry {
    public static let shared = ShaderRegistry()

    private var shaders: [String: Shader] = [:]
    private var pipelineCache: [String: MTLRenderPipelineState] = [:]
    private let syncQueue = DispatchQueue(label: "com.nativesprings.shaders.shaderregistry", attributes: .concurrent)

    private init() {}

    public func register(_ shader: Shader) {
        syncQueue.async(flags: .barrier) {
            self.shaders[shader.name] = shader
            DebugConfig.log("Shader registered: \(shader.name)")
        }
    }

    public func get(_ name: String) -> Shader? {
        syncQueue.sync {
            shaders[name]
        }
    }

    public func compiledPipeline(for name: String, device: MTLDevice) throws -> MTLRenderPipelineState {
        if let cached = syncQueue.sync(execute: { pipelineCache[name] }) {
            return cached
        }

        return try syncQueue.sync(flags: .barrier) {
            if let cached = pipelineCache[name] {
                return cached
            }

            guard let shader = shaders[name] else {
                throw ShaderError.shaderNotFound(name)
            }

            let pipeline = try shader.compile(device: device)
            pipelineCache[name] = pipeline

            DebugConfig.log("Shader compiled: \(name)")
            return pipeline
        }
    }

    public var registeredShaders: [String] {
        syncQueue.sync {
            Array(shaders.keys)
        }
    }

    public func clearCache() {
        syncQueue.async(flags: .barrier) {
            self.pipelineCache.removeAll()
            DebugConfig.log("Shader pipeline cache cleared")
        }
    }
}

public enum ShaderError: Error, LocalizedError {
    case shaderNotFound(String)
    case compilationFailed(String)
    case invalidParameter(String)

    public var errorDescription: String? {
        switch self {
        case .shaderNotFound(let name):
            return "Shader '\(name)' not found in registry"
        case .compilationFailed(let reason):
            return "Shader compilation failed: \(reason)"
        case .invalidParameter(let name):
            return "Invalid parameter: \(name)"
        }
    }
}
