import { requireNativeView } from 'expo';
import * as React from 'react';

import { OverlayViewProps } from './NativeSpringsShaders.types';

const NativeView =
  requireNativeView<OverlayViewProps>('NativeSpringsShaderOverlay');

export default function OverlayView(props: OverlayViewProps) {
  const { overlayName, parameters, ...otherProps } = props;
  return <NativeView overlayName={overlayName} parameters={parameters} {...otherProps} />;
}

export type OverlayViewRef = any;
