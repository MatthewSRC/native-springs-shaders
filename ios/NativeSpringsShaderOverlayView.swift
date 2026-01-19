import ExpoModulesCore
import Metal
import MetalKit
import UIKit

private class DisplayLinkTarget {
    weak var view: NativeSpringsShaderOverlayView?

    init(view: NativeSpringsShaderOverlayView) {
        self.view = view
    }

    @objc func update(_ displayLink: CADisplayLink) {
        view?.updateAnimation()
    }
}

class NativeSpringsShaderOverlayView: ExpoView {

    private let metalView = MTKView()
    private var metalDevice: MTLDevice?
    private var commandQueue: MTLCommandQueue?

    private var currentOverlay: Overlay?
    private var overlayParameters: [String: Any] = [:]

    private var displayLink: CADisplayLink?
    private var displayLinkTarget: DisplayLinkTarget?
    private var lastUpdateTime: CFTimeInterval = 0

    var overlayName: String? {
        didSet {
            loadOverlay()
        }
    }

    func setParameter(name: String, value: Any) {
        let convertedValue: Any
        switch value {
        case let num as NSNumber:
            if CFGetTypeID(num as CFTypeRef) == CFBooleanGetTypeID() {
                convertedValue = num.boolValue
            } else {
                convertedValue = num.floatValue
            }
        case let double as Double:
            convertedValue = Float(double)
        case let float as Float:
            convertedValue = float
        case let int as Int:
            convertedValue = Float(int)
        case let bool as Bool:
            convertedValue = bool
        case let string as String:
            convertedValue = string
        default:
            convertedValue = value
        }

        overlayParameters[name] = convertedValue

        metalView.setNeedsDisplay()
    }

    func setParameters(_ params: [String: Any]) {
        for (key, value) in params {
            setParameter(name: key, value: value)
        }
    }

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        setupMetal()
        setupMetalView()
    }

    deinit {
        stopAnimation()
        OverlayRegistry.shared.clearCache()
    }


    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            DebugConfig.log("Metal is not supported on this device")
            return
        }

        metalDevice = device
        commandQueue = device.makeCommandQueue()

        DebugConfig.log("Metal device initialized for overlay")
    }

    private func setupMetalView() {
        guard let device = metalDevice else { return }

        metalView.device = device
        metalView.framebufferOnly = false
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        metalView.isOpaque = false
        metalView.backgroundColor = .clear
        metalView.delegate = self

        metalView.enableSetNeedsDisplay = true
        metalView.isPaused = true

        metalView.isUserInteractionEnabled = false

        addSubview(metalView)
    }

    private func loadOverlay() {
        guard let overlayName = overlayName else {
            currentOverlay = nil
            stopAnimation()
            return
        }

        currentOverlay = OverlayRegistry.shared.get(overlayName)

        if let overlay = currentOverlay {
            for param in overlay.parameters {
                if overlayParameters[param.name] == nil, let defaultValue = param.defaultValue {
                    overlayParameters[param.name] = defaultValue
                }
            }

            if overlay.needsAnimation {
                startAnimation()
            } else {
                stopAnimation()
            }

            metalView.setNeedsDisplay()
        }
    }

    private func startAnimation() {
        guard displayLink == nil else { return }

        let target = DisplayLinkTarget(view: self)
        displayLinkTarget = target
        let link = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.update(_:)))

        link.add(to: .main, forMode: .default)
        link.add(to: .main, forMode: .tracking)

        displayLink = link
        lastUpdateTime = CACurrentMediaTime()

        DebugConfig.log("Started overlay animation")
    }

    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        displayLinkTarget = nil

        DebugConfig.log("Stopped overlay animation")
    }

    @objc public func updateAnimation() {
        guard let overlay = currentOverlay else { return }

        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        if let window = window {
            let viewFrameInWindow = convert(bounds, to: window)
            let windowBounds = window.bounds
            let viewCenterY = viewFrameInWindow.origin.y + (viewFrameInWindow.height / 2)

            if viewCenterY < 0 || viewCenterY > windowBounds.height {
                return
            }
        } else {
            return
        }

        overlay.update(deltaTime: deltaTime)
        metalView.setNeedsDisplay()
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if subview != metalView {
            bringSubviewToFront(metalView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        metalView.frame = bounds
    }

    func renderOverlay(drawable: CAMetalDrawable) {
        guard let device = metalDevice,
              let commandQueue = commandQueue,
              let overlay = currentOverlay else {
            return
        }

        let pipeline: MTLRenderPipelineState
        do {
            pipeline = try OverlayRegistry.shared.compiledPipeline(for: overlay.name, device: device)
        } catch {
            return
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderEncoder.setRenderPipelineState(pipeline)

        let context = OverlayContext(
            outputTexture: drawable.texture,
            viewSize: bounds.size,
            deltaTime: displayLink?.duration ?? 0,
            parameters: overlayParameters
        )

        overlay.encode(encoder: renderEncoder, context: context)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension NativeSpringsShaderOverlayView: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        renderOverlay(drawable: drawable)
    }
}
