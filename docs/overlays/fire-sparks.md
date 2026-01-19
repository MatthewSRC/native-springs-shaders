# FireSparksOverlay

Creates an animated fire particle effect with floating sparks 🔥

## Import

```tsx
import { FireSparksOverlay } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<FireSparksOverlay
  parameters={{
    intensity: 1.0,
    color: [1.0, 0.5, 0.0],
    direction: [0, -1],
    particleSize: 1.0,
    animationSpeed: 1.0,
    smokeIntensity: 1.0,
  }}
  style={styles.overlay}
/>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `color` | `[r, g, b]` or `string` | `[1.0, 0.5, 0.0]` | Spark color as RGB or HEX string |
| `direction` | `[x, y]` | `[0, -1]` | Movement direction vector |
| `borderFade` | `number` | `0.0` | Edge fade intensity (0.0 - 1.0) |
| `travelDistance` | `number` | `1.0` | Distance sparks travel before fading |
| `particleSize` | `number` | `1.0` | Size of individual spark particles |
| `animationSpeed` | `number` | `1.0` | Animation speed multiplier |
| `smokeIntensity` | `number` | `1.0` | Smoke trail intensity (0.0 - 2.0+) |
| `particleBloom` | `number` | `1.0` | Particle glow/bloom strength (0.0 - 3.0+) |
| `movementSpeed` | `number` | `1.0` | Horizontal flow/drift speed (0.2 - 3.0) |

## See Also

- [Example Screen](../../example/src/screens/FireSparksOverlayScreen.tsx)

## License

MIT

Adapted from shader by [Jan Mróz (jaszunio15)](https://www.shadertoy.com/view/wl2Gzc).
