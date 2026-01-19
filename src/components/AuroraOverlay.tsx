import React, { useMemo } from 'react';
import { BaseOverlayView, BaseOverlayProps } from './BaseOverlayView';
import { AuroraParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from '../utils/color';

/**
 * Props for the Aurora overlay effect.
 * Creates a flowing, colorful aurora borealis animation.
 */
export interface AuroraOverlayProps extends Omit<BaseOverlayProps, 'parameters'> {
  parameters?: AuroraParameters;
}

export const AuroraOverlay = React.forwardRef<any, AuroraOverlayProps>(
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
        overlayName="aurora"
        parameters={normalizedParameters}
        {...props}
      />
    );
  }
);

AuroraOverlay.displayName = 'AuroraOverlay';
