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
    private val programCache = mutableMapOf<String, Int>()
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

    @Throws(ShaderError::class)
    fun compiledProgram(name: String): Int {
        lock.read {
            programCache[name]?.let { return it }
        }

        return lock.write {
            programCache[name]?.let { return@write it }

            val shader = shaders[name] ?: throw ShaderError.ShaderNotFound(name)

            try {
                val program = shader.compile()
                programCache[name] = program

                DebugConfig.log(TAG, "Shader compiled: $name")

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

    fun clearCache() {
        lock.write {
            programCache.clear()
            DebugConfig.log(TAG, "Shader cache cleared")
        }
    }
}
