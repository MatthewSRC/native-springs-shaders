# BlobOverlay

Creates a glowing, folding 3D blob that animates smoothly between conversational states, modes and one-shot moments. It shares its state API with [OrbOverlay](./orb.md).

## Import

```tsx
import { BlobOverlay } from '@native-springs/shaders';
import type { BlobOverlayRef } from '@native-springs/shaders';
```

## Basic Usage

```tsx
const blobRef = useRef<BlobOverlayRef>(null);

<BlobOverlay
  ref={blobRef}
  state="listening"
  mode="default"
  confidence={1}
  parameters={{
    color: '#6699FF',
    secondaryColor: '#E666CC',
  }}
  style={styles.overlay}
/>

// One-shot moments
blobRef.current?.trigger('flash');
blobRef.current?.trigger('exhale');
blobRef.current?.trigger('ripple');
```

Every change to `state`, `mode`, `confidence` or the colors transitions smoothly, including changes made mid-transition. The blob looks best on dark backgrounds. It raymarches a 3D shape for every pixel, so it is heavier than most overlays. It renders at half resolution by default; lower `renderScale` further on low-end devices.

Each blob keeps its own animation state, so the `unique` prop has no effect. In a view that is narrower than it is tall (for example 400 × 500) the shape can reach the sides at the default `scale`. A `scale` of `0.65` keeps it inside in every state and mode, apart from a brief `exhale` pulse in `balanced` mode.

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `state` | `ConversationState` | `'idle'` | Core conversational state |
| `mode` | `ConversationMode` | `'default'` | Visual mode layered on top of the state |
| `confidence` | `number` | `1` | How well the assistant knows the user (0.0 - 1.0). Lower = dimmer, softer, slimmer halo |
| `speechLevel` | `number` | — | Optional 0.0 - 1.0 level (e.g. smoothed TTS amplitude) steering the speaking pulse. Omit for a built-in speech-paced rhythm |
| `parameters` | `BlobParameters` | — | Visual configuration, see below |

### States

| State | Behavior |
|-------|----------|
| `idle` | Slow ~5s breathing, gentle folding, calm middle |
| `listening` | Shape tightens slightly, halo sharpens and brightens |
| `thinking` | Churn across the middle, turbulent iridescent folding, quicker pace |
| `speaking` | Brightens and dims rhythmically, middle stays calm |
| `error` | Flat, desaturated shape with minimal motion. Overrides the mode |

### Modes

Modes describe a look, not a use case: map your own app concepts onto them.

| Mode | Behavior |
|------|----------|
| `default` | Baseline. Switching back to `default` from another mode settles quickly and gently, so leaving a mode never feels abrupt |
| `focused` | Fuller glow, calmer and more concentrated folding, held for the whole mode |
| `balanced` | Mirrored, balanced shape with slower, deliberate breathing |
| `prismatic` | Iridescent, unstable folds and shimmering colors |

### Moments

Fire through the ref with `trigger(moment)`:

| Moment | Behavior |
|--------|----------|
| `flash` | Distinct brighten-and-hold beat, e.g. when a key line lands |
| `exhale` | Slower pulse with a moment of extra brightness, e.g. releasing after a `focused` stretch |
| `ripple` | Single soft outward ripple, e.g. when offering something or entering a mode |

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `color` | `[r, g, b]` or `string` | `[0.4, 0.6, 1]` | Primary glow color as RGB or HEX string. Changes cross-fade |
| `secondaryColor` | `[r, g, b]` or `string` | `[0.9, 0.4, 0.8]` | Secondary glow color, blended across the folds. Changes cross-fade |
| `scale` | `number` | `1.0` | Blob size multiplier (0.5 - 2.0) |
| `speed` | `number` | `1.0` | Global animation speed multiplier, on top of state pacing (0.0 - 3.0) |
| `transitionDuration` | `number` | `0.7` | Approximate seconds for state and mode transitions to settle (0.1 - 3.0) |
| `colorTransitionDuration` | `number` | `0.8` | Approximate seconds for color cross-fades (0.1 - 3.0) |
| `renderScale` | `number` | `0.5` | Render resolution as a fraction of the screen's pixel density (0.1 - 1.0). Lower is faster, the glow stays soft |

## See Also

- [Example Screen](../../example/src/screens/BlobOverlayScreen.tsx)
- [App Demo Screen](../../example/src/screens/BlobDemoScreen.tsx)

## License

Adapted from shader by [mrange](https://www.shadertoy.com/view/WXc3D4). License not specified by original author. Commercial use may require permission from the original author.
