package com.nativesprings.shaders

import android.graphics.Bitmap
import android.opengl.GLES30
import android.opengl.GLUtils
import android.util.Log
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

object GLUtils {
    private const val TAG = "GLUtils"

    private val SHADER_QUAD_VERTICES = floatArrayOf(
        -1.0f, -1.0f,         0.0f, 0.0f,
         1.0f, -1.0f,         1.0f, 0.0f,
        -1.0f,  1.0f,         0.0f, 1.0f,
        -1.0f,  1.0f,         0.0f, 1.0f,
         1.0f, -1.0f,         1.0f, 0.0f,
         1.0f,  1.0f,         1.0f, 1.0f
    )

    private val OVERLAY_QUAD_VERTICES = floatArrayOf(
        -1.0f, -1.0f,         0.0f, 1.0f,
         1.0f, -1.0f,         1.0f, 1.0f,
        -1.0f,  1.0f,         0.0f, 0.0f,
        -1.0f,  1.0f,         0.0f, 0.0f,
         1.0f, -1.0f,         1.0f, 1.0f,
         1.0f,  1.0f,         1.0f, 0.0f
    )

    fun createQuadBuffer(): FloatBuffer {
        return ByteBuffer.allocateDirect(SHADER_QUAD_VERTICES.size * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer()
            .put(SHADER_QUAD_VERTICES)
            .apply { position(0) }
    }

    fun createOverlayQuadBuffer(): FloatBuffer {
        return ByteBuffer.allocateDirect(OVERLAY_QUAD_VERTICES.size * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer()
            .put(OVERLAY_QUAD_VERTICES)
            .apply { position(0) }
    }

    fun compileShader(type: Int, source: String): Int {
        val shader = GLES30.glCreateShader(type)
        if (shader == 0) {
            Log.e(TAG, "Failed to create shader")
            return 0
        }

        GLES30.glShaderSource(shader, source)
        GLES30.glCompileShader(shader)

        val compiled = IntArray(1)
        GLES30.glGetShaderiv(shader, GLES30.GL_COMPILE_STATUS, compiled, 0)

        if (compiled[0] == 0) {
            val info = GLES30.glGetShaderInfoLog(shader)
            Log.e(TAG, "Shader compilation failed: $info")
            Log.e(TAG, "Source:\n$source")
            GLES30.glDeleteShader(shader)
            return 0
        }

        return shader
    }

    fun linkProgram(vertexShaderId: Int, fragmentShaderId: Int): Int {
        val program = GLES30.glCreateProgram()
        if (program == 0) {
            Log.e(TAG, "Failed to create program")
            return 0
        }

        GLES30.glAttachShader(program, vertexShaderId)
        GLES30.glAttachShader(program, fragmentShaderId)
        GLES30.glLinkProgram(program)

        val linked = IntArray(1)
        GLES30.glGetProgramiv(program, GLES30.GL_LINK_STATUS, linked, 0)

        if (linked[0] == 0) {
            val info = GLES30.glGetProgramInfoLog(program)
            Log.e(TAG, "Program linking failed: $info")
            GLES30.glDeleteProgram(program)
            return 0
        }

        return program
    }

    @Throws(Exception::class)
    fun createProgram(vertexSource: String, fragmentSource: String): Int {
        val vertexShader = compileShader(GLES30.GL_VERTEX_SHADER, vertexSource)
        if (vertexShader == 0) {
            throw Exception("Failed to compile vertex shader")
        }

        val fragmentShader = compileShader(GLES30.GL_FRAGMENT_SHADER, fragmentSource)
        if (fragmentShader == 0) {
            GLES30.glDeleteShader(vertexShader)
            throw Exception("Failed to compile fragment shader")
        }

        val program = linkProgram(vertexShader, fragmentShader)

        GLES30.glDeleteShader(vertexShader)
        GLES30.glDeleteShader(fragmentShader)

        if (program == 0) {
            throw Exception("Failed to link program")
        }

        return program
    }

    fun createTexture(width: Int, height: Int): Int {
        val textures = IntArray(1)
        GLES30.glGenTextures(1, textures, 0)
        val textureId = textures[0]

        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, textureId)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_S, GLES30.GL_CLAMP_TO_EDGE)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE)

        GLES30.glTexImage2D(
            GLES30.GL_TEXTURE_2D,
            0,
            GLES30.GL_RGBA,
            width,
            height,
            0,
            GLES30.GL_RGBA,
            GLES30.GL_UNSIGNED_BYTE,
            null
        )

        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, 0)

        return textureId
    }

    fun createTextureFromBitmap(bitmap: Bitmap): Int {
        val textures = IntArray(1)
        GLES30.glGenTextures(1, textures, 0)
        val textureId = textures[0]

        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, textureId)

        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR_MIPMAP_LINEAR)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_S, GLES30.GL_CLAMP_TO_EDGE)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE)

        GLUtils.texImage2D(GLES30.GL_TEXTURE_2D, 0, bitmap, 0)
        GLES30.glGenerateMipmap(GLES30.GL_TEXTURE_2D)
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, 0)

        return textureId
    }

    fun textureToBitmap(textureId: Int, width: Int, height: Int, framebufferId: Int = 0): Bitmap {
        val buffer = ByteBuffer.allocateDirect(width * height * 4)
        buffer.order(ByteOrder.nativeOrder())

        val tempFbo = if (framebufferId == 0) {
            val fbos = IntArray(1)
            GLES30.glGenFramebuffers(1, fbos, 0)
            GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, fbos[0])
            GLES30.glFramebufferTexture2D(
                GLES30.GL_FRAMEBUFFER,
                GLES30.GL_COLOR_ATTACHMENT0,
                GLES30.GL_TEXTURE_2D,
                textureId,
                0
            )
            fbos[0]
        } else {
            GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, framebufferId)
            0
        }

        GLES30.glReadPixels(0, 0, width, height, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, buffer)

        if (tempFbo != 0) {
            GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, 0)
            GLES30.glDeleteFramebuffers(1, intArrayOf(tempFbo), 0)
        }

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        buffer.rewind()
        bitmap.copyPixelsFromBuffer(buffer)

        return bitmap
    }

    fun createFramebuffer(): Int {
        val framebuffers = IntArray(1)
        GLES30.glGenFramebuffers(1, framebuffers, 0)
        return framebuffers[0]
    }

    fun deleteTexture(textureId: Int) {
        GLES30.glDeleteTextures(1, intArrayOf(textureId), 0)
    }

    fun deleteFramebuffer(framebufferId: Int) {
        GLES30.glDeleteFramebuffers(1, intArrayOf(framebufferId), 0)
    }

    fun deleteProgram(programId: Int) {
        GLES30.glDeleteProgram(programId)
    }

    fun checkGLError(tag: String, operation: String) {
        val error = GLES30.glGetError()
        if (error != GLES30.GL_NO_ERROR) {
            Log.e(tag, "GL error after $operation: $error")
        }
    }

    fun loadShaderFromResource(context: android.content.Context, resourceId: Int): String {
        val inputStream = context.resources.openRawResource(resourceId)
        return java.io.BufferedReader(java.io.InputStreamReader(inputStream)).use { it.readText() }
    }
}
