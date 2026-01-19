import React, { useMemo } from 'react';
import { BaseOverlayView, BaseOverlayProps } from './BaseOverlayView';
import { FireSparksParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from '../utils/color';

/**
 * Props for the Fire Sparks overlay effect.
 * Creates an animated fire particle effect with floating sparks.
 */
export interface FireSparksOverlayProps extends Omit<BaseOverlayProps, 'parameters'> {
  parameters?: FireSparksParameters;
}

export const FireSparksOverlay = React.forwardRef<any, FireSparksOverlayProps>(
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
        overlayName="fireSparks"
        parameters={normalizedParameters}
        {...props}
      />
    );
  }
);

FireSparksOverlay.displayName = 'FireSparksOverlay';
