import React, { useMemo } from 'react';
import { BaseOverlayView, BaseOverlayProps } from './BaseOverlayView';
import { NeonParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from '../utils/color';

/**
 * Props for the Neon overlay effect.
 * Creates an animated glowing neon border that encapsulates content.
 */
export interface NeonOverlayProps extends Omit<BaseOverlayProps, 'parameters'> {
  parameters?: NeonParameters;
}

export const NeonOverlay = React.forwardRef<any, NeonOverlayProps>(
  ({ parameters, ...props }, ref) => {
    const normalizedParameters = useMemo(() => {
      if (!parameters) return parameters;

      const { color, secondaryColor, ...rest } = parameters;

      const result: Record<string, any> = { ...rest };

      if (color !== undefined) {
        result.color = normalizeColor(color);
      }

      if (secondaryColor !== undefined) {
        result.secondaryColor = normalizeColor(secondaryColor);
      }

      return result;
    }, [parameters]);

    return (
      <BaseOverlayView
        ref={ref}
        overlayName="neon"
        parameters={normalizedParameters}
        {...props}
      />
    );
  }
);

NeonOverlay.displayName = 'NeonOverlay';
