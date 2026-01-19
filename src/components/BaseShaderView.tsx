import { requireNativeView } from 'expo';
import * as React from 'react';
import { ViewProps } from 'react-native';
import { ShaderErrorEvent } from '../NativeSpringsShaders.types';

const NativeView = requireNativeView<any>('NativeSpringsShader');

export interface ShaderViewRef {
  refreshSnapshot: () => void;
}

export interface BaseShaderProps extends ViewProps {
  /**
   * Parameters object for configuring the shader effect.
   */
  parameters?: Record<string, any>;

  /**
   * When true, the shader is completely disabled and only renders children.
   * @default false
   */
  disabled?: boolean;

  /**
   * Automatically refresh the shader snapshot at regular intervals.
   * @default false
   */
  autoRefreshSnapshot?: boolean;

  /**
   * Interval in milliseconds for automatic snapshot refresh.
   * @default 1000
   */
  snapshotRefreshInterval?: number;

  /**
   * Initial delay in milliseconds before first snapshot.
   * @default 100
   */
  initialSnapshotDelay?: number;

  /**
   * Callback when a shader error occurs.
   */
  onShaderError?: (event: ShaderErrorEvent) => void;
}

interface InternalShaderProps extends BaseShaderProps {
  shaderName: string;
}

export const BaseShaderView = React.forwardRef<ShaderViewRef, InternalShaderProps>((props, ref) => {
  const { shaderName, parameters, disabled = false, ...otherProps } = props;
  const nativeRef = React.useRef<any>(null);

  React.useImperativeHandle(ref, () => ({
    refreshSnapshot: () => {
      nativeRef.current?.refreshSnapshot?.();
    },
  }));

  if (disabled) {
    return <>{props.children}</>;
  }

  return <NativeView ref={nativeRef} shaderName={shaderName} parameters={parameters} {...otherProps} />;
});

BaseShaderView.displayName = 'BaseShaderView';
