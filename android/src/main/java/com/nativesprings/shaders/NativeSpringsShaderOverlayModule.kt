package com.nativesprings.shaders

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class NativeSpringsShaderOverlayModule : Module() {
    override fun definition() = ModuleDefinition {
        Name("NativeSpringsShaderOverlay")

        OnCreate {
            // Auto-register built-in overlays
            FireSparksOverlay(appContext.reactContext!!)
            AuroraOverlay(appContext.reactContext!!)
            FireworksOverlay(appContext.reactContext!!)
            LightRayOverlay(appContext.reactContext!!)
            SparklesOverlay(appContext.reactContext!!)
            LiquidMetalOverlay(appContext.reactContext!!)
            NeonOverlay(appContext.reactContext!!)
        }

        View(NativeSpringsShaderOverlayView::class) {
            Prop("overlayName") { view: NativeSpringsShaderOverlayView, overlayName: String? ->
                view.overlayName = overlayName
            }

            Prop("parameters") { view: NativeSpringsShaderOverlayView, params: Map<String, Any> ->
                view.setParameters(params)
            }
        }
    }
}
