package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class RippleShader(private val context: Context) : Shader {
    override val name: String = "ripple"
    override val needsAnimation: Boolean = true

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("touchPoint", ShaderParameterType.FLOAT2, listOf(0.5f, 0.5f)),
        ShaderParameter("touchTime", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("frequency", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("damping", ShaderParameterType.FLOAT, 0.8f),
        ShaderParameter("color", ShaderParameterType.FLOAT3, listOf(1.0f, 1.0f, 1.0f)),
        ShaderParameter("rippleVariant", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("speed", ShaderParameterType.FLOAT, 300.0f),
        ShaderParameter("ringWidth", ShaderParameterType.FLOAT, 40.0f),
        ShaderParameter("slowdownFactor", ShaderParameterType.FLOAT, 0.5f),
        ShaderParameter("displacementStrength", ShaderParameterType.FLOAT, 0.05f),
        ShaderParameter("highlightStrength", ShaderParameterType.FLOAT, 0.1f),
        ShaderParameter("time", ShaderParameterType.FLOAT, 0.0f)
    )

    init {
        // Auto-register this shader
        ShaderRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.ripple)
        return GLUtils.createProgram(vertexShader, fragmentShader)
    }

    override fun encode(programId: Int, context: ShaderContext) {
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, context.inputTextureId)
        val inputTextureLoc = GLES30.glGetUniformLocation(programId, "u_Texture")
        GLES30.glUniform1i(inputTextureLoc, 0)

        val intensity = (context.parameters["intensity"] as? Float) ?: 1.0f
        val time = (context.parameters["time"] as? Float) ?: 0.0f
        val touchTime = (context.parameters["touchTime"] as? Float) ?: 0.0f
        val frequency = (context.parameters["frequency"] as? Float) ?: 1.0f
        val damping = (context.parameters["damping"] as? Float) ?: 0.8f

        val rippleVariant = when (context.parameters["rippleVariant"] as? String) {
            "realistic" -> 1.0f
            else -> (context.parameters["rippleVariant"] as? Float) ?: 0.0f
        }

        val speed = (context.parameters["speed"] as? Float) ?: 300.0f
        val ringWidth = (context.parameters["ringWidth"] as? Float) ?: 40.0f
        val slowdownFactor = (context.parameters["slowdownFactor"] as? Float) ?: 0.5f
        val displacementStrength = (context.parameters["displacementStrength"] as? Float) ?: 0.05f
        val highlightStrength = (context.parameters["highlightStrength"] as? Float) ?: 0.1f

        val touchPoint = context.parameters.extractFloat2("touchPoint", null, null, floatArrayOf(0.5f, 0.5f))
        val rippleColor = context.parameters.extractFloat3("color", null, null, null, floatArrayOf(1.0f, 1.0f, 1.0f))

        val intensityLoc = GLES30.glGetUniformLocation(programId, "u_Intensity")
        GLES30.glUniform1f(intensityLoc, intensity)

        val timeLoc = GLES30.glGetUniformLocation(programId, "u_Time")
        GLES30.glUniform1f(timeLoc, time)

        val touchPointLoc = GLES30.glGetUniformLocation(programId, "u_TouchPoint")
        GLES30.glUniform2f(touchPointLoc, touchPoint[0], touchPoint[1])

        val touchTimeLoc = GLES30.glGetUniformLocation(programId, "u_TouchTime")
        GLES30.glUniform1f(touchTimeLoc, touchTime)

        val frequencyLoc = GLES30.glGetUniformLocation(programId, "u_Frequency")
        GLES30.glUniform1f(frequencyLoc, frequency)

        val dampingLoc = GLES30.glGetUniformLocation(programId, "u_Damping")
        GLES30.glUniform1f(dampingLoc, damping)

        val rippleColorLoc = GLES30.glGetUniformLocation(programId, "u_RippleColor")
        GLES30.glUniform3f(rippleColorLoc, rippleColor[0], rippleColor[1], rippleColor[2])

        val rippleVariantLoc = GLES30.glGetUniformLocation(programId, "u_RippleVariant")
        GLES30.glUniform1f(rippleVariantLoc, rippleVariant)

        val speedLoc = GLES30.glGetUniformLocation(programId, "u_Speed")
        GLES30.glUniform1f(speedLoc, speed)

        val ringWidthLoc = GLES30.glGetUniformLocation(programId, "u_RingWidth")
        GLES30.glUniform1f(ringWidthLoc, ringWidth)

        val slowdownFactorLoc = GLES30.glGetUniformLocation(programId, "u_SlowdownFactor")
        GLES30.glUniform1f(slowdownFactorLoc, slowdownFactor)

        val displacementStrengthLoc = GLES30.glGetUniformLocation(programId, "u_DisplacementStrength")
        GLES30.glUniform1f(displacementStrengthLoc, displacementStrength)

        val highlightStrengthLoc = GLES30.glGetUniformLocation(programId, "u_HighlightStrength")
        GLES30.glUniform1f(highlightStrengthLoc, highlightStrength)

        val resolutionLoc = GLES30.glGetUniformLocation(programId, "u_Resolution")
        GLES30.glUniform2f(resolutionLoc, context.width.toFloat(), context.height.toFloat())
    }
}
