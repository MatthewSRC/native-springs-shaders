import React from "react";
import { BaseOverlayView } from "./BaseOverlayView";
import {
  ConversationalOverlayProps,
  ConversationalOverlayRef,
  useConversationalParameters,
} from "../utils/conversational";
import { composeOrbLook } from "../utils/orbLook";

export type OrbOverlayRef = ConversationalOverlayRef;

/**
 * Props for the Orb overlay effect.
 * Creates a glowing, pulsing energy orb with animated conversational states.
 */
export type OrbOverlayProps = ConversationalOverlayProps;

export const OrbOverlay = React.forwardRef<OrbOverlayRef, OrbOverlayProps>(
  ({ parameters, state, mode, confidence, speechLevel, ...props }, ref) => {
    const normalizedParameters = useConversationalParameters(
      ref,
      { parameters, state, mode, confidence, speechLevel },
      composeOrbLook,
    );

    return (
      <BaseOverlayView
        overlayName="orb"
        parameters={normalizedParameters}
        {...props}
      />
    );
  },
);

OrbOverlay.displayName = "OrbOverlay";
