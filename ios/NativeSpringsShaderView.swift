import ExpoModulesCore
import Metal
import MetalKit
import UIKit

private class DisplayLinkTarget {
    weak var view: NativeSpringsShaderView?

    init(view: NativeSpringsShaderView) {
        self.view = view
    }

    @objc func update(_ displayLink: CADisplayLink) {
        view?.updateAnimation()
    }
}

class NativeSpringsShaderView: ExpoView, MTKViewDelegate {
    private let outputView = UIImageView()
    private let metalView = MTKView()
    private let childrenContainer = UIView()
    private var metalDevice: MTLDevice?
    private var commandQueue: MTLCommandQueue?

    private var reactChildren: [UIView] = []

    private var currentShader: Shader?
    private var shaderParameters: [String: Any] = [:]
    private let parametersQueue = DispatchQueue(label: "com.nativesprings.shaders.parameters", attributes: .concurrent)
    private var needsShaderUpdate = false
    private var lastBounds: CGRect = .zero

    private var displayLink: CADisplayLink?
    private var displayLinkTarget: DisplayLinkTarget?
    private var lastUpdateTime: CFTimeInterval = 0
    private var animationTime: Float = 0.0
    private var lastSnapshotRefreshTime: CFTimeInterval = 0

    private var cachedSnapshot: UIImage?
    private var cachedInputTexture: MTLTexture?
    private var cachedOutputTexture: MTLTexture?
    private var cachedStaticResult: UIImage?
    private var staticResultNeedsUpdate = false
    private var isWaitingForInitialDelay = false

    private let onShaderError = EventDispatcher()

    var shaderName: String? {
        didSet {
            guard oldValue != shaderName else { return }

            DispatchQueue.main.async { [weak self] in
                self?.loadShader()
            }
        }
    }

    var autoRefreshSnapshot: Bool = false
    var snapshotRefreshInterval: Double = 0.0
    var initialSnapshotDelay: Double = 0.0

    func setParameter(name: String, value: Any) {
        let convertedValue: Any
        switch value {
        case let num as NSNumber:
            // React Native bridge sends booleans as NSNumber - CFBooleanGetTypeID distinguishes true bools from numeric 0/1
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

        parametersQueue.async(flags: .barrier) { [weak self] in
            self?.shaderParameters[name] = convertedValue
        }


        if let shader = currentShader, !shader.needsAnimation {
            staticResultNeedsUpdate = true
            needsShaderUpdate = true
            setNeedsLayout()
        }
    }

    func setParameters(_ params: [String: Any]) {
        for (key, value) in params {
            setParameter(name: key, value: value)
        }
    }

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        setupViews()
        setupMetal()
        lastSnapshotRefreshTime = CACurrentMediaTime()
    }

    deinit {
        stopAnimation()

        for child in childrenContainer.subviews {
            child.removeFromSuperview()
        }

        cachedSnapshot = nil
        cachedInputTexture = nil
        cachedOutputTexture = nil
        cachedStaticResult = nil
    }

    private func setupViews() {
        addSubview(childrenContainer)
        childrenContainer.backgroundColor = .clear
        childrenContainer.isUserInteractionEnabled = true

        addSubview(outputView)
        outputView.contentMode = .scaleAspectFill
        outputView.clipsToBounds = true
        outputView.isUserInteractionEnabled = false

        addSubview(metalView)
        metalView.delegate = self
        metalView.isHidden = true
        metalView.framebufferOnly = false
        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        metalView.isOpaque = true
        metalView.backgroundColor = nil
        metalView.enableSetNeedsDisplay = true
        metalView.isPaused = true
        metalView.isUserInteractionEnabled = false
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        if subview !== childrenContainer && subview !== outputView && subview !== metalView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.invalidateCache()
                self.needsShaderUpdate = true
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }

    override func insertSubview(_ subview: UIView, at index: Int) {
        if subview !== childrenContainer && subview !== outputView && subview !== metalView {
            reactChildren.insert(subview, at: min(index, reactChildren.count))
        }
        super.insertSubview(subview, at: index)
    }

    override func willRemoveSubview(_ subview: UIView) {
        if let reactIndex = reactChildren.firstIndex(of: subview) {
            reactChildren.remove(at: reactIndex)

            if reactIndex < subviews.count && subviews[reactIndex] !== subview {
                subview.removeFromSuperview()
                super.insertSubview(subview, at: reactIndex)
            }
        }
        super.willRemoveSubview(subview)
    }

    override func didUpdateReactSubviews() {
        super.didUpdateReactSubviews()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.invalidateCache()
            self.needsShaderUpdate = true
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else { return }

        metalDevice = device
        commandQueue = device.makeCommandQueue()
        metalView.device = device
    }

