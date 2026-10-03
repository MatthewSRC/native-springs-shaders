/**
 * Shared state machine for conversational overlays (Orb, Blob).
 *
 * Every state, mode and confidence level resolves to a "look": a set of
 * numeric targets the native side springs toward. Each overlay defines its own
 * look values, while states, modes, moments and transition pacing are shared.
 */
import React, { useImperativeHandle, useMemo, useState } from 'react';
import type { BaseOverlayProps } from '../components/BaseOverlayView';
import type { ConversationalParameters } from '../NativeSpringsShaders.types';
import { normalizeColor } from './color';

/** Core conversational state */
export type ConversationState = 'idle' | 'listening' | 'thinking' | 'speaking' | 'error';

/**
 * Visual mode, layered on top of the state:
 * - `default`: baseline look
 * - `focused`: thicker, concentrated and calmer
 * - `balanced`: mirrored left to right, slower and more deliberate
 * - `prismatic`: more chromatic and unstable, shimmering edges
 */
export type ConversationMode = 'default' | 'focused' | 'balanced' | 'prismatic';

/** One-shot moments fired through the component ref */
export type ConversationMoment = 'flash' | 'exhale' | 'ripple';

/**
 * Imperative handle for conversational overlays.
 */
export interface ConversationalOverlayRef {
  /**
   * Plays a one-shot moment:
   * - `flash`: distinct brighten-and-hold beat
   * - `exhale`: slower pulse with a moment of extra brightness
   * - `ripple`: single soft outward ripple
   */
  trigger: (moment: ConversationMoment) => void;
}

/**
 * Props shared by conversational overlays.
 */
export interface ConversationalOverlayProps extends Omit<BaseOverlayProps, 'parameters'> {
  parameters?: ConversationalParameters;
  /** Core conversational state @default 'idle' */
  state?: ConversationState;
  /** Visual mode layered on top of the state @default 'default' */
  mode?: ConversationMode;
  /** How well the assistant knows the user (0.0 - 1.0), low = dimmer and softer @default 1 */
  confidence?: number;
  /**
   * Optional speech level (0.0 - 1.0) steering the speaking pulse, e.g. smoothed
   * TTS amplitude. When omitted, a built-in speech-paced rhythm is used.
   */
  speechLevel?: number;
}

export type ComposeLook<L> = (state: ConversationState, mode: ConversationMode, confidence: number) => L;

export interface LookLayer<L> {
  /** Added to the look */
  add?: Partial<L>;
  /** Multiplied into the look, applied after `add` */
  mul?: Partial<L>;
}

export function applyLayer<L extends Record<keyof L, number>>(look: L, layer: LookLayer<L>): L {
  const result = { ...look };
  for (const [key, value] of Object.entries(layer.add ?? {})) {
    result[key as keyof L] = (result[key as keyof L] + (value as number)) as L[keyof L];
  }
  for (const [key, value] of Object.entries(layer.mul ?? {})) {
    result[key as keyof L] = (result[key as keyof L] * (value as number)) as L[keyof L];
  }
  return result;
}

export const clamp = (value: number, min: number, max: number) => Math.min(Math.max(value, min), max);

/**
 * Transition time multiplier for a state/mode change.
 */
export function getTransitionScale(
  from: { state: ConversationState; mode: ConversationMode },
  to: { state: ConversationState; mode: ConversationMode },
): number {
  if (to.state === 'error') return 1.6;
  if (from.state === 'error') return 1.4;
  // Leaving a mode: quick, gentle settle back to baseline
  if (to.mode === 'default' && from.mode !== 'default') return 0.6;
  return 1.0;
}

/**
 * Resolves conversational props into the native parameter map and exposes
 * `trigger` on the ref.
 */
export function useConversationalParameters<L extends object>(
  ref: React.Ref<ConversationalOverlayRef>,
  props: Pick<ConversationalOverlayProps, 'parameters' | 'state' | 'mode' | 'confidence' | 'speechLevel'>,
  composeLook: ComposeLook<L>,
): Record<string, any> {
  const { parameters, state = 'idle', mode = 'default', confidence = 1, speechLevel } = props;

  const [triggers, setTriggers] = useState({ flash: 0, exhale: 0, ripple: 0 });
  const [previous, setPrevious] = useState({ state, mode });
  const [transitionScale, setTransitionScale] = useState(1);

  // Adjust during render so the transition speed lands in the same native
  // update as the new targets.
  if (previous.state !== state || previous.mode !== mode) {
    setPrevious({ state, mode });
    setTransitionScale(getTransitionScale(previous, { state, mode }));
  }

  useImperativeHandle(
    ref,
    () => ({
      trigger: (moment) => setTriggers((t) => ({ ...t, [moment]: t[moment] + 1 })),
    }),
    [],
  );

  return useMemo(() => {
    const {
      color,
      secondaryColor,
      transitionDuration = 0.7,
      colorTransitionDuration = 0.8,
      ...rest
    } = parameters ?? {};

    const result: Record<string, any> = {
      ...rest,
      ...composeLook(state, mode, confidence),
      transitionTime: transitionDuration * transitionScale,
      colorTransitionTime: colorTransitionDuration,
      speechLevel: speechLevel ?? -1,
      flashTrigger: triggers.flash,
      exhaleTrigger: triggers.exhale,
      rippleTrigger: triggers.ripple,
    };

    if (color !== undefined) {
      result.color = normalizeColor(color);
    }

    if (secondaryColor !== undefined) {
      result.secondaryColor = normalizeColor(secondaryColor);
    }

    return result;
  }, [parameters, state, mode, confidence, speechLevel, transitionScale, triggers, composeLook]);
}
