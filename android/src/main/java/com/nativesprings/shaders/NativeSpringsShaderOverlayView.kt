package com.nativesprings.shaders

import android.content.Context
import android.graphics.PixelFormat
import android.opengl.GLSurfaceView
import android.util.Log
import android.view.Choreographer
import android.widget.FrameLayout
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.views.ExpoView
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import android.opengl.GLES30

class NativeSpringsShaderOverlayView(context: Context, appContext: AppContext) :
    ExpoView(context, appContext) {

    private val glSurfaceView: GLSurfaceView = GLSurfaceView(context)
    private val renderer: OverlayRenderer = OverlayRenderer()

    private var currentOverlay: Overlay? = null
    private val overlayParameters = mutableMapOf<String, Any>()

    private var choreographer: Choreographer? = null
    private var frameCallback: Choreographer.FrameCallback? = null
    private var lastFrameTime: Long = 0
    private var isAnimating = false

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

        glSurfaceView.requestRender()
    }

    fun setParameters(params: Map<String, Any>) {
        params.forEach { (key, value) ->
            setParameter(key, value)
        }
    }

    init {
        setupGLSurfaceView()
    }

    private fun setupGLSurfaceView() {
        glSurfaceView.setEGLContextClientVersion(3)
        glSurfaceView.setEGLConfigChooser(8, 8, 8, 8, 0, 0)
        glSurfaceView.holder.setFormat(PixelFormat.TRANSLUCENT)
        glSurfaceView.setZOrderOnTop(true)
        glSurfaceView.setRenderer(renderer)
        glSurfaceView.renderMode = GLSurfaceView.RENDERMODE_WHEN_DIRTY

        glSurfaceView.isEnabled = false

        addView(glSurfaceView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))

        DebugConfig.log(TAG, "GLSurfaceView initialized for overlay")
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

            renderer.setOverlay(currentOverlay)

            if (currentOverlay?.needsAnimation == true) {
                startAnimation()
            } else {
                stopAnimation()
            }

            glSurfaceView.requestRender()
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

                currentOverlay?.update(deltaTime)
                glSurfaceView.requestRender()

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

        glSurfaceView.layout(0, 0, width, height)
        renderer.updateViewSize(width, height)
    }

    override fun addView(child: android.view.View?, index: Int, params: android.view.ViewGroup.LayoutParams?) {
        super.addView(child, index, params)
        if (child != glSurfaceView) {
            glSurfaceView.bringToFront()
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        stopAnimation()
    }

    companion object {
        private const val TAG = "NativeSpringsShaderOverlayView"
    }

    private inner class OverlayRenderer : GLSurfaceView.Renderer {
        private var overlay: Overlay? = null
        private var quadBuffer: FloatBuffer? = null
        private var viewWidth = 0
        private var viewHeight = 0
        private val density: Float = context.resources.displayMetrics.density

        fun setOverlay(overlay: Overlay?) {
            this.overlay = overlay
        }

        fun updateViewSize(width: Int, height: Int) {
            viewWidth = width
            viewHeight = height
        }

        private var localProgramCache = mutableMapOf<String, Int>()

        override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
            GLES30.glClearColor(0f, 0f, 0f, 0f)

            GLES30.glEnable(GLES30.GL_BLEND)
            GLES30.glBlendFunc(GLES30.GL_SRC_ALPHA, GLES30.GL_ONE_MINUS_SRC_ALPHA)

            quadBuffer = com.nativesprings.shaders.GLUtils.createOverlayQuadBuffer()

            localProgramCache.clear()

            DebugConfig.log(TAG, "OpenGL surface created, local cache cleared")
        }

        override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
            GLES30.glViewport(0, 0, width, height)
            viewWidth = width
            viewHeight = height

            DebugConfig.log(TAG, "Surface size changed: ${width}x${height}")
        }

        override fun onDrawFrame(gl: GL10?) {
            GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)

            val currentOverlay = overlay ?: return

            try {
                val programId = OverlayRegistry.getOrCompile(currentOverlay.name, localProgramCache)
                if (programId == 0) return

                GLES30.glUseProgram(programId)

                val context = OverlayContext(
                    outputTextureId = 0,
                    viewWidth = (viewWidth / density).toInt(),
                    viewHeight = (viewHeight / density).toInt(),
                    deltaTime = 0.0,
                    parameters = overlayParameters
                )

                currentOverlay.encode(programId, context)

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

                DebugConfig.log(TAG, "Rendering overlay: ${currentOverlay.name}")

            } catch (e: Exception) {
                Log.e(TAG, "Error rendering overlay: ${e.message}")
                e.printStackTrace()
            }
        }
    }
}
