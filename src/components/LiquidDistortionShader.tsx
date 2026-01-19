import React, { useMemo } from 'react';
import { BaseShaderView, BaseShaderProps, ShaderViewRef } from './BaseShaderView';
import { LiquidDistortionParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from '../utils/color';

/**
 * Props for the Liquid Distortion shader effect.
 * Creates flowing liquid-like distortions with customizable flow patterns.
 */
export interface LiquidDistortionShaderProps extends Omit<BaseShaderProps, 'parameters'> {
  parameters?: LiquidDistortionParameters;
}

export const LiquidDistortionShader = React.forwardRef<ShaderViewRef, LiquidDistortionShaderProps>(
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
      <BaseShaderView
        ref={ref}
        shaderName="liquidDistortion"
        parameters={normalizedParameters}
        {...props}
      />
    );
  }
);

LiquidDistortionShader.displayName = 'LiquidDistortionShader';
