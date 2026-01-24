import ExpoModulesCore

public class NativeSpringsShaderModule: Module {

  public func definition() -> ModuleDefinition {
    Name("NativeSpringsShader")

    OnCreate {

      _ = LiquidDistortionShader()
      _ = GlitchShader()
      _ = RippleShader()
      _ = FireSparksOverlay()
      _ = AuroraOverlay()
      _ = FireworksOverlay()
      _ = LightRayOverlay()
      _ = SparklesOverlay()
      _ = LiquidMetalOverlay()
    }

    View(NativeSpringsShaderView.self) {
      Events("onShaderError")

      Prop("shaderName") { (view: NativeSpringsShaderView, name: String?) in
        view.shaderName = name
      }

      Prop("parameters") { (view: NativeSpringsShaderView, params: [String: Any]) in
        view.setParameters(params)
      }

      Prop("autoRefreshSnapshot") { (view: NativeSpringsShaderView, autoRefresh: Bool) in
        view.autoRefreshSnapshot = autoRefresh
      }

      Prop("snapshotRefreshInterval") { (view: NativeSpringsShaderView, interval: Double) in
        view.snapshotRefreshInterval = interval
      }

      Prop("initialSnapshotDelay") { (view: NativeSpringsShaderView, delay: Double) in
        view.initialSnapshotDelay = delay
      }

      AsyncFunction("refreshSnapshot") { (view: NativeSpringsShaderView) in
        view.refreshSnapshot()
      }
    }
  }
}
