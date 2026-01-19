import Foundation
import Metal

public class MetalLibraryLoader {
    public static func loadLibrary(
        resourceName: String,
        subdirectory: String? = nil,
        bundle: Bundle,
        device: MTLDevice
    ) throws -> MTLLibrary {
        let commonSource = try loadCommonSource(bundle: bundle)

        if let subdir = subdirectory,
           let url = bundle.url(forResource: resourceName, withExtension: "metal", subdirectory: subdir) {
            do {
                var source = try String(contentsOf: url, encoding: .utf8)
                source = source.replacingOccurrences(of: #"#include\s+"\.\.\/Common\.metal""#, with: "", options: .regularExpression)
                source = source.replacingOccurrences(of: #"#include\s+"Common\.metal""#, with: "", options: .regularExpression)

                let fullSource = commonSource + "\n" + source
                return try device.makeLibrary(source: fullSource, options: nil)
            } catch {
                throw ShaderError.compilationFailed("Failed to compile \(resourceName).metal from subdirectory '\(subdir)': \(error.localizedDescription)")
            }
        }

        if let url = bundle.url(forResource: resourceName, withExtension: "metal") {
            do {
                var source = try String(contentsOf: url, encoding: .utf8)
                source = source.replacingOccurrences(of: #"#include\s+"\.\.\/Common\.metal""#, with: "", options: .regularExpression)
                source = source.replacingOccurrences(of: #"#include\s+"Common\.metal""#, with: "", options: .regularExpression)

                let fullSource = commonSource + "\n" + source
                return try device.makeLibrary(source: fullSource, options: nil)
            } catch {
                throw ShaderError.compilationFailed("Failed to compile \(resourceName).metal: \(error.localizedDescription)")
            }
        }

        if let library = device.makeDefaultLibrary() {
            return library
        }

        throw ShaderError.compilationFailed("\(resourceName).metal not found in bundle resources")
    }

    private static func loadCommonSource(bundle: Bundle) throws -> String {
        if let url = bundle.url(forResource: "Common", withExtension: "metal") {
            do {
                return try String(contentsOf: url, encoding: .utf8)
            } catch {
                throw ShaderError.compilationFailed("Failed to load Common.metal: \(error.localizedDescription)")
            }
        }

        throw ShaderError.compilationFailed("Common.metal not found in bundle resources")
    }

    public static func compilePipeline(
        library: MTLLibrary,
        vertexFunctionName: String,
        fragmentFunctionName: String,
        device: MTLDevice,
        enableBlending: Bool = false
    ) throws -> MTLRenderPipelineState {
        guard let vertexFunction = library.makeFunction(name: vertexFunctionName) else {
            throw ShaderError.compilationFailed("Function '\(vertexFunctionName)' not found in Metal library")
        }

        guard let fragmentFunction = library.makeFunction(name: fragmentFunctionName) else {
            throw ShaderError.compilationFailed("Function '\(fragmentFunctionName)' not found in Metal library")
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        if enableBlending {
            configureAlphaBlending(pipelineDescriptor: pipelineDescriptor)
        }

        do {
            return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            throw ShaderError.compilationFailed("Failed to create render pipeline state for \(fragmentFunctionName): \(error.localizedDescription)")
        }
    }

    private static func configureAlphaBlending(pipelineDescriptor: MTLRenderPipelineDescriptor) {
        let attachment = pipelineDescriptor.colorAttachments[0]
        attachment?.isBlendingEnabled = true
        attachment?.sourceRGBBlendFactor = .sourceAlpha
        attachment?.destinationRGBBlendFactor = .oneMinusSourceAlpha
        attachment?.sourceAlphaBlendFactor = .sourceAlpha
        attachment?.destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }

    public static func loadAndCompilePipeline(
        resourceName: String,
        subdirectory: String? = nil,
        vertexFunctionName: String,
        fragmentFunctionName: String,
        bundle: Bundle,
        device: MTLDevice,
        enableBlending: Bool = false
    ) throws -> MTLRenderPipelineState {
        let library = try loadLibrary(
            resourceName: resourceName,
            subdirectory: subdirectory,
            bundle: bundle,
            device: device
        )

        return try compilePipeline(
            library: library,
            vertexFunctionName: vertexFunctionName,
            fragmentFunctionName: fragmentFunctionName,
            device: device,
            enableBlending: enableBlending
        )
    }
}
