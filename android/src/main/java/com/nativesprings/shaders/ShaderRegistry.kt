package com.nativesprings.shaders

import android.util.Log
import java.util.concurrent.locks.ReentrantReadWriteLock
import kotlin.concurrent.read
import kotlin.concurrent.write

sealed class ShaderError(message: String) : Exception(message) {
    class ShaderNotFound(name: String) : ShaderError("Shader '$name' not found in registry")
    class CompilationFailed(reason: String) : ShaderError("Shader compilation failed: $reason")
    class InvalidParameter(name: String) : ShaderError("Invalid parameter: $name")
}

object ShaderRegistry {
    private const val TAG = "ShaderRegistry"
    private val shaders = mutableMapOf<String, Shader>()
    private val lock = ReentrantReadWriteLock()

    fun register(shader: Shader) {
        lock.write {
            shaders[shader.name] = shader
            DebugConfig.log(TAG, "Shader registered: ${shader.name}")
        }
    }

    fun get(name: String): Shader? {
        return lock.read {
            shaders[name]
        }
    }

    /**
     * Get or compile a shader program using a local cache.
     * Each GL context must provide its own cache since programs are context-specific.
     *
     * @param name The shader name
     * @param localCache The caller's local program cache (per GL context)
     * @return The compiled program ID, or 0 if compilation failed
     */
    fun getOrCompile(name: String, localCache: MutableMap<String, Int>): Int {
        return localCache.getOrPut(name) {
            val shader = lock.read { shaders[name] }
            if (shader == null) {
                DebugConfig.log(TAG, "Shader '$name' not found in registry")
                return@getOrPut 0
            }

            try {
                val program = shader.compile()
                if (program == 0) {
                    DebugConfig.log(TAG, "Failed to compile shader $name")
                } else {
                    DebugConfig.log(TAG, "Shader compiled: $name")
                }
                program
            } catch (e: Exception) {
                throw ShaderError.CompilationFailed(e.message ?: "Unknown error")
            }
        }
    }

    val registeredShaders: List<String>
        get() = lock.read {
            shaders.keys.toList()
        }
}
