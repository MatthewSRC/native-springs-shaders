import React, { useMemo } from 'react';
import { BaseOverlayView, BaseOverlayProps } from './BaseOverlayView';
import { FireworksParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from '../utils/color';

/**
 * Props for the Fireworks overlay effect.
 * Creates animated firework explosions with customizable colors and patterns.
 */
export interface FireworksOverlayProps extends Omit<BaseOverlayProps, 'parameters'> {
  parameters?: FireworksParameters;
}

export const FireworksOverlay = React.forwardRef<any, FireworksOverlayProps>(
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
        overlayName="fireworks"
        parameters={normalizedParameters}
        {...props}
      />
    );
  }
);

FireworksOverlay.displayName = 'FireworksOverlay';
