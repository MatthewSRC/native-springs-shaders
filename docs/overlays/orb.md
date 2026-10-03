# OrbOverlay

Creates a glowing energy orb that animates smoothly between conversational states, modes and one-shot moments.

## Import

```tsx
import { OrbOverlay } from '@native-springs/shaders';
import type { OrbOverlayRef } from '@native-springs/shaders';
```

## Basic Usage

```tsx
const orbRef = useRef<OrbOverlayRef>(null);

<OrbOverlay
  ref={orbRef}
  state="listening"
  mode="default"
  confidence={1}
  parameters={{
    color: '#FFCC66',
    secondaryColor: '#BFCC66',
  }}
  style={styles.overlay}
/>

// One-shot moments
orbRef.current?.trigger('flash');
orbRef.current?.trigger('exhale');
orbRef.current?.trigger('ripple');
```

Every change to `state`, `mode`, `confidence` or the colors transitions smoothly, including changes made mid-transition. The orb looks best on dark backgrounds.

Each orb keeps its own animation state, so the `unique` prop has no effect. Turbulent looks (`thinking`, `prismatic`) make the ring and its filaments larger, so leave room around the orb or lower `scale` in a narrow view.

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `state` | `ConversationState` | `'idle'` | Core conversational state |
| `mode` | `ConversationMode` | `'default'` | Visual mode layered on top of the state |
| `confidence` | `number` | `1` | How well the assistant knows the user (0.0 - 1.0). Lower = dimmer, softer, thinner |
| `speechLevel` | `number` | — | Optional 0.0 - 1.0 level (e.g. smoothed TTS amplitude) steering the speaking pulse. Omit for a built-in speech-paced rhythm |
| `parameters` | `OrbParameters` | — | Visual configuration, see below |

### States

| State | Behavior |
|-------|----------|
| `idle` | Slow ~5s breathing, steady dispersion, calm dark center |
| `listening` | Ring tightens slightly, edge fringing sharpens and brightens |
| `thinking` | Faint churn in the center, turbulent chromatic dispersion, quicker pace |
| `speaking` | Edge brightens and dims rhythmically, center stays calm |
| `error` | Flat, desaturated ring with minimal motion. Overrides the mode |

### Modes

Modes describe a look, not a use case: map your own app concepts onto them.

| Mode | Behavior |
|------|----------|
| `default` | Baseline. Switching back to `default` from another mode settles quickly and gently, so leaving a mode never feels abrupt |
| `focused` | Thicker ring, concentrated dispersion, held for the whole mode |
| `balanced` | Mirrored, balanced dispersion with slower, deliberate breathing |
| `prismatic` | More chromatic, unstable dispersion with shimmering edges |

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
| `color` | `[r, g, b]` or `string` | `[1, 0.8, 0.4]` | Primary glow color as RGB or HEX string. Changes cross-fade |
| `secondaryColor` | `[r, g, b]` or `string` | `[0.75, 0.8, 0.4]` | Secondary glow color blended in away from the orb edge. Changes cross-fade |
| `scale` | `number` | `1.0` | Orb size multiplier (0.5 - 2.0) |
| `speed` | `number` | `1.0` | Global animation speed multiplier, on top of state pacing (0.0 - 3.0) |
| `transitionDuration` | `number` | `0.7` | Approximate seconds for state and mode transitions to settle (0.1 - 3.0) |
| `colorTransitionDuration` | `number` | `0.8` | Approximate seconds for color cross-fades (0.1 - 3.0) |
| `renderScale` | `number` | `0.75` | Render resolution as a fraction of the screen's pixel density (0.1 - 1.0). Lower is faster, the glow stays soft |

## See Also

- [Example Screen](../../example/src/screens/OrbOverlayScreen.tsx)
- [App Demo Screen](../../example/src/screens/OrbDemoScreen.tsx)

## License

Adapted from shader by [SnoopethDuckDuck](https://www.shadertoy.com/view/mdd3D4). License not specified by original author. Commercial use may require permission from the original author.
