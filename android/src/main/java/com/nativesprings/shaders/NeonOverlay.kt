package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class NeonOverlay(private val context: Context) : Overlay {
    override val name: String = "neon"

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("borderWidth", ShaderParameterType.FLOAT, 3.0f),
        ShaderParameter("cornerRadius", ShaderParameterType.FLOAT, 16.0f),
        ShaderParameter("color", ShaderParameterType.FLOAT3, listOf(0.0f, 1.0f, 0.9f)),
        ShaderParameter("secondaryColor", ShaderParameterType.FLOAT3, listOf(1.0f, 0.0f, 0.8f)),
        ShaderParameter("glowSize", ShaderParameterType.FLOAT, 4.0f),
        ShaderParameter("glowFalloff", ShaderParameterType.FLOAT, 1.2f),
        ShaderParameter("flowSpeed", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("flowIntensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("pulseSpeed", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("pulseIntensity", ShaderParameterType.FLOAT, 0.2f),
        ShaderParameter("flickerIntensity", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("colorBlend", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("inset", ShaderParameterType.FLOAT, 0.0f)
    )

    override val needsAnimation: Boolean = true

    private var time: Float = 0.0f

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.neon)
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

        val intensity = (context.parameters["intensity"] as? Number)?.toFloat() ?: 1.0f
        val intensityLoc = GLES30.glGetUniformLocation(programId, "intensity")
        GLES30.glUniform1f(intensityLoc, intensity)

        val viewSizeLoc = GLES30.glGetUniformLocation(programId, "viewSize")
        GLES30.glUniform2f(viewSizeLoc, context.viewWidth.toFloat(), context.viewHeight.toFloat())

        val borderWidth = (context.parameters["borderWidth"] as? Number)?.toFloat() ?: 3.0f
        val borderWidthLoc = GLES30.glGetUniformLocation(programId, "borderWidth")
        GLES30.glUniform1f(borderWidthLoc, borderWidth)

        val cornerRadius = (context.parameters["cornerRadius"] as? Number)?.toFloat() ?: 16.0f
        val cornerRadiusLoc = GLES30.glGetUniformLocation(programId, "cornerRadius")
        GLES30.glUniform1f(cornerRadiusLoc, cornerRadius)

        val color = context.parameters.extractFloat3(
            "color", "colorR", "colorG", "colorB",
            floatArrayOf(0.0f, 1.0f, 0.9f)
        )
        val colorLoc = GLES30.glGetUniformLocation(programId, "color")
        GLES30.glUniform3f(colorLoc, color[0], color[1], color[2])

        val secondaryColor = context.parameters.extractFloat3(
            "secondaryColor", "secondaryColorR", "secondaryColorG", "secondaryColorB",
            floatArrayOf(1.0f, 0.0f, 0.8f)
        )
        val secondaryColorLoc = GLES30.glGetUniformLocation(programId, "secondaryColor")
        GLES30.glUniform3f(secondaryColorLoc, secondaryColor[0], secondaryColor[1], secondaryColor[2])

        val glowSize = (context.parameters["glowSize"] as? Number)?.toFloat() ?: 4.0f
        val glowSizeLoc = GLES30.glGetUniformLocation(programId, "glowSize")
        GLES30.glUniform1f(glowSizeLoc, glowSize)

        val glowFalloff = (context.parameters["glowFalloff"] as? Number)?.toFloat() ?: 1.2f
        val glowFalloffLoc = GLES30.glGetUniformLocation(programId, "glowFalloff")
        GLES30.glUniform1f(glowFalloffLoc, glowFalloff)

        val flowSpeed = (context.parameters["flowSpeed"] as? Number)?.toFloat() ?: 1.0f
        val flowSpeedLoc = GLES30.glGetUniformLocation(programId, "flowSpeed")
        GLES30.glUniform1f(flowSpeedLoc, flowSpeed)

        val flowIntensity = (context.parameters["flowIntensity"] as? Number)?.toFloat() ?: 1.0f
        val flowIntensityLoc = GLES30.glGetUniformLocation(programId, "flowIntensity")
        GLES30.glUniform1f(flowIntensityLoc, flowIntensity)

        val pulseSpeed = (context.parameters["pulseSpeed"] as? Number)?.toFloat() ?: 1.0f
        val pulseSpeedLoc = GLES30.glGetUniformLocation(programId, "pulseSpeed")
        GLES30.glUniform1f(pulseSpeedLoc, pulseSpeed)

        val pulseIntensity = (context.parameters["pulseIntensity"] as? Number)?.toFloat() ?: 0.2f
        val pulseIntensityLoc = GLES30.glGetUniformLocation(programId, "pulseIntensity")
        GLES30.glUniform1f(pulseIntensityLoc, pulseIntensity)

        val flickerIntensity = (context.parameters["flickerIntensity"] as? Number)?.toFloat() ?: 0.0f
        val flickerIntensityLoc = GLES30.glGetUniformLocation(programId, "flickerIntensity")
        GLES30.glUniform1f(flickerIntensityLoc, flickerIntensity)

        val colorBlend = (context.parameters["colorBlend"] as? Number)?.toFloat() ?: 0.0f
        val colorBlendLoc = GLES30.glGetUniformLocation(programId, "colorBlend")
        GLES30.glUniform1f(colorBlendLoc, colorBlend)

        val inset = (context.parameters["inset"] as? Number)?.toFloat() ?: 0.0f
        val insetLoc = GLES30.glGetUniformLocation(programId, "inset")
        GLES30.glUniform1f(insetLoc, inset)
    }

    companion object {
        private const val TAG = "NeonOverlay"
    }
}
