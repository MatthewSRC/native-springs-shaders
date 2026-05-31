package com.nativesprings.shaders

import android.content.Context
import android.graphics.SurfaceTexture
import android.opengl.GLES30
import android.util.Log
import android.view.Choreographer
import android.view.TextureView
import android.widget.FrameLayout
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.views.ExpoView
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGL10
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.egl.EGLContext
import javax.microedition.khronos.egl.EGLDisplay
import javax.microedition.khronos.egl.EGLSurface

class NativeSpringsShaderOverlayView(context: Context, appContext: AppContext) :
    ExpoView(context, appContext) {

    private val overlayTextureView: OverlayTextureView = OverlayTextureView(context)

    private var currentOverlay: Overlay? = null
    private val overlayParameters = mutableMapOf<String, Any>()

    private var choreographer: Choreographer? = null
    private var frameCallback: Choreographer.FrameCallback? = null
    private var lastFrameTime: Long = 0
    private var isAnimating = false

    /**
     * When true, all views sharing the same overlay name advance the animation
     * clock only once per vsync frame, keeping every instance in perfect sync
     * regardless of how many screens or tabs have the overlay mounted.
     */
    var isUnique: Boolean = false

    var overlayName: String? = null
        set(value) {
            field = value
            loadOverlay()
        }

    fun setParameter(name: String, value: Any) {
        val convertedValue = when (value) {
            is Number -> value.toFloat()
            is Boolean -> value
            is String -> value
            else -> value
        }

        overlayParameters[name] = convertedValue
        overlayTextureView.requestRender()
    }

    fun setParameters(params: Map<String, Any>) {
        params.forEach { (key, value) ->
            setParameter(key, value)
        }
    }

    init {
        setupOverlayTextureView()
    }

    private fun setupOverlayTextureView() {
        // TextureView participates in the normal View hierarchy so z-index is respected,
        // unlike GLSurfaceView which composites in a separate surface layer.
        addView(overlayTextureView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))

        DebugConfig.log(TAG, "OverlayTextureView initialized")
    }

    private fun loadOverlay() {
        DebugConfig.log(TAG, "loadOverlay() called")

        val name = overlayName ?: run {
            currentOverlay = null
            stopAnimation()
            return
        }

        DebugConfig.log(TAG, "Looking for overlay: $name")

        currentOverlay = OverlayRegistry.get(name)

        if (currentOverlay != null) {
            DebugConfig.log(TAG, "Loaded overlay: $name")
            DebugConfig.log(TAG, "needsAnimation: ${currentOverlay?.needsAnimation}")

            currentOverlay?.parameters?.forEach { param ->
                if (!overlayParameters.containsKey(param.name)) {
                    param.defaultValue?.let { defaultValue ->
                        overlayParameters[param.name] = defaultValue
                        DebugConfig.log(TAG, "Initialized ${param.name} = $defaultValue")
                    }
                }
            }

            overlayTextureView.setOverlay(currentOverlay)

            if (currentOverlay?.needsAnimation == true) {
                startAnimation()
            } else {
                stopAnimation()
            }

            overlayTextureView.requestRender()
        } else {
            Log.w(TAG, "Overlay '$name' not found in registry")
            Log.w(TAG, "Available overlays: ${OverlayRegistry.registeredOverlays}")
        }
    }

    private fun startAnimation() {
        if (isAnimating) return

        isAnimating = true
        lastFrameTime = System.nanoTime()

        choreographer = Choreographer.getInstance()
        frameCallback = object : Choreographer.FrameCallback {
            override fun doFrame(frameTimeNanos: Long) {
                if (!isAnimating) return

                val deltaTime = (frameTimeNanos - lastFrameTime) / 1_000_000_000.0
                lastFrameTime = frameTimeNanos

                val overlay = currentOverlay
                if (overlay != null) {
                    if (isUnique) {
                        // Only advance time once per vsync frame across all unique-mode
                        // views for this overlay. Choreographer guarantees that
                        // frameTimeNanos is identical for all callbacks in the same frame.
                        val overlayName = overlay.name
                        if (lastSharedFrameTimes[overlayName] != frameTimeNanos) {
                            lastSharedFrameTimes[overlayName] = frameTimeNanos
                            overlay.update(deltaTime)
                        }
                    } else {
                        overlay.update(deltaTime)
                    }
                }

                overlayTextureView.requestRender()

                choreographer?.postFrameCallback(this)
            }
        }

        choreographer?.postFrameCallback(frameCallback!!)

        DebugConfig.log(TAG, "Started overlay animation")
    }

    private fun stopAnimation() {
        if (!isAnimating) return

        isAnimating = false
        frameCallback?.let { choreographer?.removeFrameCallback(it) }
        frameCallback = null

        DebugConfig.log(TAG, "Stopped overlay animation")
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)

        val width = right - left
        val height = bottom - top

        overlayTextureView.layout(0, 0, width, height)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stopAnimation()
    }

    companion object {
        private const val TAG = "NativeSpringsShaderOverlayView"

        // Per-overlay-name last-seen frame timestamp for unique-mode deduplication.
        // Choreographer callbacks run on the main thread so no synchronization needed.
        private val lastSharedFrameTimes = mutableMapOf<String, Long>()
    }

    private inner class OverlayTextureView(context: Context) :
        TextureView(context), TextureView.SurfaceTextureListener {

        private var renderThread: RenderThread? = null

        @Volatile
        private var pendingRender = false

        init {
            isOpaque = false
            isClickable = false
            isFocusable = false
            surfaceTextureListener = this
        }

        fun setOverlay(overlay: Overlay?) {
            renderThread?.setOverlay(overlay)
        }

        fun requestRender() {
            val thread = renderThread
            if (thread != null) {
                thread.requestRender()
            } else {
                pendingRender = true
            }
        }

        override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
            val thread = RenderThread(surface, width, height)
            renderThread = thread
            currentOverlay?.let { thread.setOverlay(it) }
            thread.start()
            if (pendingRender) {
                pendingRender = false
                thread.requestRender()
            }
            DebugConfig.log(TAG, "OverlayTextureView surface available: ${width}x${height}")
        }

        override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {
            renderThread?.onSurfaceChanged(width, height)
        }

        override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
            renderThread?.shutdown()
            renderThread = null
            DebugConfig.log(TAG, "OverlayTextureView surface destroyed")
            return true
        }

        override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {}

        private inner class RenderThread(
            private val surfaceTexture: SurfaceTexture,
            @Volatile private var viewWidth: Int,
            @Volatile private var viewHeight: Int
        ) : Thread("OverlayRenderThread") {

            @Volatile var isRunning = true
            @Volatile private var renderRequested = false
            @Volatile private var overlay: Overlay? = null

            private var egl: EGL10? = null
            private var eglDisplay: EGLDisplay? = null
            private var eglContext: EGLContext? = null
            private var eglSurface: EGLSurface? = null
            private var quadBuffer: FloatBuffer? = null
            private val localProgramCache = mutableMapOf<String, Int>()
            private val density: Float = context.resources.displayMetrics.density

            fun setOverlay(o: Overlay?) {
                overlay = o
            }

            fun requestRender() {
                renderRequested = true
            }

            fun onSurfaceChanged(w: Int, h: Int) {
                viewWidth = w
                viewHeight = h
            }

            fun shutdown() {
                isRunning = false
                interrupt()
                try {
                    join(2000)
                } catch (_: InterruptedException) {}
            }

            override fun run() {
                try {
                    initEGL()
                    initGL()

                    while (isRunning) {
                        try {
                            if (renderRequested) {
                                renderRequested = false
                                renderFrame()
                            }
                            sleep(8)
                        } catch (_: InterruptedException) {
                            break
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Overlay render thread error: ${e.message}")
                    e.printStackTrace()
                } finally {
                    cleanup()
                }
            }

            private fun initEGL() {
                egl = javax.microedition.khronos.egl.EGLContext.getEGL() as EGL10
                eglDisplay = egl!!.eglGetDisplay(EGL10.EGL_DEFAULT_DISPLAY)

                val version = IntArray(2)
                egl!!.eglInitialize(eglDisplay, version)

                val configAttribs = intArrayOf(
                    EGL10.EGL_RENDERABLE_TYPE, 4,
                    EGL10.EGL_RED_SIZE, 8,
                    EGL10.EGL_GREEN_SIZE, 8,
                    EGL10.EGL_BLUE_SIZE, 8,
                    EGL10.EGL_ALPHA_SIZE, 8,
                    EGL10.EGL_DEPTH_SIZE, 0,
                    EGL10.EGL_STENCIL_SIZE, 0,
                    EGL10.EGL_NONE
                )

                val configs = arrayOfNulls<EGLConfig>(1)
                val numConfigs = IntArray(1)
                egl!!.eglChooseConfig(eglDisplay, configAttribs, configs, 1, numConfigs)

                val contextAttribs = intArrayOf(0x3098, 3, EGL10.EGL_NONE) // GLES 3

                eglContext = egl!!.eglCreateContext(
                    eglDisplay, configs[0], EGL10.EGL_NO_CONTEXT, contextAttribs
                )
                eglSurface = egl!!.eglCreateWindowSurface(
                    eglDisplay, configs[0], surfaceTexture, null
                )
                egl!!.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)

                DebugConfig.log(TAG, "EGL initialized for overlay")
            }

            private fun initGL() {
                quadBuffer = GLUtils.createOverlayQuadBuffer()

                GLES30.glEnable(GLES30.GL_BLEND)
                // RGB: standard straight-alpha blend → framebuffer stores col*alpha
                // Alpha: write srcAlpha as-is (not srcAlpha²) so SurfaceFlinger composites correctly
                GLES30.glBlendFuncSeparate(
                    GLES30.GL_SRC_ALPHA, GLES30.GL_ONE_MINUS_SRC_ALPHA,
                    GLES30.GL_ONE,       GLES30.GL_ZERO
                )

                DebugConfig.log(TAG, "OpenGL initialized for overlay")
            }

            private fun renderFrame() {
                val currentOverlay = overlay ?: run {
                    GLES30.glClearColor(0f, 0f, 0f, 0f)
                    GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
                    egl?.eglSwapBuffers(eglDisplay, eglSurface)
                    return
                }

                try {
                    val programId = OverlayRegistry.getOrCompile(currentOverlay.name, localProgramCache)
                    if (programId == 0) return

                    GLES30.glViewport(0, 0, viewWidth, viewHeight)
                    GLES30.glClearColor(0f, 0f, 0f, 0f)
                    GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
                    GLES30.glUseProgram(programId)

                    val overlayCtx = OverlayContext(
                        outputTextureId = 0,
                        viewWidth = (viewWidth / density).toInt(),
                        viewHeight = (viewHeight / density).toInt(),
                        deltaTime = 0.0,
                        parameters = overlayParameters
                    )

                    currentOverlay.encode(programId, overlayCtx)

                    val buffer = quadBuffer ?: return
                    buffer.position(0)
                    val stride = 4 * 4

                    GLES30.glEnableVertexAttribArray(0)
                    GLES30.glVertexAttribPointer(0, 2, GLES30.GL_FLOAT, false, stride, buffer)

                    buffer.position(2)
                    GLES30.glEnableVertexAttribArray(1)
                    GLES30.glVertexAttribPointer(1, 2, GLES30.GL_FLOAT, false, stride, buffer)

                    GLES30.glDrawArrays(GLES30.GL_TRIANGLES, 0, 6)

                    GLES30.glDisableVertexAttribArray(0)
                    GLES30.glDisableVertexAttribArray(1)

                    egl?.eglSwapBuffers(eglDisplay, eglSurface)

                    DebugConfig.log(TAG, "Rendered overlay: ${currentOverlay.name}")

                } catch (e: Exception) {
                    Log.e(TAG, "Error rendering overlay: ${e.message}")
                    e.printStackTrace()
                }
            }

            private fun cleanup() {
                localProgramCache.clear()
                egl?.run {
                    eglMakeCurrent(eglDisplay, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_CONTEXT)
                    eglDestroySurface(eglDisplay, eglSurface)
                    eglDestroyContext(eglDisplay, eglContext)
                    eglTerminate(eglDisplay)
                }
                DebugConfig.log(TAG, "Overlay render thread cleaned up")
            }
        }
    }
}
