package com.nativesprings.shaders

import android.util.Log

object DebugConfig {
    var enabled: Boolean = Log.isLoggable("NativeSpringsShaders", Log.DEBUG)

    fun log(tag: String, message: String) {
        if (enabled) {
            Log.d(tag, message)
        }
    }
}
