import ExpoModulesCore

public class NativeSpringsShaderOverlayModule: Module {

  public func definition() -> ModuleDefinition {
    Name("NativeSpringsShaderOverlay")

    View(NativeSpringsShaderOverlayView.self) {
      Prop("overlayName") { (view: NativeSpringsShaderOverlayView, name: String?) in
        view.overlayName = name
      }


      Prop("parameters") { (view: NativeSpringsShaderOverlayView, params: [String: Any]) in
        view.setParameters(params)
      }
    }
  }
}
