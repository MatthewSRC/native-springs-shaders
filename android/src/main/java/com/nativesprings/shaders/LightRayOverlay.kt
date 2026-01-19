package com.nativesprings.shaders

import android.content.Context
import android.opengl.GLES30

class LightRayOverlay(private val context: Context) : Overlay {
    override val name: String = "lightRay"

    override val parameters: List<ShaderParameter> = listOf(
        ShaderParameter("intensity", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("rayPosition", ShaderParameterType.FLOAT2, listOf(0.7f, -0.4f)),
        ShaderParameter("color", ShaderParameterType.FLOAT3, listOf(1.0f, 0.95f, 0.8f)),
        ShaderParameter("speed", ShaderParameterType.FLOAT, 1.5f),
        ShaderParameter("numRays", ShaderParameterType.FLOAT, 2.0f),
        ShaderParameter("depthAttenuation", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("rayLength", ShaderParameterType.FLOAT, 1.0f),
        ShaderParameter("rayDirection", ShaderParameterType.FLOAT2, listOf(1.0f, -0.116f)),
        ShaderParameter("rayWidth", ShaderParameterType.FLOAT, 1.0f)
    )

    override val needsAnimation: Boolean = true

    private var time: Float = 0.0f

    init {
        OverlayRegistry.register(this)
    }

    override fun compile(): Int {
        val vertexShader = GLUtils.loadShaderFromResource(context, R.raw.vertex)
        val fragmentShader = GLUtils.loadShaderFromResource(context, R.raw.light_ray)
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

        val rayPosition = context.parameters.extractFloat2("rayPosition", "rayPositionX", "rayPositionY", floatArrayOf(0.7f, -0.4f))
        val rayPositionLoc = GLES30.glGetUniformLocation(programId, "rayPosition")
        GLES30.glUniform2f(rayPositionLoc, rayPosition[0], rayPosition[1])

        val color = context.parameters.extractFloat3("color", "colorR", "colorG", "colorB", floatArrayOf(1.0f, 0.95f, 0.8f))
        val rayColorLoc = GLES30.glGetUniformLocation(programId, "rayColor")
        GLES30.glUniform3f(rayColorLoc, color[0], color[1], color[2])

        val speed = (context.parameters["speed"] as? Float) ?: 1.5f
        val speedLoc = GLES30.glGetUniformLocation(programId, "speed")
        GLES30.glUniform1f(speedLoc, speed)

        val numRays = (context.parameters["numRays"] as? Float) ?: 2.0f
        val numRaysLoc = GLES30.glGetUniformLocation(programId, "numRays")
        GLES30.glUniform1f(numRaysLoc, numRays)

        val depthAttenuation = (context.parameters["depthAttenuation"] as? Float) ?: 1.0f
        val depthAttenuationLoc = GLES30.glGetUniformLocation(programId, "depthAttenuation")
        GLES30.glUniform1f(depthAttenuationLoc, depthAttenuation)

        val rayLength = (context.parameters["rayLength"] as? Float) ?: 1.0f
        val rayLengthLoc = GLES30.glGetUniformLocation(programId, "rayLength")
        GLES30.glUniform1f(rayLengthLoc, rayLength)

        val rayDirection = context.parameters.extractFloat2("rayDirection", "rayDirectionX", "rayDirectionY", floatArrayOf(1.0f, -0.116f))
        val rayDirectionLoc = GLES30.glGetUniformLocation(programId, "u_RayDirection")
        GLES30.glUniform2f(rayDirectionLoc, rayDirection[0], rayDirection[1])

        val rayWidth = (context.parameters["rayWidth"] as? Float) ?: 1.0f
        val rayWidthLoc = GLES30.glGetUniformLocation(programId, "u_RayWidth")
        GLES30.glUniform1f(rayWidthLoc, rayWidth)
    }

    companion object {
        private const val TAG = "LightRayOverlay"
    }
}
