package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class LiquidMetalOverlay(private val context: Context) : Overlay {
    override val name: String = "liquidMetal"

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("borderWidth", ShaderParameterType.FLOAT, 4.0f),
        ShaderParameter("cornerRadius", ShaderParameterType.FLOAT, 12.0f),
        ShaderParameter("baseColor", ShaderParameterType.FLOAT3, listOf(0.15f, 0.15f, 0.2f)),
        ShaderParameter("highlightColor", ShaderParameterType.FLOAT3, listOf(0.9f, 0.92f, 1.0f)),
        ShaderParameter("flowSpeed", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("repetition", ShaderParameterType.FLOAT, 4.0f),
        ShaderParameter("distortion", ShaderParameterType.FLOAT, 0.3f),
        ShaderParameter("chromaticAberration", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("flowOffsetX", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("flowOffsetY", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("flowAngle", ShaderParameterType.FLOAT, 1.22f),
        ShaderParameter("specularIntensity", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("specularPositionX", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("specularPositionY", ShaderParameterType.FLOAT, -0.5f),
        ShaderParameter("specularSize", ShaderParameterType.FLOAT, 0.3f),
        ShaderParameter("roughness", ShaderParameterType.FLOAT, 0.0f)
    )

    override val needsAnimation: Boolean = true

    private var time: Float = 0.0f

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.liquid_metal)
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

        val borderWidth = (context.parameters["borderWidth"] as? Number)?.toFloat() ?: 4.0f
        val borderWidthLoc = GLES30.glGetUniformLocation(programId, "borderWidth")
        GLES30.glUniform1f(borderWidthLoc, borderWidth)

        val cornerRadius = (context.parameters["cornerRadius"] as? Number)?.toFloat() ?: 12.0f
        val cornerRadiusLoc = GLES30.glGetUniformLocation(programId, "cornerRadius")
        GLES30.glUniform1f(cornerRadiusLoc, cornerRadius)

        val baseColor = context.parameters.extractFloat3(
            "baseColor", "baseColorR", "baseColorG", "baseColorB",
            floatArrayOf(0.15f, 0.15f, 0.2f)
        )
        val baseColorLoc = GLES30.glGetUniformLocation(programId, "baseColor")
        GLES30.glUniform3f(baseColorLoc, baseColor[0], baseColor[1], baseColor[2])

        val highlightColor = context.parameters.extractFloat3(
            "highlightColor", "highlightColorR", "highlightColorG", "highlightColorB",
            floatArrayOf(0.9f, 0.92f, 1.0f)
        )
        val highlightColorLoc = GLES30.glGetUniformLocation(programId, "highlightColor")
        GLES30.glUniform3f(highlightColorLoc, highlightColor[0], highlightColor[1], highlightColor[2])

        val flowSpeed = (context.parameters["flowSpeed"] as? Number)?.toFloat() ?: 1.0f
        val flowSpeedLoc = GLES30.glGetUniformLocation(programId, "flowSpeed")
        GLES30.glUniform1f(flowSpeedLoc, flowSpeed)

        val repetition = (context.parameters["repetition"] as? Number)?.toFloat() ?: 4.0f
        val repetitionLoc = GLES30.glGetUniformLocation(programId, "repetition")
        GLES30.glUniform1f(repetitionLoc, repetition)

        val distortion = (context.parameters["distortion"] as? Number)?.toFloat() ?: 0.3f
        val distortionLoc = GLES30.glGetUniformLocation(programId, "distortion")
        GLES30.glUniform1f(distortionLoc, distortion)

        val chromaticAberration = (context.parameters["chromaticAberration"] as? Number)?.toFloat() ?: 1.0f
        val chromaticAberrationLoc = GLES30.glGetUniformLocation(programId, "chromaticAberration")
        GLES30.glUniform1f(chromaticAberrationLoc, chromaticAberration)

        val flowOffsetX = (context.parameters["flowOffsetX"] as? Number)?.toFloat() ?: 0.0f
        val flowOffsetY = (context.parameters["flowOffsetY"] as? Number)?.toFloat() ?: 0.0f
        val flowOffsetLoc = GLES30.glGetUniformLocation(programId, "flowOffset")
        GLES30.glUniform2f(flowOffsetLoc, flowOffsetX, flowOffsetY)

        val flowAngle = (context.parameters["flowAngle"] as? Number)?.toFloat() ?: 1.22f
        val flowAngleLoc = GLES30.glGetUniformLocation(programId, "flowAngle")
        GLES30.glUniform1f(flowAngleLoc, flowAngle)

        val specularIntensity = (context.parameters["specularIntensity"] as? Number)?.toFloat() ?: 0.0f
        val specularIntensityLoc = GLES30.glGetUniformLocation(programId, "specularIntensity")
        GLES30.glUniform1f(specularIntensityLoc, specularIntensity)

        val specularPositionX = (context.parameters["specularPositionX"] as? Number)?.toFloat() ?: 0.0f
        val specularPositionY = (context.parameters["specularPositionY"] as? Number)?.toFloat() ?: -0.5f
        val specularPositionLoc = GLES30.glGetUniformLocation(programId, "specularPosition")
        GLES30.glUniform2f(specularPositionLoc, specularPositionX, specularPositionY)

        val specularSize = (context.parameters["specularSize"] as? Number)?.toFloat() ?: 0.3f
        val specularSizeLoc = GLES30.glGetUniformLocation(programId, "specularSize")
        GLES30.glUniform1f(specularSizeLoc, specularSize)

        val roughness = (context.parameters["roughness"] as? Number)?.toFloat() ?: 0.0f
        val roughnessLoc = GLES30.glGetUniformLocation(programId, "roughness")
        GLES30.glUniform1f(roughnessLoc, roughness)
    }

    companion object {
        private const val TAG = "LiquidMetalOverlay"
    }
}
