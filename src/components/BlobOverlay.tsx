import React from "react";
import { BaseOverlayView } from "./BaseOverlayView";
import {
  ConversationalOverlayProps,
  ConversationalOverlayRef,
  useConversationalParameters,
} from "../utils/conversational";
import { composeBlobLook } from "../utils/blobLook";

export type BlobOverlayRef = ConversationalOverlayRef;

/**
 * Props for the Blob overlay effect.
 * Creates a glowing, folding 3D blob with animated conversational states.
 */
export type BlobOverlayProps = ConversationalOverlayProps;

export const BlobOverlay = React.forwardRef<BlobOverlayRef, BlobOverlayProps>(
  ({ parameters, state, mode, confidence, speechLevel, ...props }, ref) => {
    const normalizedParameters = useConversationalParameters(
      ref,
      { parameters, state, mode, confidence, speechLevel },
      composeBlobLook,
    );

    return (
      <BaseOverlayView
        overlayName="blob"
        parameters={normalizedParameters}
        {...props}
      />
    );
  },
);

BlobOverlay.displayName = "BlobOverlay";
