# FireworksOverlay

Creates animated firework explosions 🎆

## Import

```tsx
import { FireworksOverlay } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<FireworksOverlay
  parameters={{
    intensity: 1.0,
    speed: 1.0,
    frequency: 1.5,
    particleCount: 50,
    gravity: 0.4,
  }}
  style={styles.overlay}
/>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `color` | `[r, g, b]` or `string` | `[1.0, 0.5, 0.0]` | Firework color as RGB or HEX string |
| `speed` | `number` | `1.0` | Animation speed multiplier |
| `minSize` | `number` | `0.2` | Minimum explosion size |
| `maxSize` | `number` | `0.6` | Maximum explosion size |
| `minDuration` | `number` | `1.0` | Minimum explosion duration (seconds) |
| `maxDuration` | `number` | `2.5` | Maximum explosion duration (seconds) |
| `frequency` | `number` | `1.5` | Spawn frequency multiplier |
| `useCustomColor` | `boolean` | `false` | Use custom color instead of rainbow |
| `sharpness` | `number` | `1.5` | Particle edge sharpness (0.0 - 1.0+) |
| `particleCount` | `number` | `50` | Number of particles per explosion (20 - 100) |
| `gravity` | `number` | `0.4` | Gravity strength affecting particle fall (0.0 - 2.0) |

## See Also

- [Example Screen](../../example/src/screens/FireworksOverlayScreen.tsx)

## License

CC BY-NC-SA 3.0

Commercial use requires permission from the original author.
