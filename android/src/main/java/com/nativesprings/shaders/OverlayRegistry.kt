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

    /**
     * Get or compile an overlay program using a local cache.
     * Each GL context must provide its own cache since programs are context-specific.
     *
     * @param name The overlay name
     * @param localCache The caller's local program cache (per GL context)
     * @return The compiled program ID, or 0 if compilation failed
     */
    fun getOrCompile(name: String, localCache: MutableMap<String, Int>): Int {
        return localCache.getOrPut(name) {
            val overlay = lock.read { overlays[name] }
            if (overlay == null) {
                Log.e(TAG, "Overlay '$name' not found in registry")
                return@getOrPut 0
            }

            try {
                val program = overlay.compile()
                if (program == 0) {
                    DebugConfig.log(TAG, "Failed to compile overlay $name")
                } else {
                    DebugConfig.log(TAG, "Overlay compiled: $name")
                }
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
}
