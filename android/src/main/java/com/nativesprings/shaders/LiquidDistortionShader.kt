package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class LiquidDistortionShader(private val context: Context) : Shader {
    override val name: String = "liquidDistortion"
    override val needsAnimation: Boolean = true

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("speed", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("waveScale", ShaderParameterType.FLOAT, 3.0f),
        ShaderParameter("time", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("turbulence", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("chromaticAberration", ShaderParameterType.FLOAT, 0.3f),
        ShaderParameter("liquidVariant", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("flowDirection", ShaderParameterType.FLOAT2, listOf(0.7f, -1.0f)),
        ShaderParameter("color", ShaderParameterType.FLOAT3, listOf(0.85f, 0.95f, 1.0f)),
        ShaderParameter("shineStrength", ShaderParameterType.FLOAT, 0.15f),
        ShaderParameter("colorTintStrength", ShaderParameterType.FLOAT, 0.2f)
    )

    init {
        // Auto-register this shader
        ShaderRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.liquid_distortion)
        return GLUtils.createProgram(vertexShader, fragmentShader)
    }

    override fun encode(programId: Int, context: ShaderContext) {
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, context.inputTextureId)
        val inputTextureLoc = GLES30.glGetUniformLocation(programId, "u_InputTexture")
        GLES30.glUniform1i(inputTextureLoc, 0)
        val intensity = (context.parameters["intensity"] as? Float) ?: 1.0f
        val speed = (context.parameters["speed"] as? Float) ?: 1.0f
        val waveScale = (context.parameters["waveScale"] as? Float) ?: 3.0f
        val time = (context.parameters["time"] as? Float) ?: 0.0f
        val turbulence = (context.parameters["turbulence"] as? Float) ?: 1.0f
        val chromaticAberration = (context.parameters["chromaticAberration"] as? Float) ?: 0.3f

        val liquidVariant = when (context.parameters["liquidVariant"] as? String) {
            "glass" -> 1.0f
            "oil" -> 2.0f
            else -> 0.0f
        }

        val flowDirection = context.parameters.extractFloat2("flowDirection", "flowDirectionX", "flowDirectionY", floatArrayOf(0.7f, -1.0f))
        val liquidColor = context.parameters.extractFloat3("color", null, null, null, floatArrayOf(0.85f, 0.95f, 1.0f))
        val shineStrength = (context.parameters["shineStrength"] as? Float) ?: 0.15f
        val colorTintStrength = (context.parameters["colorTintStrength"] as? Float) ?: 0.2f

        GLES30.glUniform1f(GLES30.glGetUniformLocation(programId, "u_Intensity"), intensity)
        GLES30.glUniform1f(GLES30.glGetUniformLocation(programId, "u_Speed"), speed)
        GLES30.glUniform1f(GLES30.glGetUniformLocation(programId, "u_WaveScale"), waveScale)
        GLES30.glUniform1f(GLES30.glGetUniformLocation(programId, "u_Time"), time)
        GLES30.glUniform1f(GLES30.glGetUniformLocation(programId, "u_Turbulence"), turbulence)
        GLES30.glUniform1f(GLES30.glGetUniformLocation(programId, "u_ChromaticAberration"), chromaticAberration)
        GLES30.glUniform1f(GLES30.glGetUniformLocation(programId, "u_LiquidVariant"), liquidVariant)
        GLES30.glUniform2f(GLES30.glGetUniformLocation(programId, "u_FlowDirection"), flowDirection[0], flowDirection[1])
        GLES30.glUniform3f(GLES30.glGetUniformLocation(programId, "u_LiquidColor"), liquidColor[0], liquidColor[1], liquidColor[2])
        GLES30.glUniform1f(GLES30.glGetUniformLocation(programId, "u_ShineStrength"), shineStrength)
        GLES30.glUniform1f(GLES30.glGetUniformLocation(programId, "u_ColorTintStrength"), colorTintStrength)
    }
}
