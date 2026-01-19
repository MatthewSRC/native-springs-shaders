package com.nativesprings.shaders

import android.content.Context
import android.graphics.Bitmap
import android.graphics.SurfaceTexture
import android.opengl.GLES30
import android.util.Log
import android.view.TextureView
import java.nio.FloatBuffer
import java.util.concurrent.locks.ReentrantLock
import javax.microedition.khronos.egl.EGL10
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.egl.EGLContext
import javax.microedition.khronos.egl.EGLDisplay
import javax.microedition.khronos.egl.EGLSurface
import kotlin.concurrent.withLock

class GLTextureView(context: Context) : TextureView(context), TextureView.SurfaceTextureListener {

    private var renderThread: RenderThread? = null
    private val lock = ReentrantLock()

    private var surfaceWidth = 0
    private var surfaceHeight = 0
    private var surfaceReady = false

    private var currentShader: Shader? = null
    private var shaderParameters = mutableMapOf<String, Any>()
    private var inputTexture: Bitmap? = null
    private var needsRender = false

    var isAnimating = false
        set(value) {
            field = value
            renderThread?.isAnimating = value
            if (value) {
                renderThread?.requestRender()
            }
        }

    var onFirstFrameRendered: (() -> Unit)? = null
    private var firstFrameRendered = false

    init {
        surfaceTextureListener = this
        isOpaque = true
    }

    fun setShader(shader: Shader?) {
        lock.withLock {
            currentShader = shader
            needsRender = true
        }
        firstFrameRendered = false
    }

    fun setParameters(params: Map<String, Any>) {
        lock.withLock {
            shaderParameters.clear()
            shaderParameters.putAll(params)
        }
    }

    fun setInputTexture(bitmap: Bitmap?) {
        lock.withLock {
            inputTexture?.recycle()
            inputTexture = bitmap?.copy(bitmap.config ?: Bitmap.Config.ARGB_8888, false)
            needsRender = true
        }
        renderThread?.requestRender()
    }

    fun requestRender() {
        renderThread?.requestRender()
    }

    override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
        surfaceWidth = width
        surfaceHeight = height
        surfaceReady = true

        renderThread = RenderThread(surface).apply {
            start()
        }

        DebugConfig.log(TAG, "GLTextureView surface ready: ${width}x${height}")

