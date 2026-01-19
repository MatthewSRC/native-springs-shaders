package com.nativesprings.shaders

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class NativeSpringsShaderOverlayModule : Module() {
    override fun definition() = ModuleDefinition {
        // Sets the name of the module that JavaScript code will use to refer to the module
        Name("NativeSpringsShaderOverlay")

        // Module initialization - register built-in overlays
        OnCreate {
            // Auto-register built-in overlays
            FireSparksOverlay(appContext.reactContext!!)
            AuroraOverlay(appContext.reactContext!!)
            FireworksOverlay(appContext.reactContext!!)
            LightRayOverlay(appContext.reactContext!!)
            SparklesOverlay(appContext.reactContext!!)
        }

        // Expose the overlay view
        View(NativeSpringsShaderOverlayView::class) {
            // Overlay name property (special - triggers overlay loading)
            Prop("overlayName") { view: NativeSpringsShaderOverlayView, overlayName: String? ->
                view.overlayName = overlayName
            }

            // Generic parameters handler - replaces 31 individual Prop() calls
            // Accepts a map of parameter name -> value pairs
            Prop("parameters") { view: NativeSpringsShaderOverlayView, params: Map<String, Any> ->
                view.setParameters(params)
            }
        }
    }
}
