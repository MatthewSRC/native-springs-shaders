package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30
import java.util.concurrent.ConcurrentHashMap
import kotlin.math.max

class BlobOverlay(private val context: Context) : Overlay {
    override val name: String = "blob"

    override val parameters: List<ShaderParameter> = SPEC.shaderParameters

    override val needsAnimation: Boolean = true

    // Raymarching every native pixel is expensive and the glow stays soft at lower resolution
    override val renderScale: Float = 0.5f

    private val animators = ConversationalAnimators(SPEC)

    // Each view's GL context compiles its own program, so locations are cached per program.
    private val uniformLocations = ConcurrentHashMap<Int, IntArray>()

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.blob)
        return GLUtils.createProgram(vertexShader, fragmentShader)
    }

    // Time is tracked per view in encode()
    override fun update(deltaTime: Double) {}

    override fun releaseView(viewId: Int) {
        animators.release(viewId)
    }

    override fun encode(programId: Int, context: OverlayContext) {
        if (programId == 0) {
            android.util.Log.e(TAG, "Invalid program ID (0) - shader compilation likely failed")
            return
        }

        val loc = uniformLocations.getOrPut(programId) {
            IntArray(UNIFORMS.size) { GLES30.glGetUniformLocation(programId, UNIFORMS[it]) }
        }

        val f = animators.advance(context.viewId, context.parameters)
        val look = f.look

        GLES30.glUniform1f(loc[U_TIME], f.time)
        GLES30.glUniform1f(loc[U_INTENSITY], (context.parameters["intensity"] as? Number)?.toFloat() ?: 1.0f)
        GLES30.glUniform2f(loc[U_VIEW_SIZE], context.viewWidth.toFloat(), context.viewHeight.toFloat())
        GLES30.glUniform3f(loc[U_COLOR], f.colors[0], f.colors[1], f.colors[2])
        GLES30.glUniform3f(loc[U_SECONDARY_COLOR], f.colors[3], f.colors[4], f.colors[5])
        GLES30.glUniform1f(loc[U_SCALE], (context.parameters["scale"] as? Number)?.toFloat() ?: 1.0f)
        GLES30.glUniform1f(
            loc[U_RADIUS],
            max(
                look[RADIUS] + look[BREATH_AMOUNT] * f.breath + 0.06f * f.speak +
                    0.04f * f.flash + 0.1f * f.exhale + 0.08f * f.nudge,
                0.1f
            )
        )
        GLES30.glUniform1f(loc[U_THICKNESS], max(look[THICKNESS] + 0.35f * f.flash + 0.2f * f.exhale, 0.05f))
        GLES30.glUniform1f(loc[U_TWIST], max(look[TWIST] + 0.4f * f.speak + 0.5f * f.exhale, 0f))
        GLES30.glUniform1f(loc[U_IRIDESCENCE], look[IRIDESCENCE])
        GLES30.glUniform1f(loc[U_SHIMMER], look[SHIMMER])
        GLES30.glUniform1f(loc[U_SYMMETRY], look[SYMMETRY])
        GLES30.glUniform1f(loc[U_CORE], look[CORE])
        GLES30.glUniform1f(
            loc[U_BRIGHTNESS],
            max(
                look[BRIGHTNESS] * (1f + 1.2f * look[BREATH_AMOUNT] * f.breath) +
                    0.3f * f.speak + 0.5f * f.flash + 0.4f * f.exhale,
                0f
            )
        )
        GLES30.glUniform1f(loc[U_SATURATION], look[SATURATION])
        GLES30.glUniform1f(loc[U_RIPPLE_PROGRESS], f.rippleProgress)
        GLES30.glUniform1f(loc[U_RIPPLE_STRENGTH], if (f.rippleActive) 1f else 0f)
    }

    companion object {
        private const val TAG = "BlobOverlay"

        private const val RADIUS = 0
        private const val BREATH_AMOUNT = 1
        private const val BREATH_PERIOD = 2
        private const val THICKNESS = 3
        private const val TWIST = 4
        private const val IRIDESCENCE = 5
        private const val SHIMMER = 6
        private const val SYMMETRY = 7
        private const val CORE = 8
        private const val BRIGHTNESS = 9
        private const val SATURATION = 10
        private const val MOTION = 11
        private const val SPEAKING = 12

        /** Look targets resolved in src/utils/blobLook.ts, with idle defaults. */
        private val SPEC = ConversationalLookSpec(
            keys = arrayOf(
                "radius", "breathAmount", "breathPeriod", "thickness", "twist",
                "iridescence", "shimmer", "symmetry", "core", "brightness",
                "saturation", "motion", "speaking"
            ),
            defaults = floatArrayOf(
                1.5f, 0.06f, 5.0f, 1.0f, 2.0f,
                0.15f, 0.0f, 0.0f, 0.0f, 1.0f,
                1.0f, 0.6f, 0.0f
            ),
            defaultColor = floatArrayOf(0.4f, 0.6f, 1.0f),
            defaultSecondaryColor = floatArrayOf(0.9f, 0.4f, 0.8f),
            motionIndex = MOTION,
            breathPeriodIndex = BREATH_PERIOD,
            speakingIndex = SPEAKING,
            // Arrive by growing out of a small, dark seed
            arrival = mapOf(RADIUS to 0.6f, BRIGHTNESS to 0f)
        )

        private val UNIFORMS = arrayOf(
            "time", "intensity", "viewSize", "color", "secondaryColor", "scale",
            "radius", "thickness", "twist", "iridescence", "shimmer", "symmetry",
            "core", "brightness", "saturation", "rippleProgress", "rippleStrength"
        )

        private const val U_TIME = 0
        private const val U_INTENSITY = 1
        private const val U_VIEW_SIZE = 2
        private const val U_COLOR = 3
        private const val U_SECONDARY_COLOR = 4
        private const val U_SCALE = 5
        private const val U_RADIUS = 6
        private const val U_THICKNESS = 7
        private const val U_TWIST = 8
        private const val U_IRIDESCENCE = 9
        private const val U_SHIMMER = 10
        private const val U_SYMMETRY = 11
        private const val U_CORE = 12
        private const val U_BRIGHTNESS = 13
        private const val U_SATURATION = 14
        private const val U_RIPPLE_PROGRESS = 15
        private const val U_RIPPLE_STRENGTH = 16
    }
}
