package com.nativesprings.shaders

import android.opengl.GLES30

/**
 * Context passed to shaders during encoding
 */
data class ShaderContext(
    val inputTextureId: Int,
    val outputTextureId: Int,
    val width: Int,
    val height: Int,
    val parameters: Map<String, Any>
)

/**
 * Interface that all shaders must implement
 */
interface Shader {
    /**
     * Unique identifier for this shader
     */
    val name: String

    /**
     * Whether this shader requires continuous animation (default: false)
     */
    val needsAnimation: Boolean
        get() = false

    /**
     * Parameters this shader accepts
     */
    val parameters: List<ShaderParameter>

    /**
     * Compiles the shader and returns a program ID
     * @return OpenGL program ID
     * @throws Exception if compilation fails
     */
    @Throws(Exception::class)
    fun compile(): Int

    /**
     * Sets up shader uniforms and state before rendering
     * @param programId The compiled OpenGL program ID
     * @param context Rendering context with textures and parameters
     */
    fun encode(programId: Int, context: ShaderContext)
}
