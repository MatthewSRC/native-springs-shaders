import React from 'react';
import { BaseShaderView, BaseShaderProps, ShaderViewRef } from './BaseShaderView';
import { GlitchParameters } from '../NativeSpringsShaders.types';

/**
 * Props for the Glitch shader effect.
 * Creates digital glitch artifacts with chromatic aberration and scanlines.
 */
export interface GlitchShaderProps extends Omit<BaseShaderProps, 'parameters'> {
  parameters?: GlitchParameters;
}

export const GlitchShader = React.forwardRef<ShaderViewRef, GlitchShaderProps>((props, ref) => {
  return <BaseShaderView ref={ref} shaderName="glitch" {...props} />;
});

GlitchShader.displayName = 'GlitchShader';
