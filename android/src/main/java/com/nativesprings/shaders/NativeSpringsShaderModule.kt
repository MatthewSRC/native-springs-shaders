package com.nativesprings.shaders

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class NativeSpringsShaderModule : Module() {
    override fun definition() = ModuleDefinition {
        // Sets the name of the module that JavaScript code will use to refer to the module
        Name("NativeSpringsShader")

        // Module initialization - register built-in shaders
        OnCreate {
            // Auto-register built-in shaders
            LiquidDistortionShader(appContext.reactContext!!)
            GlitchShader(appContext.reactContext!!)
            RippleShader(appContext.reactContext!!)
        }

        // Expose the shader view
        View(NativeSpringsShaderView::class) {
            // Shader name property (special - triggers shader loading)
            Prop("shaderName") { view: NativeSpringsShaderView, shaderName: String? ->
                view.shaderName = shaderName
            }

            // Generic parameters handler - replaces individual Prop() calls
            // Accepts a map of parameter name -> value pairs
            Prop("parameters") { view: NativeSpringsShaderView, params: Map<String, Any> ->
                view.setParameters(params)
            }

            // Configuration properties (not shader parameters)
            Prop("autoRefreshSnapshot") { view: NativeSpringsShaderView, autoRefresh: Boolean ->
                view.autoRefreshSnapshot = autoRefresh
            }

            Prop("snapshotRefreshInterval") { view: NativeSpringsShaderView, interval: Double ->
                view.snapshotRefreshInterval = interval
            }

            Prop("initialSnapshotDelay") { view: NativeSpringsShaderView, delay: Double ->
                view.initialSnapshotDelay = delay
            }

            // Method to manually refresh snapshot
            AsyncFunction("refreshSnapshot") { view: NativeSpringsShaderView ->
                view.refreshSnapshot()
            }
        }
    }
}
