package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class SparklesOverlay(private val context: Context) : Overlay {
    override val name: String = "sparkles"

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("density", ShaderParameterType.FLOAT, 3.0f),
        ShaderParameter("size", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("speed", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("color", ShaderParameterType.FLOAT3, listOf(1.0f, 1.0f, 1.0f)),
        ShaderParameter("colorize", ShaderParameterType.BOOL, true),
        ShaderParameter("twinkleSpeed", ShaderParameterType.FLOAT, 0.5f),
        ShaderParameter("brightnessMultiplier", ShaderParameterType.FLOAT, 2.5f)
    )

    override val needsAnimation: Boolean = true

    private var time: Float = 0.0f

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.sparkles)
        return GLUtils.createProgram(vertexShader, fragmentShader)
    }

    override fun update(deltaTime: Double) {
        time += deltaTime.toFloat()
    }

    override fun encode(programId: Int, context: OverlayContext) {
        val timeLoc = GLES30.glGetUniformLocation(programId, "time")
        GLES30.glUniform1f(timeLoc, time)

        val intensity = (context.parameters["intensity"] as? Float) ?: 1.0f
        val intensityLoc = GLES30.glGetUniformLocation(programId, "intensity")
        GLES30.glUniform1f(intensityLoc, intensity)

        val viewSizeLoc = GLES30.glGetUniformLocation(programId, "viewSize")
        GLES30.glUniform2f(viewSizeLoc, context.viewWidth.toFloat(), context.viewHeight.toFloat())

        val density = (context.parameters["density"] as? Float) ?: 3.0f
        val densityLoc = GLES30.glGetUniformLocation(programId, "density")
        GLES30.glUniform1f(densityLoc, density)

        val size = (context.parameters["size"] as? Float) ?: 1.0f
        val sizeLoc = GLES30.glGetUniformLocation(programId, "size")
        GLES30.glUniform1f(sizeLoc, size)

        val speed = (context.parameters["speed"] as? Float) ?: 1.0f
        val speedLoc = GLES30.glGetUniformLocation(programId, "speed")
        GLES30.glUniform1f(speedLoc, speed)

        val color = context.parameters.extractFloat3("color", "colorR", "colorG", "colorB", floatArrayOf(1.0f, 1.0f, 1.0f))
        val colorLoc = GLES30.glGetUniformLocation(programId, "color")
        GLES30.glUniform3f(colorLoc, color[0], color[1], color[2])

        val colorizeBool = (context.parameters["colorize"] as? Boolean) ?: true
        val colorize = if (colorizeBool) 1.0f else 0.0f
        val colorizeLoc = GLES30.glGetUniformLocation(programId, "colorize")
        GLES30.glUniform1f(colorizeLoc, colorize)

        val twinkleSpeed = (context.parameters["twinkleSpeed"] as? Float) ?: 0.5f
        val twinkleSpeedLoc = GLES30.glGetUniformLocation(programId, "u_TwinkleSpeed")
        GLES30.glUniform1f(twinkleSpeedLoc, twinkleSpeed)

        val brightnessMultiplier = (context.parameters["brightnessMultiplier"] as? Float) ?: 2.5f
        val brightnessMultiplierLoc = GLES30.glGetUniformLocation(programId, "u_BrightnessMultiplier")
        GLES30.glUniform1f(brightnessMultiplierLoc, brightnessMultiplier)
    }

    companion object {
        private const val TAG = "SparklesOverlay"
    }
}
