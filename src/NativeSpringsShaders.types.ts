import { ViewProps } from 'react-native';
import { ColorValue } from './utils/color';

export interface ShaderConfig {
  name: string;
  [key: string]: any;
}

export interface OverlayConfig {
  name: string;
  [key: string]: any;
}

export interface ShaderErrorEvent {
  code: string;
  message: string;
  shaderName?: string;
  [key: string]: any;
}

export interface AuroraParameters {
  /** Controls the overall intensity/opacity (0.0 - 1.0+) */
  intensity?: number;
  /**
   * Color tint - accepts multiple formats:
   * - Normalized RGB: [0.3, 0.7, 1.0]
   * - RGB 0-255: [77, 179, 255]
   * - Hex string: '#4DB3FF' or '4DB3FF'
   */
  color?: ColorValue;
  /** Movement direction as [x, y] */
  direction?: [number, number];
  /** Edge fade intensity (0.0 - 1.0) */
  borderFade?: number;
}

export interface SparklesParameters {
  /** Controls the overall intensity/opacity (0.0 - 1.0+) */
  intensity?: number;
  /**
   * Sparkle color - accepts multiple formats:
   * - Normalized RGB: [1.0, 0.84, 0.0]
   * - RGB 0-255: [255, 215, 0]
   * - Hex string: '#FFD700'
   */
  color?: ColorValue;
  /** Sparkle density (0.0 - 1.0+) */
  density?: number;
  /** Sparkle size multiplier */
  size?: number;
  /** Animation speed multiplier */
  speed?: number;
  /** Use rainbow colors instead of fixed color */
  colorize?: boolean;
  /** Twinkle fade in/out speed (0.0 - 2.0+) */
  twinkleSpeed?: number;
  /** Overall brightness multiplier (0.0 - 5.0+) */
  brightnessMultiplier?: number;
}

export interface FireSparksParameters {
  /** Controls the overall intensity/opacity (0.0 - 1.0+) */
  intensity?: number;
  /**
   * Spark color - accepts multiple formats:
   * - Normalized RGB: [1.0, 0.5, 0.0]
   * - RGB 0-255: [255, 128, 0]
   * - Hex string: '#FF8000'
   */
  color?: ColorValue;
  /** Movement direction as [x, y] */
  direction?: [number, number];
  /** Edge fade intensity (0.0 - 1.0) */
  borderFade?: number;
  /** Distance sparks travel before fading */
  travelDistance?: number;
  /** Size of individual spark particles */
  particleSize?: number;
  /** Animation speed multiplier (particle rotation) */
  animationSpeed?: number;
  /** Smoke trail intensity (0.0 - 2.0+) */
  smokeIntensity?: number;
  /** Particle glow/bloom strength (0.0 - 3.0+) */
  particleBloom?: number;
  /** Horizontal flow/drift speed (0.2 - 3.0) */
  movementSpeed?: number;
}

export interface FireworksParameters {
  /** Controls the overall intensity/opacity (0.0 - 1.0+) */
  intensity?: number;
  /**
   * Firework color - accepts multiple formats:
   * - Normalized RGB: [1.0, 0.5, 0.0]
   * - RGB 0-255: [255, 128, 0]
   * - Hex string: '#FF8000'
   */
  color?: ColorValue;
  /** Animation speed multiplier */
  speed?: number;
  /** Minimum explosion size */
  minSize?: number;
  /** Maximum explosion size */
  maxSize?: number;
  /** Minimum explosion duration in seconds */
  minDuration?: number;
  /** Maximum explosion duration in seconds */
  maxDuration?: number;
  /** Spawn frequency multiplier */
  frequency?: number;
  /** Use custom color instead of rainbow colors */
  useCustomColor?: boolean;
  /** Particle edge sharpness (0.0 - 1.0+) */
  sharpness?: number;
  /** Number of particles per explosion (20 - 100) */
  particleCount?: number;
  /** Gravity strength affecting particle fall (0.0 - 2.0) */
  gravity?: number;
}

