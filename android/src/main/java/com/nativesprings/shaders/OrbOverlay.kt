package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30
import java.util.concurrent.ConcurrentHashMap
import kotlin.math.max

class OrbOverlay(private val context: Context) : Overlay {
    override val name: String = "orb"

    override val parameters: List<ShaderParameter> = SPEC.shaderParameters

    override val needsAnimation: Boolean = true

    // Soft glow holds up well below native resolution
    override val renderScale: Float = 0.75f

    private val animators = ConversationalAnimators(SPEC)

    // Each view's GL context compiles its own program, so locations are cached per program.
    private val uniformLocations = ConcurrentHashMap<Int, IntArray>()

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.orb)
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
            look[RADIUS] + look[BREATH_AMOUNT] * f.breath + 0.012f * f.speak +
                0.008f * f.flash + 0.025f * f.exhale + 0.02f * f.nudge
        )
        GLES30.glUniform1f(loc[U_THICKNESS], max(look[THICKNESS] + 0.25f * f.flash - 0.15f * f.exhale, 0.1f))
        GLES30.glUniform1f(loc[U_DISPERSION], look[DISPERSION] + 0.3f * f.speak)
        GLES30.glUniform1f(loc[U_SPREAD], look[SPREAD] - 6f * f.exhale)
        GLES30.glUniform1f(loc[U_TURBULENCE], look[TURBULENCE])
        GLES30.glUniform1f(loc[U_CHROMATIC], look[CHROMATIC])
        GLES30.glUniform1f(loc[U_SHIMMER], look[SHIMMER])
        GLES30.glUniform1f(loc[U_SYMMETRY], look[SYMMETRY])
        GLES30.glUniform1f(loc[U_CORE], look[CORE])
        GLES30.glUniform1f(
            loc[U_BRIGHTNESS],
            max(
                look[BRIGHTNESS] * (1f + 4f * look[BREATH_AMOUNT] * f.breath) +
                    0.35f * f.speak + 0.55f * f.flash + 0.45f * f.exhale,
                0f
            )
        )
        GLES30.glUniform1f(loc[U_SATURATION], look[SATURATION])
        GLES30.glUniform1f(loc[U_RIPPLE_PROGRESS], f.rippleProgress)
        GLES30.glUniform1f(loc[U_RIPPLE_STRENGTH], if (f.rippleActive) 1f else 0f)
    }

    companion object {
        private const val TAG = "OrbOverlay"

        private const val RADIUS = 0
        private const val BREATH_AMOUNT = 1
        private const val BREATH_PERIOD = 2
        private const val THICKNESS = 3
        private const val DISPERSION = 4
        private const val SPREAD = 5
        private const val TURBULENCE = 6
        private const val CHROMATIC = 7
        private const val SHIMMER = 8
        private const val SYMMETRY = 9
        private const val CORE = 10
        private const val BRIGHTNESS = 11
        private const val SATURATION = 12
        private const val MOTION = 13
        private const val SPEAKING = 14

        /** Look targets resolved in src/utils/orbLook.ts, with idle defaults. */
        private val SPEC = ConversationalLookSpec(
            keys = arrayOf(
                "radius", "breathAmount", "breathPeriod", "thickness", "dispersion",
                "spread", "turbulence", "chromatic", "shimmer", "symmetry",
                "core", "brightness", "saturation", "motion", "speaking"
            ),
            defaults = floatArrayOf(
                0.23f, 0.012f, 5.0f, 1.0f, 1.0f,
                14.0f, 0.15f, 1.0f, 0.0f, 0.0f,
                0.0f, 1.0f, 1.0f, 0.6f, 0.0f
            ),
            defaultColor = floatArrayOf(1.0f, 0.8f, 0.4f),
            defaultSecondaryColor = floatArrayOf(0.75f, 0.8f, 0.4f),
            motionIndex = MOTION,
            breathPeriodIndex = BREATH_PERIOD,
            speakingIndex = SPEAKING,
            // Arrive by zooming in and fading up from darkness
            arrival = mapOf(RADIUS to 0.83f, BRIGHTNESS to 0f)
        )

        private val UNIFORMS = arrayOf(
            "time", "intensity", "viewSize", "color", "secondaryColor", "scale",
            "radius", "thickness", "dispersion", "spread", "turbulence", "chromatic",
            "shimmer", "symmetry", "core", "brightness", "saturation",
            "rippleProgress", "rippleStrength"
        )

        private const val U_TIME = 0
        private const val U_INTENSITY = 1
        private const val U_VIEW_SIZE = 2
        private const val U_COLOR = 3
        private const val U_SECONDARY_COLOR = 4
        private const val U_SCALE = 5
        private const val U_RADIUS = 6
        private const val U_THICKNESS = 7
        private const val U_DISPERSION = 8
        private const val U_SPREAD = 9
        private const val U_TURBULENCE = 10
        private const val U_CHROMATIC = 11
        private const val U_SHIMMER = 12
        private const val U_SYMMETRY = 13
        private const val U_CORE = 14
        private const val U_BRIGHTNESS = 15
        private const val U_SATURATION = 16
        private const val U_RIPPLE_PROGRESS = 17
        private const val U_RIPPLE_STRENGTH = 18
    }
}
