package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class CloudsOverlay(private val context: Context) : Overlay {
    override val name: String = "clouds"

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 0.6f),
        ShaderParameter("color", ShaderParameterType.FLOAT3, listOf(0.15f, 0.2f, 0.55f)),
        ShaderParameter("secondaryColor", ShaderParameterType.FLOAT3, listOf(0.25f, 0.15f, 0.5f)),
        ShaderParameter("tertiaryColor", ShaderParameterType.FLOAT3, listOf(0.1f, 0.3f, 0.5f)),
        ShaderParameter("scale", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("speed", ShaderParameterType.FLOAT, 0.3f),
        ShaderParameter("softness", ShaderParameterType.FLOAT, 0.6f),
        ShaderParameter("blobCount", ShaderParameterType.FLOAT, 3.0f)
    )

    override val needsAnimation: Boolean = true

    private var time: Float = 0.0f

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.clouds)
        return GLUtils.createProgram(vertexShader, fragmentShader)
    }

    override fun update(deltaTime: Double) {
        time += deltaTime.toFloat()
    }

    override fun encode(programId: Int, context: OverlayContext) {
        if (programId == 0) {
            android.util.Log.e(TAG, "Invalid program ID (0) - shader compilation likely failed")
            return
        }

        val timeLoc = GLES30.glGetUniformLocation(programId, "time")
        GLES30.glUniform1f(timeLoc, time)

        val intensity = (context.parameters["intensity"] as? Number)?.toFloat() ?: 0.6f
        val intensityLoc = GLES30.glGetUniformLocation(programId, "intensity")
        GLES30.glUniform1f(intensityLoc, intensity)

        val viewSizeLoc = GLES30.glGetUniformLocation(programId, "viewSize")
        GLES30.glUniform2f(viewSizeLoc, context.viewWidth.toFloat(), context.viewHeight.toFloat())

        val color = context.parameters.extractFloat3(
            "color", "colorR", "colorG", "colorB",
            floatArrayOf(0.15f, 0.2f, 0.55f)
        )
        val colorLoc = GLES30.glGetUniformLocation(programId, "color")
        GLES30.glUniform3f(colorLoc, color[0], color[1], color[2])

        val secondaryColor = context.parameters.extractFloat3(
            "secondaryColor", "secondaryColorR", "secondaryColorG", "secondaryColorB",
            floatArrayOf(0.25f, 0.15f, 0.5f)
        )
        val secondaryColorLoc = GLES30.glGetUniformLocation(programId, "secondaryColor")
        GLES30.glUniform3f(secondaryColorLoc, secondaryColor[0], secondaryColor[1], secondaryColor[2])

        val tertiaryColor = context.parameters.extractFloat3(
            "tertiaryColor", "tertiaryColorR", "tertiaryColorG", "tertiaryColorB",
            floatArrayOf(0.1f, 0.3f, 0.5f)
        )
        val tertiaryColorLoc = GLES30.glGetUniformLocation(programId, "tertiaryColor")
        GLES30.glUniform3f(tertiaryColorLoc, tertiaryColor[0], tertiaryColor[1], tertiaryColor[2])

        val scale = (context.parameters["scale"] as? Number)?.toFloat() ?: 1.0f
        val scaleLoc = GLES30.glGetUniformLocation(programId, "scale")
        GLES30.glUniform1f(scaleLoc, scale)

        val speed = (context.parameters["speed"] as? Number)?.toFloat() ?: 0.3f
        val speedLoc = GLES30.glGetUniformLocation(programId, "speed")
        GLES30.glUniform1f(speedLoc, speed)

        val softness = (context.parameters["softness"] as? Number)?.toFloat() ?: 0.6f
        val softnessLoc = GLES30.glGetUniformLocation(programId, "softness")
        GLES30.glUniform1f(softnessLoc, softness)

        val blobCount = (context.parameters["blobCount"] as? Number)?.toFloat() ?: 3.0f
        val blobCountLoc = GLES30.glGetUniformLocation(programId, "blobCount")
        GLES30.glUniform1f(blobCountLoc, blobCount)
    }

    companion object {
        private const val TAG = "CloudsOverlay"
    }
}
