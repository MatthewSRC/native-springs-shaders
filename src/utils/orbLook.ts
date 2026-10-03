/**
 * Look values for the Orb overlay per state, mode and confidence.
 */
import {
  ConversationMode,
  ConversationState,
  LookLayer,
  applyLayer,
  clamp,
} from './conversational';

export interface OrbLook {
  /** Ring radius relative to view height */
  radius: number;
  /** Breathing radius amplitude */
  breathAmount: number;
  /** Breathing cycle length in seconds */
  breathPeriod: number;
  /** Ring glow thickness multiplier */
  thickness: number;
  /** How strongly noise filaments bend the ring */
  dispersion: number;
  /** Filament falloff away from the ring - higher = more concentrated */
  spread: number;
  /** Chaotic mixing of the filament layers (0 - 1) */
  turbulence: number;
  /** Chromatic separation multiplier */
  chromatic: number;
  /** Fast edge shimmer (0 - 1) */
  shimmer: number;
  /** Mirror symmetry of the dispersion (0 - 1) */
  symmetry: number;
  /** Internal churn inside the dark center (0 - 1) */
  core: number;
  /** Brightness multiplier */
  brightness: number;
  /** Color saturation (0 - 1) */
  saturation: number;
  /** Motion speed multiplier */
  motion: number;
  /** Amount of speaking pulse (0 - 1) */
  speaking: number;
}

const BASE_LOOK: OrbLook = {
  radius: 0.23,
  breathAmount: 0.012,
  breathPeriod: 5.0,
  thickness: 1.0,
  dispersion: 1.0,
  spread: 14.0,
  turbulence: 0.15,
  chromatic: 1.0,
  shimmer: 0.0,
  symmetry: 0.0,
  core: 0.0,
  brightness: 1.0,
  saturation: 1.0,
  motion: 0.6,
  speaking: 0.0,
};

/** Flat, desaturated, nearly still ring. Overrides every mode. */
const ERROR_LOOK: OrbLook = {
  radius: 0.23,
  breathAmount: 0.003,
  breathPeriod: 8.0,
  thickness: 0.9,
  dispersion: 0.2,
  spread: 20.0,
  turbulence: 0.0,
  chromatic: 0.2,
  shimmer: 0.0,
  symmetry: 0.0,
  core: 0.0,
  brightness: 0.55,
  saturation: 0.1,
  motion: 0.08,
  speaking: 0.0,
};

const STATE_LAYERS: Record<Exclude<ConversationState, 'error'>, LookLayer<OrbLook>> = {
  // Slow breathing, steady dispersion, calm center
  idle: {},
  // Ring tightens, fringe sharpens and brightens, subtle inward pull
  listening: {
    add: { radius: -0.015, spread: 5.0, chromatic: 0.15, breathAmount: -0.005, turbulence: -0.05 },
    mul: { brightness: 1.12, motion: 1.2 },
  },
  // Center churns, dispersion turbulent and chromatic, pace quickens
  thinking: {
    add: { core: 1.0, turbulence: 0.2, chromatic: 0.5, dispersion: 0.25, shimmer: 0.15 },
    mul: { motion: 1.8, breathPeriod: 0.75 },
  },
  // Rhythmic edge brighten/dim, settled core
  speaking: {
    add: { speaking: 1.0 },
    mul: { motion: 1.3 },
  },
};

const MODE_LAYERS: Record<ConversationMode, LookLayer<OrbLook>> = {
  default: {},
  // Thicker ring, focused and concentrated dispersion
  focused: {
    add: { thickness: 0.45, spread: 8.0, dispersion: -0.3, turbulence: -0.08, chromatic: -0.2 },
  },
  // Balanced, mirrored dispersion with deliberate, slower breathing
  balanced: {
    add: { symmetry: 1.0 },
    mul: { breathPeriod: 1.35, motion: 0.8 },
  },
  // Refracted, unstable edges
  prismatic: {
    add: { chromatic: 0.9, shimmer: 0.6, turbulence: 0.12, dispersion: 0.15 },
  },
};

/**
 * Resolves state, mode and confidence into the Orb look targets sent to native.
 */
export function composeOrbLook(state: ConversationState, mode: ConversationMode, confidence: number): OrbLook {
  let look =
    state === 'error'
      ? { ...ERROR_LOOK }
      : applyLayer(applyLayer(BASE_LOOK, MODE_LAYERS[mode]), STATE_LAYERS[state]);

  // Low confidence: dimmer, softer dispersion, slightly thinner ring
  const c = clamp(confidence, 0, 1);
  look = applyLayer(look, {
    mul: {
      brightness: 0.65 + 0.35 * c,
      dispersion: 0.6 + 0.4 * c,
      thickness: 0.8 + 0.2 * c,
      chromatic: 0.7 + 0.3 * c,
      turbulence: 0.7 + 0.3 * c,
    },
  });

  look.turbulence = clamp(look.turbulence, 0, 1);
  look.shimmer = clamp(look.shimmer, 0, 1);
  look.symmetry = clamp(look.symmetry, 0, 1);
  look.core = clamp(look.core, 0, 1);
  look.saturation = clamp(look.saturation, 0, 1);
  look.speaking = clamp(look.speaking, 0, 1);
  look.chromatic = Math.max(look.chromatic, 0);
  look.dispersion = Math.max(look.dispersion, 0);
  look.breathAmount = Math.max(look.breathAmount, 0);

  return look;
}