export interface LightRayParameters {
  /** Controls the overall intensity/opacity (0.0 - 1.0+) */
  intensity?: number;
  /**
   * Light ray color - accepts multiple formats:
   * - Normalized RGB: [1.0, 0.95, 0.8]
   * - RGB 0-255: [255, 242, 204]
   * - Hex string: '#FFF2CC'
   */
  color?: ColorValue;
  /** Light source position as [x, y] */
  rayPosition?: [number, number];
  /** Animation speed multiplier */
  speed?: number;
  /** Number of light rays */
  numRays?: number;
  /** Depth-based intensity falloff */
  depthAttenuation?: number;
  /** Length of light rays */
  rayLength?: number;
  /** Ray direction as [x, y] */
  rayDirection?: [number, number];
  /** Width/spread of light rays (0.5 - 3.0) */
  rayWidth?: number;
}

export interface RippleParameters {
  /** Controls the overall intensity/opacity (0.0 - 1.0+) */
  intensity?: number;
  /**
   * Ripple color - accepts multiple formats:
   * - Normalized RGB: [0.3, 0.7, 1.0]
   * - RGB 0-255: [77, 179, 255]
   * - Hex string: '#4DB3FF'
   */
  color?: ColorValue;
  /** Touch point as [x, y] */
  touchPoint?: [number, number];
  /** Time since touch started */
  touchTime?: number;
  /** Wave frequency */
  frequency?: number;
  /** How quickly ripples fade (0.0 - 1.0) */
  damping?: number;
  /** Ripple variant: 'standard', 'realistic' or numeric value 0.0-1.0 */
  rippleVariant?: 'standard' | 'realistic' | 0 | 1;
  /** Wave speed */
  speed?: number;
  /** Width of wave ring (realistic variant) */
  ringWidth?: number;
  /** Wave deceleration rate (realistic variant) */
  slowdownFactor?: number;
  /** Image distortion strength (0.0 - 0.2) */
  displacementStrength?: number;
  /** Colored highlight intensity (0.0 - 0.5) */
  highlightStrength?: number;
}

export interface LiquidDistortionParameters {
  /** Controls the overall intensity/opacity (0.0 - 1.0+) */
  intensity?: number;
  /** Animation speed multiplier */
  speed?: number;
  /** Wave pattern scale */
  waveScale?: number;
  /** Turbulence intensity */
  turbulence?: number;
  /** Chromatic aberration intensity */
  chromaticAberration?: number;
  /** Flow direction as [x, y] */
  flowDirection?: [number, number];
  /**
   * Liquid color tint - accepts multiple formats:
   * - Normalized RGB: [0.85, 0.95, 1.0]
   * - RGB 0-255: [217, 242, 255]
   * - Hex string: '#D9F2FF'
   */
  color?: ColorValue;
  /** Liquid variant: 'water', 'glass', 'oil' or numeric value 0.0-2.0 */
  liquidVariant?: 'water' | 'glass' | 'oil' | 0 | 1 | 2;
  /** Shine/highlight strength (0.0 - 1.0) */
  shineStrength?: number;
  /** Color tint strength (0.0 - 1.0) */
  colorTintStrength?: number;
}

export interface GlitchParameters {
  /** Controls the overall intensity/opacity (0.0 - 1.0+) */
  intensity?: number;
  /** Chromatic aberration intensity */
  chromaticAberration?: number;
  /** Scanline intensity */
  scanlineIntensity?: number;
  /** Glitch occurrence frequency (0.0 - 1.0) */
  glitchFrequency?: number;
  /** Size of glitch blocks in pixels */
  blockSize?: number;
  /** Film grain/noise intensity (0.0 - 0.2) */
  grainIntensity?: number;
  /** Edge vignette darkness (0.0 - 1.0) */
  vignetteStrength?: number;
  /** RGB separation spread multiplier (0.5 - 3.0) */
  chromaticSpread?: number;
}

export type ShaderViewProps = ViewProps & {
  shaderName?: string;
  parameters?: Record<string, any>;

  autoRefreshSnapshot?: boolean;
  snapshotRefreshInterval?: number;
  initialSnapshotDelay?: number;

  onShaderError?: (event: ShaderErrorEvent) => void;
};

export type OverlayViewProps = ViewProps & {
  overlayName?: string;
  parameters?: Record<string, any>;
};
