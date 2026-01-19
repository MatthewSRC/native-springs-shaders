import Foundation
import Metal
import UIKit

public struct OverlayContext {
    public let outputTexture: MTLTexture
    public let viewSize: CGSize
    public let deltaTime: TimeInterval
    public let parameters: [String: Any]

    public init(outputTexture: MTLTexture, viewSize: CGSize, deltaTime: TimeInterval, parameters: [String: Any]) {
        self.outputTexture = outputTexture
        self.viewSize = viewSize
        self.deltaTime = deltaTime
        self.parameters = parameters
    }
}

public protocol Overlay: AnyObject {
    var name: String { get }

    var parameters: [ShaderParameter] { get }

    var needsAnimation: Bool { get }

    func compile(device: MTLDevice) throws -> MTLRenderPipelineState

    func update(deltaTime: TimeInterval)

    func encode(encoder: MTLRenderCommandEncoder, context: OverlayContext)
}
