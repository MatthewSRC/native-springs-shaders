package com.nativesprings.shaders

/**
 * Types of parameters that shaders can accept
 */
enum class ShaderParameterType {
    FLOAT,
    FLOAT2,
    FLOAT3,
    FLOAT4,
    INT,
    BOOL
}

/**
 * Represents a parameter that can be passed to a shader
 */
data class ShaderParameter(
    val name: String,
    val type: ShaderParameterType,
    val defaultValue: Any? = null
)
