import React, { useMemo } from 'react';
import { BaseOverlayView, BaseOverlayProps } from './BaseOverlayView';
import { SparklesParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from '../utils/color';

/**
 * Props for the Sparkles overlay effect.
 * Creates twinkling star-like particles across the view.
 */
export interface SparklesOverlayProps extends Omit<BaseOverlayProps, 'parameters'> {
  parameters?: SparklesParameters;
}

export const SparklesOverlay = React.forwardRef<any, SparklesOverlayProps>(
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
        overlayName="sparkles"
        parameters={normalizedParameters}
        {...props}
      />
    );
  }
);

SparklesOverlay.displayName = 'SparklesOverlay';
