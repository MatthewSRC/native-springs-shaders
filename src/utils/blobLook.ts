/**
 * Look values for the Blob overlay per state, mode and confidence.
 */
import {
  ConversationMode,
  ConversationState,
  LookLayer,
  applyLayer,
  clamp,
} from './conversational';

export interface BlobLook {
  /** Shell radius of the shape */
  radius: number;
  /** Breathing radius amplitude */
  breathAmount: number;
  /** Breathing cycle length in seconds */
  breathPeriod: number;
  /** Glow exposure - higher = wider, fuller halo */
  thickness: number;
  /** How strongly the shape folds as it rotates - lower = calmer, more concentrated */
  twist: number;
  /** Blend from the two-color gradient toward rainbow coloring (0 - 1) */
  iridescence: number;
  /** Fast unstable flicker of the folds and colors (0 - 1) */
  shimmer: number;
  /** Mirror symmetry left to right (0 - 1) */
  symmetry: number;
  /** Churn across the middle of the shape (0 - 1) */
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

const BASE_LOOK: BlobLook = {
  radius: 1.5,
  breathAmount: 0.06,
  breathPeriod: 5.0,
  thickness: 1.0,
  twist: 2.0,
  iridescence: 0.15,
  shimmer: 0.0,
  symmetry: 0.0,
  core: 0.0,
  brightness: 1.0,
  saturation: 1.0,
  motion: 0.6,
  speaking: 0.0,
};

/** Flat, desaturated, nearly still shape. Overrides every mode. */
const ERROR_LOOK: BlobLook = {
  radius: 1.45,
  breathAmount: 0.015,
  breathPeriod: 8.0,
  thickness: 0.8,
  twist: 0.6,
  iridescence: 0.0,
  shimmer: 0.0,
  symmetry: 0.0,
  core: 0.0,
  brightness: 0.5,
  saturation: 0.1,
  motion: 0.08,
  speaking: 0.0,
};

const STATE_LAYERS: Record<Exclude<ConversationState, 'error'>, LookLayer<BlobLook>> = {
  // Slow breathing, gentle folding, calm middle
  idle: {},
  // Shape tightens, halo sharpens and brightens, subtle inward pull
  listening: {
    add: { radius: -0.1, twist: -0.2, iridescence: 0.1, breathAmount: -0.025 },
    mul: { thickness: 0.85, brightness: 1.15, motion: 1.2 },
  },
  // Middle churns, folding turbulent and chromatic, pace quickens
  thinking: {
    add: { core: 1.0, twist: 0.8, iridescence: 0.35, shimmer: 0.15 },
    mul: { motion: 1.8, breathPeriod: 0.75 },
  },
  // Rhythmic brighten/dim, settled middle
  speaking: {
    add: { speaking: 1.0 },
    mul: { motion: 1.3 },
  },
};

const MODE_LAYERS: Record<ConversationMode, LookLayer<BlobLook>> = {
  default: {},
  // Fuller glow, calmer and more concentrated folding
  focused: {
    add: { thickness: 0.6, twist: -0.7, iridescence: -0.1 },
  },
  // Mirrored, balanced shape with deliberate, slower breathing
  balanced: {
    add: { symmetry: 1.0 },
    mul: { breathPeriod: 1.35, motion: 0.8 },
  },
  // Refracted, unstable folds and colors
  prismatic: {
    add: { iridescence: 0.6, shimmer: 0.6, twist: 0.4 },
  },
};

/**
 * Resolves state, mode and confidence into the Blob look targets sent to native.
 */
export function composeBlobLook(state: ConversationState, mode: ConversationMode, confidence: number): BlobLook {
  let look =
    state === 'error'
      ? { ...ERROR_LOOK }
      : applyLayer(applyLayer(BASE_LOOK, MODE_LAYERS[mode]), STATE_LAYERS[state]);

  // Low confidence: dimmer, softer folding, slimmer halo
  const c = clamp(confidence, 0, 1);
  look = applyLayer(look, {
    mul: {
      brightness: 0.65 + 0.35 * c,
      twist: 0.7 + 0.3 * c,
      thickness: 0.75 + 0.25 * c,
      iridescence: 0.7 + 0.3 * c,
    },
  });

  look.iridescence = clamp(look.iridescence, 0, 1);
  look.shimmer = clamp(look.shimmer, 0, 1);
  look.symmetry = clamp(look.symmetry, 0, 1);
  look.core = clamp(look.core, 0, 1);
  look.saturation = clamp(look.saturation, 0, 1);
  look.speaking = clamp(look.speaking, 0, 1);
  look.twist = Math.max(look.twist, 0);
  look.breathAmount = Math.max(look.breathAmount, 0);

  return look;
}