    private func loadShader() {
        guard let shaderName = shaderName else {
            currentShader = nil
            stopAnimation()
            invalidateCache()
            return
        }

        currentShader = ShaderRegistry.shared.get(shaderName)

        if let shader = currentShader {
            parametersQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                for param in shader.parameters {
                    if self.shaderParameters[param.name] == nil, let defaultValue = param.defaultValue {
                        self.shaderParameters[param.name] = defaultValue
                    }
                }
            }

            invalidateCache()

            if initialSnapshotDelay > 0 {
                outputView.isHidden = true
                metalView.isHidden = true
                isWaitingForInitialDelay = true

                DispatchQueue.main.asyncAfter(deadline: .now() + initialSnapshotDelay / 1000.0) { [weak self] in
                    guard let self = self, let shader = self.currentShader else { return }

                    self.isWaitingForInitialDelay = false

                    if shader.needsAnimation {
                        self.outputView.isHidden = true
                        self.metalView.isHidden = false
                        self.startAnimation()
                    } else {
                        self.metalView.isHidden = true
                        self.outputView.isHidden = false
                        self.stopAnimation()
                    }

                    self.needsShaderUpdate = true
                    self.setNeedsLayout()
                }
            } else {
                if shader.needsAnimation {
                    outputView.isHidden = true
                    metalView.isHidden = false
                    startAnimation()
                } else {
                    metalView.isHidden = true
                    outputView.isHidden = false
                    stopAnimation()
                }

                needsShaderUpdate = true
                setNeedsLayout()
            }
        } else {
            stopAnimation()
            invalidateCache()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        childrenContainer.frame = bounds
        outputView.frame = bounds
        metalView.frame = bounds

        let boundsChanged = !lastBounds.equalTo(bounds)

        if bounds.size.width > 0 && bounds.size.height > 0 {
            if boundsChanged || needsShaderUpdate {
                lastBounds = bounds
                needsShaderUpdate = false

                if boundsChanged {
                    invalidateCache()
                } else if let shader = currentShader, !shader.needsAnimation {
                    staticResultNeedsUpdate = true
                }

                if let window = window {
                    let viewFrameInWindow = convert(bounds, to: window)
                    let windowBounds = window.bounds

                    let viewCenterY = viewFrameInWindow.origin.y + (viewFrameInWindow.height / 2)

                    if viewCenterY >= 0 && viewCenterY <= windowBounds.height {
                        updateShaderEffect()
                    }
                }
            }
        }
    }

    func captureSnapshot() -> UIImage? {
        guard bounds.size.width > 0 && bounds.size.height > 0 else {
            return nil
        }

        let reactChildren = subviews.filter { $0 !== childrenContainer && $0 !== outputView && $0 !== metalView }

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        for child in reactChildren {
            child.layer.render(in: context)
        }
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return snapshot
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView == outputView || hitView == metalView || hitView == self {
            return childrenContainer.hitTest(point, with: event)
        }

        return hitView
    }

