import { requireNativeView } from 'expo';
import * as React from 'react';

import { ShaderViewProps } from './NativeSpringsShaders.types';

const NativeView =
  requireNativeView<ShaderViewProps>('NativeSpringsShader');

export interface ShaderViewRef {
  /**
   * Manually refresh the cached snapshot for animated shaders.
   * Useful when children content changes during animation.
   */
  refreshSnapshot: () => void;
}

const ShaderView = React.forwardRef<ShaderViewRef, ShaderViewProps>((props, ref) => {
  const { shaderName, parameters, ...otherProps } = props;
  const nativeRef = React.useRef<any>(null);

  React.useImperativeHandle(ref, () => ({
    refreshSnapshot: () => {
      // @ts-ignore - AsyncFunction exposed from native module
      nativeRef.current?.refreshSnapshot?.();
    },
  }));

  // @ts-ignore - ref is supported but not in requireNativeView types
  return <NativeView ref={nativeRef} shaderName={shaderName} parameters={parameters} {...otherProps} />;
});

ShaderView.displayName = 'ShaderView';

export default ShaderView;
