package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class GlitchShader(private val context: Context) : Shader {
    override val name: String = "glitch"
    override val needsAnimation: Boolean = true

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("chromaticAberration", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("scanlineIntensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("glitchFrequency", ShaderParameterType.FLOAT, 0.15f),
        ShaderParameter("blockSize", ShaderParameterType.FLOAT, 50.0f),
        ShaderParameter("grainIntensity", ShaderParameterType.FLOAT, 0.04f),
        ShaderParameter("vignetteStrength", ShaderParameterType.FLOAT, 0.5f),
        ShaderParameter("chromaticSpread", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("time", ShaderParameterType.FLOAT, 0.0f)
    )

    init {
        // Auto-register this shader
        ShaderRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.glitch)
        return GLUtils.createProgram(vertexShader, fragmentShader)
    }

    override fun encode(programId: Int, context: ShaderContext) {
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, context.inputTextureId)
        val inputTextureLoc = GLES30.glGetUniformLocation(programId, "u_Texture")
        GLES30.glUniform1i(inputTextureLoc, 0)
        val intensity = (context.parameters["intensity"] as? Float) ?: 1.0f
        val chromaticAberration = (context.parameters["chromaticAberration"] as? Float) ?: 1.0f
        val scanlineIntensity = (context.parameters["scanlineIntensity"] as? Float) ?: 1.0f
        val glitchFrequency = (context.parameters["glitchFrequency"] as? Float) ?: 0.15f
        val blockSize = (context.parameters["blockSize"] as? Float) ?: 50.0f
        val grainIntensity = (context.parameters["grainIntensity"] as? Float) ?: 0.04f
        val vignetteStrength = (context.parameters["vignetteStrength"] as? Float) ?: 0.5f
        val chromaticSpread = (context.parameters["chromaticSpread"] as? Float) ?: 1.0f
        val time = (context.parameters["time"] as? Float) ?: 0.0f

        val intensityLoc = GLES30.glGetUniformLocation(programId, "u_Intensity")
        GLES30.glUniform1f(intensityLoc, intensity)

        val chromaticAberrationLoc = GLES30.glGetUniformLocation(programId, "u_ChromaticAberration")
        GLES30.glUniform1f(chromaticAberrationLoc, chromaticAberration)

        val scanlineIntensityLoc = GLES30.glGetUniformLocation(programId, "u_ScanlineIntensity")
        GLES30.glUniform1f(scanlineIntensityLoc, scanlineIntensity)

        val glitchFrequencyLoc = GLES30.glGetUniformLocation(programId, "u_GlitchFrequency")
        GLES30.glUniform1f(glitchFrequencyLoc, glitchFrequency)

        val blockSizeLoc = GLES30.glGetUniformLocation(programId, "u_BlockSize")
        GLES30.glUniform1f(blockSizeLoc, blockSize)

        val grainIntensityLoc = GLES30.glGetUniformLocation(programId, "u_GrainIntensity")
        GLES30.glUniform1f(grainIntensityLoc, grainIntensity)

        val vignetteStrengthLoc = GLES30.glGetUniformLocation(programId, "u_VignetteStrength")
        GLES30.glUniform1f(vignetteStrengthLoc, vignetteStrength)

        val chromaticSpreadLoc = GLES30.glGetUniformLocation(programId, "u_ChromaticSpread")
        GLES30.glUniform1f(chromaticSpreadLoc, chromaticSpread)

        val timeLoc = GLES30.glGetUniformLocation(programId, "u_Time")
        GLES30.glUniform1f(timeLoc, time)

        val resolutionLoc = GLES30.glGetUniformLocation(programId, "u_Resolution")
        GLES30.glUniform2f(resolutionLoc, context.width.toFloat(), context.height.toFloat())
    }
}
