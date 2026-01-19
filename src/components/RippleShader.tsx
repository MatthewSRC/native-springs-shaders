import React, { useMemo } from 'react';
import { BaseShaderView, BaseShaderProps, ShaderViewRef } from './BaseShaderView';
import { RippleParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from '../utils/color';

/**
 * Props for the Ripple shader effect.
 * Creates interactive water ripple distortions at touch points.
 */
export interface RippleShaderProps extends Omit<BaseShaderProps, 'parameters'> {
  parameters?: RippleParameters;
}

export const RippleShader = React.forwardRef<ShaderViewRef, RippleShaderProps>(
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
        shaderName="ripple"
        parameters={normalizedParameters}
        {...props}
      />
    );
  }
);

RippleShader.displayName = 'RippleShader';
