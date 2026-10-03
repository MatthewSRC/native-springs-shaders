import React from 'react';
import { BlobOverlay } from '@native-springs/shaders';
import { AssistantDemo } from '../components/AssistantDemo';
import { BLOB_PALETTE } from '../components/palettes';

// Sized so the blob stays inside the view's width in every state and mode
const OVERLAY_PARAMETERS = { scale: 0.65 };

interface BlobDemoScreenProps {
  onBack: () => void;
}

export const BlobDemoScreen: React.FC<BlobDemoScreenProps> = ({ onBack }) => (
  <AssistantDemo
    Overlay={BlobOverlay}
    palette={BLOB_PALETTE}
    overlayParameters={OVERLAY_PARAMETERS}
    onBack={onBack}
  />
);
