import Foundation
import Metal

public class OverlayRegistry {
    public static let shared = OverlayRegistry()

    private var overlays: [String: Overlay] = [:]

    private var pipelineCache: [String: MTLRenderPipelineState] = [:]

    private let syncQueue = DispatchQueue(label: "com.nativesprings.shaders.overlayregistry", attributes: .concurrent)

    private init() {}


    public func register(_ overlay: Overlay) {
        syncQueue.async(flags: .barrier) {
            self.overlays[overlay.name] = overlay
            DebugConfig.log("Overlay registered: \(overlay.name)")
        }
    }

    public func get(_ name: String) -> Overlay? {
        syncQueue.sync {
            overlays[name]
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

            guard let overlay = overlays[name] else {
                throw OverlayError.overlayNotFound(name)
            }

            let pipeline = try overlay.compile(device: device)
            pipelineCache[name] = pipeline

            DebugConfig.log("Overlay compiled: \(name)")
            return pipeline
        }
    }

    public var registeredOverlays: [String] {
        syncQueue.sync {
            Array(overlays.keys)
        }
    }

    public func clearCache() {
        syncQueue.async(flags: .barrier) {
            self.pipelineCache.removeAll()
            DebugConfig.log("Overlay pipeline cache cleared")
        }
    }
}

public enum OverlayError: Error, LocalizedError {
    case overlayNotFound(String)
    case compilationFailed(String)
    case invalidParameter(String)

    public var errorDescription: String? {
        switch self {
        case .overlayNotFound(let name):
            return "Overlay '\(name)' not found in registry"
        case .compilationFailed(let reason):
            return "Overlay compilation failed: \(reason)"
        case .invalidParameter(let name):
            return "Invalid parameter: \(name)"
        }
    }
}
