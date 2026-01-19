package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class FireSparksOverlay(private val context: Context) : Overlay {
    override val name: String = "fireSparks"

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("direction", ShaderParameterType.FLOAT2, listOf(0.7f, -1.0f)),
        ShaderParameter("travelDistance", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("color", ShaderParameterType.FLOAT3, listOf(1.0f, 0.4f, 0.05f)),
        ShaderParameter("particleSize", ShaderParameterType.FLOAT, 0.009f),
        ShaderParameter("animationSpeed", ShaderParameterType.FLOAT, 1.5f),
        ShaderParameter("smokeIntensity", ShaderParameterType.FLOAT, 0.8f),
        ShaderParameter("particleBloom", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("movementSpeed", ShaderParameterType.FLOAT, 1.0f)
    )

    override val needsAnimation: Boolean = true

    private var time: Float = 0.0f

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.fire_sparks)
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

        val direction = context.parameters.extractFloat2("direction", "directionX", "directionY", floatArrayOf(0.7f, -1.0f))
        val movementDirectionLoc = GLES30.glGetUniformLocation(programId, "movementDirection")
        GLES30.glUniform2f(movementDirectionLoc, direction[0], direction[1])

        val travelDistance = (context.parameters["travelDistance"] as? Float) ?: 1.0f
        val travelDistanceLoc = GLES30.glGetUniformLocation(programId, "travelDistance")
        GLES30.glUniform1f(travelDistanceLoc, travelDistance)

        val color = context.parameters.extractFloat3("color", "colorR", "colorG", "colorB", floatArrayOf(1.0f, 0.4f, 0.05f))
        val sparkColorLoc = GLES30.glGetUniformLocation(programId, "sparkColor")
        GLES30.glUniform3f(sparkColorLoc, color[0], color[1], color[2])

        val particleSize = (context.parameters["particleSize"] as? Float) ?: 0.009f
        val particleSizeLoc = GLES30.glGetUniformLocation(programId, "particleSize")
        GLES30.glUniform1f(particleSizeLoc, particleSize)

        val animationSpeed = (context.parameters["animationSpeed"] as? Float) ?: 1.5f
        val animationSpeedLoc = GLES30.glGetUniformLocation(programId, "animationSpeed")
        GLES30.glUniform1f(animationSpeedLoc, animationSpeed)

        val smokeIntensity = (context.parameters["smokeIntensity"] as? Float) ?: 0.8f
        val smokeIntensityLoc = GLES30.glGetUniformLocation(programId, "u_SmokeIntensity")
        GLES30.glUniform1f(smokeIntensityLoc, smokeIntensity)

        val particleBloom = (context.parameters["particleBloom"] as? Float) ?: 1.0f
        val particleBloomLoc = GLES30.glGetUniformLocation(programId, "u_ParticleBloom")
        GLES30.glUniform1f(particleBloomLoc, particleBloom)

        val movementSpeed = (context.parameters["movementSpeed"] as? Float) ?: 1.0f
        val movementSpeedLoc = GLES30.glGetUniformLocation(programId, "u_MovementSpeed")
        GLES30.glUniform1f(movementSpeedLoc, movementSpeed)
    }

    companion object {
        private const val TAG = "FireSparksOverlay"
    }
}
