package com.nativesprings.shaders

/**
 * Helper functions for extracting typed parameters from context maps
 */

/**
 * Extract a FloatArray of size 2 from either an array parameter or individual X/Y components
 * Priority: array parameter > individual X/Y components > default value
 */
fun Map<String, Any>.extractFloat2(
    arrayName: String,
    xName: String? = null,
    yName: String? = null,
    default: FloatArray = floatArrayOf(0f, 0f)
): FloatArray {
    // Try to extract from array parameter first
    when (val value = this[arrayName]) {
        is FloatArray -> if (value.size >= 2) return floatArrayOf(value[0], value[1])
        is DoubleArray -> if (value.size >= 2) return floatArrayOf(value[0].toFloat(), value[1].toFloat())
        is List<*> -> {
            if (value.size >= 2) {
                val x = when (val first = value[0]) {
                    is Number -> first.toFloat()
                    else -> default[0]
                }
                val y = when (val second = value[1]) {
                    is Number -> second.toFloat()
                    else -> default[1]
                }
                return floatArrayOf(x, y)
            }
        }
    }

    // Fall back to individual X/Y components if provided
    if (xName != null && yName != null) {
        val x = (this[xName] as? Number)?.toFloat() ?: default[0]
        val y = (this[yName] as? Number)?.toFloat() ?: default[1]
        return floatArrayOf(x, y)
    }

    return default
}

/**
 * Extract a FloatArray of size 3 from either an array parameter or individual R/G/B components
 * Priority: array parameter > individual R/G/B components > default value
 */
fun Map<String, Any>.extractFloat3(
    arrayName: String,
    rName: String? = null,
    gName: String? = null,
    bName: String? = null,
    default: FloatArray = floatArrayOf(1f, 1f, 1f)
): FloatArray {
    // Try to extract from array parameter first
    when (val value = this[arrayName]) {
        is FloatArray -> if (value.size >= 3) return floatArrayOf(value[0], value[1], value[2])
        is DoubleArray -> if (value.size >= 3) return floatArrayOf(value[0].toFloat(), value[1].toFloat(), value[2].toFloat())
        is List<*> -> {
            if (value.size >= 3) {
                val r = when (val first = value[0]) {
                    is Number -> first.toFloat()
                    else -> default[0]
                }
                val g = when (val second = value[1]) {
                    is Number -> second.toFloat()
                    else -> default[1]
                }
                val b = when (val third = value[2]) {
                    is Number -> third.toFloat()
                    else -> default[2]
                }
                return floatArrayOf(r, g, b)
            }
        }
    }

    // Fall back to individual R/G/B components if provided
    if (rName != null && gName != null && bName != null) {
        val r = (this[rName] as? Number)?.toFloat() ?: default[0]
        val g = (this[gName] as? Number)?.toFloat() ?: default[1]
        val b = (this[bName] as? Number)?.toFloat() ?: default[2]
        return floatArrayOf(r, g, b)
    }

    return default
}
