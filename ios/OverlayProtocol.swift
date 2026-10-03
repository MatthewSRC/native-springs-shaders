import Foundation
import Metal
import UIKit

public struct OverlayContext {
    public let outputTexture: MTLTexture
    public let viewSize: CGSize
    public let deltaTime: TimeInterval
    public let parameters: [String: Any]
    /// Identifies the view being rendered, for overlays that keep per-view state.
    public let viewId: Int

    public init(outputTexture: MTLTexture, viewSize: CGSize, deltaTime: TimeInterval, parameters: [String: Any], viewId: Int = 0) {
        self.outputTexture = outputTexture
        self.viewSize = viewSize
        self.deltaTime = deltaTime
        self.parameters = parameters
        self.viewId = viewId
    }
}

public protocol Overlay: AnyObject {
    var name: String { get }

    var parameters: [ShaderParameter] { get }

    var needsAnimation: Bool { get }

    /// Render resolution as a fraction of the screen's pixel density.
    /// Views can override it with a `renderScale` parameter.
    var renderScale: CGFloat { get }

    func compile(device: MTLDevice) throws -> MTLRenderPipelineState

    func update(deltaTime: TimeInterval)

    func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext)

    /// Called when a view using this overlay is destroyed, so per-view state can be dropped.
    func releaseView(viewId: Int)
}

public extension Overlay {
    var renderScale: CGFloat { 1.0 }

    func releaseView(viewId: Int) {}
}
