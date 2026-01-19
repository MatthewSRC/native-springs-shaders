package com.nativesprings.shaders

import android.util.Log
import java.util.concurrent.locks.ReentrantReadWriteLock
import kotlin.concurrent.read
import kotlin.concurrent.write

sealed class OverlayError(message: String) : Exception(message) {
    class OverlayNotFound(name: String) : OverlayError("Overlay '$name' not found in registry")
    class CompilationFailed(reason: String) : OverlayError("Overlay compilation failed: $reason")
    class InvalidParameter(name: String) : OverlayError("Invalid parameter: $name")
}

object OverlayRegistry {
    private const val TAG = "OverlayRegistry"

    private val overlays = mutableMapOf<String, Overlay>()
    private val programCache = mutableMapOf<String, Int>()
    private val lock = ReentrantReadWriteLock()

    fun register(overlay: Overlay) {
        lock.write {
            overlays[overlay.name] = overlay
            DebugConfig.log(TAG, "Overlay registered: ${overlay.name}")
        }
    }

    fun get(name: String): Overlay? {
        return lock.read {
            overlays[name]
        }
    }

    @Throws(OverlayError::class)
    fun compiledProgram(name: String): Int {
        lock.read {
            programCache[name]?.let { return it }
        }

        return lock.write {
            programCache[name]?.let { return@write it }

            val overlay = overlays[name] ?: throw OverlayError.OverlayNotFound(name)

            try {
                val program = overlay.compile()
                programCache[name] = program

                DebugConfig.log(TAG, "Overlay compiled: $name")

                program
            } catch (e: Exception) {
                throw OverlayError.CompilationFailed(e.message ?: "Unknown error")
            }
        }
    }

    val registeredOverlays: List<String>
        get() = lock.read {
            overlays.keys.toList()
        }

    fun clearCache() {
        lock.write {
            programCache.clear()
            DebugConfig.log(TAG, "Overlay program cache cleared")
        }
    }
}
