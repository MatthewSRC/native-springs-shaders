import { requireNativeView } from 'expo';
import * as React from 'react';
import { ViewProps } from 'react-native';

const NativeView = requireNativeView<any>('NativeSpringsShaderOverlay');

/**
 * Base props shared by all overlay components.
 */
export interface BaseOverlayProps extends ViewProps {
  /**
   * Parameters object for configuring the overlay effect.
   */
  parameters?: Record<string, any>;

  /**
   * When true, the overlay is completely disabled and only renders children.
   * @default false
   */
  disabled?: boolean;

  /**
   * When true, all instances of this overlay across the app share a single
   * animation clock. No matter how many <CloudsOverlay unique /> components
   * are mounted (different screens, tabs, etc.), they all show the same
   * animation frame and time advances only once per vsync.
   * @default false
   */
  unique?: boolean;
}

/**
 * Internal props interface for BaseOverlayView.
 */
interface InternalOverlayProps extends BaseOverlayProps {
  overlayName: string;
}

export const BaseOverlayView = React.forwardRef<any, InternalOverlayProps>((props, ref) => {
  const { overlayName, parameters, disabled = false, ...otherProps } = props;

  if (disabled) {
    return <>{props.children}</>;
  }

  return <NativeView ref={ref} overlayName={overlayName} parameters={parameters} {...otherProps} />;
});

BaseOverlayView.displayName = 'BaseOverlayView';
