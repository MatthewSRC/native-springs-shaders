import React, { useMemo } from 'react';
import { BaseOverlayView, BaseOverlayProps } from './BaseOverlayView';
import { LiquidMetalParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from '../utils/color';

/**
 * Props for the Liquid Metal overlay effect.
 * Creates a flowing, chrome-like metallic border effect.
 */
export interface LiquidMetalOverlayProps extends Omit<BaseOverlayProps, 'parameters'> {
  parameters?: LiquidMetalParameters;
}

export const LiquidMetalOverlay = React.forwardRef<any, LiquidMetalOverlayProps>(
  ({ parameters, ...props }, ref) => {
    const normalizedParameters = useMemo(() => {
      if (!parameters) return parameters;

      const {
        baseColor,
        highlightColor,
        stripeCount,
        flowOffset,
        flowAngle,
        specular,
        ...rest
      } = parameters;

      const result: Record<string, any> = { ...rest };

      if (baseColor !== undefined) {
        result.baseColor = normalizeColor(baseColor);
      }

      if (highlightColor !== undefined) {
        result.highlightColor = normalizeColor(highlightColor);
      }

      if (stripeCount !== undefined) {
        result.repetition = stripeCount;
      }

      if (flowOffset !== undefined) {
        result.flowOffsetX = flowOffset[0];
        result.flowOffsetY = flowOffset[1];
      }

      if (flowAngle !== undefined) {
        result.flowAngle = (flowAngle * Math.PI) / 180;
      }

      if (specular !== undefined) {
        if (specular.intensity !== undefined) {
          result.specularIntensity = specular.intensity;
        }
        if (specular.position !== undefined) {
          result.specularPositionX = specular.position[0];
          result.specularPositionY = specular.position[1];
        }
        if (specular.size !== undefined) {
          result.specularSize = specular.size;
        }
      }

      return result;
    }, [parameters]);

    return (
      <BaseOverlayView
        ref={ref}
        overlayName="liquidMetal"
        parameters={normalizedParameters}
        {...props}
      />
    );
  }
);

LiquidMetalOverlay.displayName = 'LiquidMetalOverlay';
