package com.nativesprings.shaders

/**
 * Context passed to overlays during rendering
 */
data class OverlayContext(
    val outputTextureId: Int,
    val viewWidth: Int,
    val viewHeight: Int,
    val deltaTime: Double,
    val parameters: Map<String, Any>
)

/**
 * Interface that all overlays must implement
 */
interface Overlay {
    /**
     * Unique identifier for this overlay
     */
    val name: String

    /**
     * Parameters this overlay accepts
     */
    val parameters: List<ShaderParameter>

    /**
     * Whether this overlay requires continuous animation
     */
    val needsAnimation: Boolean

    /**
     * Compiles the overlay and returns a program ID
     * @return OpenGL program ID
     * @throws Exception if compilation fails
     */
    @Throws(Exception::class)
    fun compile(): Int

    /**
     * Updates the overlay's internal state (for animations)
     * @param deltaTime Time since last update in seconds
     */
    fun update(deltaTime: Double)

    /**
     * Sets up overlay uniforms and state before rendering
     * @param programId The compiled OpenGL program ID
     * @param context Rendering context with texture and parameters
     */
    fun encode(programId: Int, context: OverlayContext)
}
