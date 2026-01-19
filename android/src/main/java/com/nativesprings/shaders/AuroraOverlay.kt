package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class AuroraOverlay(private val context: Context) : Overlay {
    override val name: String = "aurora"

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("direction", ShaderParameterType.FLOAT2, listOf(0.0f, 1.0f)),
        ShaderParameter("color", ShaderParameterType.FLOAT3, listOf(0.6f, 0.8f, 1.0f)),
        ShaderParameter("borderFade", ShaderParameterType.FLOAT, 0.0f)
    )

    override val needsAnimation: Boolean = true

    private var time: Float = 0.0f

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.aurora)
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

        val direction = context.parameters.extractFloat2("direction", "directionX", "directionY", floatArrayOf(0.0f, 1.0f))
        val movementDirectionLoc = GLES30.glGetUniformLocation(programId, "movementDirection")
        GLES30.glUniform2f(movementDirectionLoc, direction[0], direction[1])

        val color = context.parameters.extractFloat3("color", "colorR", "colorG", "colorB", floatArrayOf(0.6f, 0.8f, 1.0f))
        val colorTintLoc = GLES30.glGetUniformLocation(programId, "colorTint")
        GLES30.glUniform3f(colorTintLoc, color[0], color[1], color[2])

        val borderFade = (context.parameters["borderFade"] as? Float) ?: 1.0f
        val borderFadeLoc = GLES30.glGetUniformLocation(programId, "borderFade")
        GLES30.glUniform1f(borderFadeLoc, borderFade)
    }

    companion object {
        private const val TAG = "AuroraOverlay"
    }
}
