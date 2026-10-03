import React from 'react';
import { BlobOverlay } from '@native-springs/shaders';
import { ConversationTester } from '../components/ConversationTester';
import { BLOB_PALETTE } from '../components/palettes';

interface BlobOverlayScreenProps {
  onBack: () => void;
  onOpenDemo: () => void;
}

export const BlobOverlayScreen: React.FC<BlobOverlayScreenProps> = ({ onBack, onOpenDemo }) => (
  <ConversationTester
    title="Blob"
    Overlay={BlobOverlay}
    palette={BLOB_PALETTE}
    defaultRenderScale={0.5}
    onBack={onBack}
    onOpenDemo={onOpenDemo}
  />
);
