import React, { useMemo } from "react";
import { BaseOverlayView, BaseOverlayProps } from "./BaseOverlayView";
import { CloudsParameters } from "../NativeSpringsShaders.types";
import { normalizeColor } from "../utils/color";

/**
 * Props for the Clouds overlay effect.
 * Creates soft, blurry gradient blobs for ambient backgrounds.
 */
export interface CloudsOverlayProps extends Omit<
  BaseOverlayProps,
  "parameters"
> {
  parameters?: CloudsParameters;
}

export const CloudsOverlay = React.forwardRef<any, CloudsOverlayProps>(
  ({ parameters, ...props }, ref) => {
    const normalizedParameters = useMemo(() => {
      if (!parameters) return parameters;

      const { color, secondaryColor, tertiaryColor, ...rest } = parameters;

      const result: Record<string, any> = { ...rest };

      if (color !== undefined) {
        result.color = normalizeColor(color);
      }

      if (secondaryColor !== undefined) {
        result.secondaryColor = normalizeColor(secondaryColor);
      }

      if (tertiaryColor !== undefined) {
        result.tertiaryColor = normalizeColor(tertiaryColor);
      }

      return result;
    }, [parameters]);

    return (
      <BaseOverlayView
        ref={ref}
        overlayName="clouds"
        parameters={normalizedParameters}
        {...props}
      />
    );
  },
);

CloudsOverlay.displayName = "CloudsOverlay";
