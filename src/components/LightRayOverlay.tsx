import React, { useMemo } from 'react';
import { BaseOverlayView, BaseOverlayProps } from './BaseOverlayView';
import { LightRayParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from '../utils/color';

/**
 * Props for the Light Ray overlay effect.
 * Creates volumetric light rays emanating from a source point.
 */
export interface LightRayOverlayProps extends Omit<BaseOverlayProps, 'parameters'> {
  parameters?: LightRayParameters;
}

export const LightRayOverlay = React.forwardRef<any, LightRayOverlayProps>(
  ({ parameters, ...props }, ref) => {
    const normalizedParameters = useMemo(() => {
      if (!parameters) return parameters;

      const { color, ...rest } = parameters;
      if (color === undefined) return parameters;

      return {
        ...rest,
        color: normalizeColor(color),
      };
    }, [parameters]);

    return (
      <BaseOverlayView
        ref={ref}
        overlayName="lightRay"
        parameters={normalizedParameters}
        {...props}
      />
    );
  }
);

LightRayOverlay.displayName = 'LightRayOverlay';
