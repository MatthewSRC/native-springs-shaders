import React from 'react';
import { OrbOverlay } from '@native-springs/shaders';
import { ConversationTester } from '../components/ConversationTester';
import { ORB_PALETTE } from '../components/palettes';

interface OrbOverlayScreenProps {
  onBack: () => void;
  onOpenDemo: () => void;
}

export const OrbOverlayScreen: React.FC<OrbOverlayScreenProps> = ({ onBack, onOpenDemo }) => (
  <ConversationTester
    title="Orb"
    Overlay={OrbOverlay}
    palette={ORB_PALETTE}
    defaultRenderScale={0.75}
    onBack={onBack}
    onOpenDemo={onOpenDemo}
  />
);
