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

    // Cached uniform locations — populated once in compile(), reused every frame.
    private var locTime = -1
    private var locIntensity = -1
    private var locViewSize = -1
    private var locColor = -1
    private var locSecondaryColor = -1
    private var locTertiaryColor = -1
    private var locScale = -1
    private var locSpeed = -1
    private var locSoftness = -1
    private var locBlobCount = -1

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.clouds)
        val programId = GLUtils.createProgram(vertexShader, fragmentShader)
        if (programId != 0) {
            locTime           = GLES30.glGetUniformLocation(programId, "time")
            locIntensity      = GLES30.glGetUniformLocation(programId, "intensity")
            locViewSize       = GLES30.glGetUniformLocation(programId, "viewSize")
            locColor          = GLES30.glGetUniformLocation(programId, "color")
            locSecondaryColor = GLES30.glGetUniformLocation(programId, "secondaryColor")
            locTertiaryColor  = GLES30.glGetUniformLocation(programId, "tertiaryColor")
            locScale          = GLES30.glGetUniformLocation(programId, "scale")
            locSpeed          = GLES30.glGetUniformLocation(programId, "speed")
            locSoftness       = GLES30.glGetUniformLocation(programId, "softness")
            locBlobCount      = GLES30.glGetUniformLocation(programId, "blobCount")
        }
        return programId
    }

    override fun update(deltaTime: Double) {
        time += deltaTime.toFloat()
    }

    override fun encode(programId: Int, context: OverlayContext) {
        if (programId == 0) {
            android.util.Log.e(TAG, "Invalid program ID (0) - shader compilation likely failed")
            return
        }

        GLES30.glUniform1f(locTime, time)

        val intensity = (context.parameters["intensity"] as? Number)?.toFloat() ?: 0.6f
        GLES30.glUniform1f(locIntensity, intensity)

        GLES30.glUniform2f(locViewSize, context.viewWidth.toFloat(), context.viewHeight.toFloat())

        val color = context.parameters.extractFloat3(
            "color", "colorR", "colorG", "colorB",
            floatArrayOf(0.15f, 0.2f, 0.55f)
        )
        GLES30.glUniform3f(locColor, color[0], color[1], color[2])

        val secondaryColor = context.parameters.extractFloat3(
            "secondaryColor", "secondaryColorR", "secondaryColorG", "secondaryColorB",
            floatArrayOf(0.25f, 0.15f, 0.5f)
        )
        GLES30.glUniform3f(locSecondaryColor, secondaryColor[0], secondaryColor[1], secondaryColor[2])

        val tertiaryColor = context.parameters.extractFloat3(
            "tertiaryColor", "tertiaryColorR", "tertiaryColorG", "tertiaryColorB",
            floatArrayOf(0.1f, 0.3f, 0.5f)
        )
        GLES30.glUniform3f(locTertiaryColor, tertiaryColor[0], tertiaryColor[1], tertiaryColor[2])

        val scale = (context.parameters["scale"] as? Number)?.toFloat() ?: 1.0f
        GLES30.glUniform1f(locScale, scale)

        val speed = (context.parameters["speed"] as? Number)?.toFloat() ?: 0.3f
        GLES30.glUniform1f(locSpeed, speed)

        val softness = (context.parameters["softness"] as? Number)?.toFloat() ?: 0.6f
        GLES30.glUniform1f(locSoftness, softness)

        val blobCount = (context.parameters["blobCount"] as? Number)?.toFloat() ?: 3.0f
        GLES30.glUniform1f(locBlobCount, blobCount)
    }

    companion object {
        private const val TAG = "CloudsOverlay"
    }
}
