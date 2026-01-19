package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class FireworksOverlay(private val context: Context) : Overlay {
    override val name: String = "fireworks"

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("speed", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("minSize", ShaderParameterType.FLOAT, 0.2f),
        ShaderParameter("maxSize", ShaderParameterType.FLOAT, 0.6f),
        ShaderParameter("minDuration", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("maxDuration", ShaderParameterType.FLOAT, 2.5f),
        ShaderParameter("frequency", ShaderParameterType.FLOAT, 1.5f),
        ShaderParameter("color", ShaderParameterType.FLOAT3, listOf(1.0f, 0.5f, 0.0f)),
        ShaderParameter("useCustomColor", ShaderParameterType.FLOAT, 0.0f),
        ShaderParameter("sharpness", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("particleCount", ShaderParameterType.FLOAT, 50.0f),
        ShaderParameter("gravity", ShaderParameterType.FLOAT, 0.4f)
    )

    override val needsAnimation: Boolean = true

    private var time: Float = 0.0f

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.fireworks)
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

        val speed = (context.parameters["speed"] as? Float) ?: 1.0f
        val speedLoc = GLES30.glGetUniformLocation(programId, "speed")
        GLES30.glUniform1f(speedLoc, speed)

        val minSize = (context.parameters["minSize"] as? Float) ?: 0.2f
        val minSizeLoc = GLES30.glGetUniformLocation(programId, "minSize")
        GLES30.glUniform1f(minSizeLoc, minSize)

        val maxSize = (context.parameters["maxSize"] as? Float) ?: 0.6f
        val maxSizeLoc = GLES30.glGetUniformLocation(programId, "maxSize")
        GLES30.glUniform1f(maxSizeLoc, maxSize)

        val minDuration = (context.parameters["minDuration"] as? Float) ?: 1.0f
        val minDurationLoc = GLES30.glGetUniformLocation(programId, "minDuration")
        GLES30.glUniform1f(minDurationLoc, minDuration)

        val maxDuration = (context.parameters["maxDuration"] as? Float) ?: 2.5f
        val maxDurationLoc = GLES30.glGetUniformLocation(programId, "maxDuration")
        GLES30.glUniform1f(maxDurationLoc, maxDuration)

        val frequency = (context.parameters["frequency"] as? Float) ?: 1.5f
        val frequencyLoc = GLES30.glGetUniformLocation(programId, "frequency")
        GLES30.glUniform1f(frequencyLoc, frequency)

        val color = context.parameters.extractFloat3("color", "colorR", "colorG", "colorB", floatArrayOf(1.0f, 0.5f, 0.0f))
        val customColorLoc = GLES30.glGetUniformLocation(programId, "customColor")
        GLES30.glUniform3f(customColorLoc, color[0], color[1], color[2])

        val useCustomColorBool = (context.parameters["useCustomColor"] as? Boolean) ?: false
        val useCustomColor = if (useCustomColorBool) 1.0f else 0.0f
        val useCustomColorLoc = GLES30.glGetUniformLocation(programId, "useCustomColor")
        GLES30.glUniform1f(useCustomColorLoc, useCustomColor)

        val sharpness = (context.parameters["sharpness"] as? Float) ?: 1.0f
        val sharpnessLoc = GLES30.glGetUniformLocation(programId, "sharpness")
        GLES30.glUniform1f(sharpnessLoc, sharpness)

        val particleCount = (context.parameters["particleCount"] as? Float) ?: 50.0f
        val particleCountLoc = GLES30.glGetUniformLocation(programId, "u_ParticleCount")
        GLES30.glUniform1f(particleCountLoc, particleCount)

        val gravity = (context.parameters["gravity"] as? Float) ?: 0.4f
        val gravityLoc = GLES30.glGetUniformLocation(programId, "u_Gravity")
        GLES30.glUniform1f(gravityLoc, gravity)
    }

    companion object {
        private const val TAG = "FireworksOverlay"
    }
}
