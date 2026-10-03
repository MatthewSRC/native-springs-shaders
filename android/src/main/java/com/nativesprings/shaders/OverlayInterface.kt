package com.nativesprings.shaders

/**
 * Context passed to overlays during rendering
 */
data class OverlayContext(
    val outputTextureId: Int,
    val viewWidth: Int,
    val viewHeight: Int,
    val deltaTime: Double,
    val parameters: Map<String, Any>,
    /** Identifies the view being rendered, for overlays that keep per-view state */
    val viewId: Int = 0
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
     * Render resolution as a fraction of the screen's pixel density.
     * Views can override it with a `renderScale` parameter.
     */
    val renderScale: Float
        get() = 1f

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

    /**
     * Called when a view using this overlay releases its surface, so per-view state can be dropped
     * @param viewId The id passed as OverlayContext.viewId
     */
    fun releaseView(viewId: Int) {}
}