    private func applyShaderAsync(to image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let device = metalDevice,
            let commandQueue = commandQueue,
            let shader = currentShader
        else {
            onShaderError(["code": "METAL_NOT_INITIALIZED", "message": "Metal or shader not initialized"])
            completion(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }

            guard let cgImage = image.cgImage else {
                completion(nil)
                return
            }

            let textureLoader = MTKTextureLoader(device: device)

            textureLoader.newTexture(cgImage: cgImage, options: nil) { inputTexture, error in
                guard let inputTexture = inputTexture else {
                    completion(nil)
                    return
                }

                let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
                    pixelFormat: .bgra8Unorm,
                    width: inputTexture.width,
                    height: inputTexture.height,
                    mipmapped: false
                )
                textureDescriptor.usage = [.renderTarget, .shaderRead]

                guard let outputTexture = device.makeTexture(descriptor: textureDescriptor) else {
                    completion(nil)
                    return
                }

                guard let pipeline = try? ShaderRegistry.shared.compiledPipeline(for: shader.name, device: device)
                else {
                    self.onShaderError(["code": "SHADER_COMPILE_FAILED", "message": "Failed to compile shader pipeline", "shaderName": shader.name])
                    completion(nil)
                    return
                }

                guard let commandBuffer = commandQueue.makeCommandBuffer() else {
                    completion(nil)
                    return
                }

                let renderPassDescriptor = MTLRenderPassDescriptor()
                renderPassDescriptor.colorAttachments[0].texture = outputTexture
                renderPassDescriptor.colorAttachments[0].loadAction = .clear
                renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
                renderPassDescriptor.colorAttachments[0].storeAction = .store

                guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                    completion(nil)
                    return
                }

                renderEncoder.setRenderPipelineState(pipeline)

                let params = self.parametersQueue.sync {
                    return self.shaderParameters
                }
                let context = ShaderContext(
                    inputTexture: inputTexture,
                    outputTexture: outputTexture,
                    parameters: params
                )

                shader.encode(encoder: renderEncoder, context: context)

                renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
                renderEncoder.endEncoding()

                commandBuffer.addCompletedHandler { _ in
                    let resultImage = self.textureToUIImage(texture: outputTexture)
                    completion(resultImage)
                }

                commandBuffer.commit()
            }
        }
    }

    func applyShader(to image: UIImage) -> UIImage? {
        guard let device = metalDevice,
            let commandQueue = commandQueue,
            let shader = currentShader
        else {
            let error = "Metal or shader not initialized"
            onShaderError(["code": "METAL_NOT_INITIALIZED", "message": error])
            return nil
        }

        let inputTexture: MTLTexture
        let isAnimated = shader.needsAnimation

        if isAnimated && cachedInputTexture != nil {
            inputTexture = cachedInputTexture!
        } else {
            guard let cgImage = image.cgImage else {
                return nil
            }

            let textureLoader = MTKTextureLoader(device: device)

            guard let newTexture = try? textureLoader.newTexture(cgImage: cgImage, options: nil) else {
                return nil
            }

            inputTexture = newTexture

            if isAnimated {
                cachedInputTexture = newTexture
            }
        }

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: inputTexture.width,
            height: inputTexture.height,
            mipmapped: false
        )
        textureDescriptor.usage = [.renderTarget, .shaderRead]

        guard let outputTexture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        guard let pipeline = try? ShaderRegistry.shared.compiledPipeline(for: shader.name, device: device)
        else {
            onShaderError(["code": "SHADER_COMPILE_FAILED", "message": "Failed to compile shader pipeline", "shaderName": shader.name])
            return nil
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return nil
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return nil
        }

        renderEncoder.setRenderPipelineState(pipeline)

        let params = parametersQueue.sync {
            return shaderParameters
        }
        let context = ShaderContext(
            inputTexture: inputTexture,
            outputTexture: outputTexture,
            parameters: params
        )

        shader.encode(encoder: renderEncoder, context: context)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return textureToUIImage(texture: outputTexture)
    }

    private func textureToUIImage(texture: MTLTexture) -> UIImage? {
        let width = texture.width
        let height = texture.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width

        var imageBytes = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let region = MTLRegionMake2D(0, 0, width, height)

        texture.getBytes(&imageBytes, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        let bitmapInfo =
            CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue

        guard
            let context = CGContext(
                data: &imageBytes,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ),
            let cgImage = context.makeImage()
        else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    func updateShaderEffect() {
        guard bounds.size.width > 0 && bounds.size.height > 0 else {
            return
        }

        guard currentShader != nil else {
            return
        }

        guard !isWaitingForInitialDelay else {
            return
        }

        let isAnimated = currentShader?.needsAnimation ?? false

        if isAnimated {
            renderAnimatedShader()
        } else {
            renderStaticShader()
        }
    }

    private func renderStaticShader() {
        guard let snapshot = captureSnapshot() else {
            return
        }

        parametersQueue.async(flags: .barrier) { [weak self] in
            self?.shaderParameters["time"] = self?.animationTime ?? 0.0
        }

        applyShaderAsync(to: snapshot) { [weak self] processedImage in
            guard let self = self else { return }

            if let processedImage = processedImage {
                DispatchQueue.main.async {
                    self.cachedStaticResult = processedImage
                    self.staticResultNeedsUpdate = false
                    self.outputView.image = processedImage
                    self.outputView.frame = self.bounds
                }
            }
        }
    }

    private func renderAnimatedShader() {
        if cachedInputTexture == nil {
            guard let snapshot = captureSnapshot() else {
                return
            }
            cachedSnapshot = snapshot

            guard let device = metalDevice,
                  let cgImage = snapshot.cgImage else {
                return
            }

            let textureLoader = MTKTextureLoader(device: device)
            guard let texture = try? textureLoader.newTexture(cgImage: cgImage, options: nil) else {
                return
            }

            cachedInputTexture = texture
        }

        metalView.setNeedsDisplay()
    }

    private func invalidateCache() {
        cachedSnapshot = nil
        cachedInputTexture = nil
        cachedOutputTexture = nil
        cachedStaticResult = nil
        staticResultNeedsUpdate = true
    }

    public func refreshSnapshot() {
        invalidateCache()
        if currentShader?.needsAnimation ?? false {
            updateShaderEffect()
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

        DebugConfig.log("Started shader animation")
    }

    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        displayLinkTarget = nil

        DebugConfig.log("Stopped shader animation")
    }

    @objc func updateAnimation() {
        guard let shader = currentShader, shader.needsAnimation else {
            return
        }

        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        animationTime += Float(deltaTime)

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

        if autoRefreshSnapshot && snapshotRefreshInterval > 0 {
            let timeSinceLastRefresh = currentTime - lastSnapshotRefreshTime
            if timeSinceLastRefresh >= snapshotRefreshInterval {
                invalidateCache()
                lastSnapshotRefreshTime = currentTime
            }
        }

        updateShaderEffect()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard let device = metalDevice,
              let commandQueue = commandQueue,
              let shader = currentShader,
              let drawable = view.currentDrawable,
              let inputTexture = cachedInputTexture else {
            return
        }

        let params = parametersQueue.sync {
            shaderParameters["time"] = animationTime
            return shaderParameters
        }

        guard let pipeline = try? ShaderRegistry.shared.compiledPipeline(for: shader.name, device: device) else {
            return
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderEncoder.setRenderPipelineState(pipeline)

        let context = ShaderContext(
            inputTexture: inputTexture,
            outputTexture: drawable.texture,
            parameters: params
        )

        shader.encode(encoder: renderEncoder, context: context)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
