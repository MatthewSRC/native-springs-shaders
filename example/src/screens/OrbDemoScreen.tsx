import React from 'react';
import { OrbOverlay } from '@native-springs/shaders';
import { AssistantDemo } from '../components/AssistantDemo';
import { ORB_PALETTE } from '../components/palettes';

// Sized so the ring and its filaments stay inside the view in every state
const OVERLAY_PARAMETERS = { scale: 0.9 };

interface OrbDemoScreenProps {
  onBack: () => void;
}

export const OrbDemoScreen: React.FC<OrbDemoScreenProps> = ({ onBack }) => (
  <AssistantDemo
    Overlay={OrbOverlay}
    palette={ORB_PALETTE}
    overlayParameters={OVERLAY_PARAMETERS}
    onBack={onBack}
  />
);