        // Render immediately if state was set before surface was ready
        if (currentShader != null && inputTexture != null) {
            DebugConfig.log(TAG, "Surface ready with existing state, requesting render (animating=$isAnimating)")
            renderThread?.isAnimating = isAnimating
            if (isAnimating) {
                renderThread?.requestRender()
            }
        }
    }

    override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {
        surfaceWidth = width
        surfaceHeight = height
        renderThread?.onSurfaceChanged(width, height)

        DebugConfig.log(TAG, "GLTextureView size changed: ${width}x${height}")
    }

    override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
        surfaceReady = false
        renderThread?.shutdown()
        renderThread = null

        lock.withLock {
            inputTexture?.recycle()
            inputTexture = null
        }

        // GL context destruction invalidates cached program IDs
        ShaderRegistry.clearCache()

        DebugConfig.log(TAG, "GLTextureView surface destroyed, shader cache cleared")

        firstFrameRendered = false

        return true
    }

    override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {
    }

    private inner class RenderThread(private val surfaceTexture: SurfaceTexture) : Thread("GLRenderThread") {

        @Volatile
        var isRunning = true

        @Volatile
        var isAnimating = false

        @Volatile
        private var renderRequested = false

        private var egl: EGL10? = null
        private var eglDisplay: EGLDisplay? = null
        private var eglContext: EGLContext? = null
        private var eglSurface: EGLSurface? = null

        private var quadBuffer: FloatBuffer? = null
        private var inputTextureId: Int? = null
        private var lastAnimationTime: Long = 0

        fun requestRender() {
            renderRequested = true
        }

        fun onSurfaceChanged(width: Int, height: Int) {
        }

        fun shutdown() {
            isRunning = false
            isAnimating = false
            interrupt()
            try {
                join(2000)
            } catch (e: InterruptedException) {
                Log.w(TAG, "Render thread interrupted during shutdown")
            }
        }

        override fun run() {
            try {
                initEGL()
                initGL()

                lastAnimationTime = System.currentTimeMillis()

                var frameCount = 0
                var lastFrameTime = System.nanoTime()

                while (isRunning) {
                    try {
                        val frameStartTime = System.nanoTime()

                        if (isAnimating || renderRequested) {
                            renderRequested = false
                            renderFrame()
                            frameCount++
                        }

                        val frameTime = (System.nanoTime() - frameStartTime) / 1_000_000L
                        val targetFrameTime = 16L
                        val sleepTime = if (isAnimating || renderRequested) {
                            maxOf(0, targetFrameTime - frameTime)
                        } else {
                            targetFrameTime
                        }

                        if (sleepTime > 0) {
                            sleep(sleepTime)
                        }

                        lastFrameTime = System.nanoTime()

                    } catch (e: InterruptedException) {
                        DebugConfig.log(TAG, "Render thread interrupted")
                        break
                    }
                }

            } catch (e: Exception) {
                Log.e(TAG, "Render thread error: ${e.message}")
                e.printStackTrace()
            } finally {
                cleanup()
            }
        }

        private fun initEGL() {
            egl = javax.microedition.khronos.egl.EGLContext.getEGL() as EGL10
            eglDisplay = egl?.eglGetDisplay(EGL10.EGL_DEFAULT_DISPLAY)

            val version = IntArray(2)
            egl?.eglInitialize(eglDisplay, version)

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
            egl?.eglChooseConfig(eglDisplay, configAttribs, configs, 1, numConfigs)

            val contextAttribs = intArrayOf(
                0x3098, 3,
                EGL10.EGL_NONE
            )

            eglContext = egl?.eglCreateContext(
                eglDisplay,
                configs[0],
                EGL10.EGL_NO_CONTEXT,
                contextAttribs
            )

            eglSurface = egl?.eglCreateWindowSurface(
                eglDisplay,
                configs[0],
                surfaceTexture,
                null
            )

            egl?.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)

            DebugConfig.log(TAG, "EGL initialized")
        }

        private fun initGL() {
            quadBuffer = GLUtils.createOverlayQuadBuffer()

            GLES30.glEnable(GLES30.GL_BLEND)
            GLES30.glBlendFunc(GLES30.GL_SRC_ALPHA, GLES30.GL_ONE_MINUS_SRC_ALPHA)

            DebugConfig.log(TAG, "OpenGL initialized")
        }

        private fun renderFrame() {
            val shader: Shader?
            val params: Map<String, Any>
            val bitmap: Bitmap?
            val shouldUpdateTexture: Boolean
            val bitmapWidth: Int
            val bitmapHeight: Int

            // Capture state and dimensions under lock to avoid race conditions with recycled bitmaps
            lock.withLock {
                shader = currentShader
                params = HashMap(shaderParameters)
                bitmap = inputTexture
                shouldUpdateTexture = needsRender
                bitmapWidth = bitmap?.width ?: 0
                bitmapHeight = bitmap?.height ?: 0
            }

            if (shader == null || bitmap == null || bitmapWidth == 0 || bitmapHeight == 0) {
                GLES30.glClearColor(0f, 0f, 0f, 0f)
                GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
                egl?.eglSwapBuffers(eglDisplay, eglSurface)

                if (shader == null) {
                    DebugConfig.log(TAG, "No shader set, clearing to transparent")
                }
                if (bitmap == null) {
                    DebugConfig.log(TAG, "No input texture, clearing to transparent (shader=${shader?.name})")
                }
                if (bitmapWidth == 0 || bitmapHeight == 0) {
                    DebugConfig.log(TAG, "Invalid bitmap dimensions, clearing to transparent")
                }
                return
            }

            try {
                val currentTime = System.currentTimeMillis()
                val deltaTime = (currentTime - lastAnimationTime) / 1000.0f
                lastAnimationTime = currentTime

                val animationTime = params["time"] as? Float ?: 0f
                val newTime = if (isAnimating) animationTime + deltaTime else animationTime

                val updatedParams = params.toMutableMap().apply {
                    put("time", newTime)
                }

                if (inputTextureId == null || shouldUpdateTexture) {
                    inputTextureId?.let { GLUtils.deleteTexture(it) }
                    inputTextureId = GLUtils.createTextureFromBitmap(bitmap)

                    lock.withLock {
                        needsRender = false
                    }
                }

                val texId = inputTextureId ?: return

                val programId = try {
                    ShaderRegistry.compiledProgram(shader.name)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to compile shader ${shader.name}: ${e.message}")
                    GLES30.glClearColor(0f, 0f, 0f, 0f)
                    GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
                    egl?.eglSwapBuffers(eglDisplay, eglSurface)
                    return
                }

                if (programId == 0) {
                    Log.e(TAG, "Invalid shader program ID for ${shader.name}")
                    GLES30.glClearColor(0f, 0f, 0f, 0f)
                    GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
                    egl?.eglSwapBuffers(eglDisplay, eglSurface)
                    return
                }

                GLES30.glViewport(0, 0, surfaceWidth, surfaceHeight)
                GLES30.glClearColor(0f, 0f, 0f, 0f)
                GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
                GLES30.glUseProgram(programId)

                val shaderContext = ShaderContext(
                    inputTextureId = texId,
                    outputTextureId = 0,
                    width = bitmapWidth,
                    height = bitmapHeight,
                    parameters = updatedParams
                )

                shader.encode(programId, shaderContext)

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

                val error = GLES30.glGetError()
                if (error != GLES30.GL_NO_ERROR) {
                    Log.e(TAG, "OpenGL error after draw: $error")
                }

                egl?.eglSwapBuffers(eglDisplay, eglSurface)

                // First frame callback to hide children after shader renders
                if (!firstFrameRendered) {
                    firstFrameRendered = true
                    onFirstFrameRendered?.let { callback ->
                        this@GLTextureView.post(callback)
                    }
                }

            } catch (e: Exception) {
                Log.e(TAG, "Render error: ${e.message}")
                e.printStackTrace()
            }
        }

        private fun cleanup() {
            inputTextureId?.let { GLUtils.deleteTexture(it) }
            inputTextureId = null

            egl?.eglMakeCurrent(eglDisplay, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_CONTEXT)
            egl?.eglDestroySurface(eglDisplay, eglSurface)
            egl?.eglDestroyContext(eglDisplay, eglContext)
            egl?.eglTerminate(eglDisplay)

            DebugConfig.log(TAG, "Render thread cleaned up")
        }
    }

    companion object {
        private const val TAG = "GLTextureView"
    }
}
