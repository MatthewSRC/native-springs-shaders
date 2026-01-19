# RippleShader

Creates interactive water ripple distortions at touch points 💧

## Import

```tsx
import { RippleShader } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<RippleShader
  parameters={{
    intensity: 1.0,
    touchPoint: [0.5, 0.5],
    touchTime: 0,
    rippleVariant: 'realistic',
    speed: 300,
    damping: 0.8,
  }}
  style={styles.shader}
>
  <Image source={yourImage} style={styles.image} />
</RippleShader>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `color` | `[r, g, b]` or `string` | `[0.3, 0.7, 1.0]` | Ripple color as RGB or HEX string |
| `touchPoint` | `[x, y]` | `[0.5, 0.5]` | Touch point normalized coordinates (0.0 - 1.0) |
| `touchTime` | `number` | `0` | Time since touch started (seconds) |
| `frequency` | `number` | `1.2` | Wave frequency |
| `damping` | `number` | `0.8` | How quickly ripples fade (0.0 - 1.0) |
| `rippleVariant` | `string` | `'realistic'` | Ripple style: `'standard'` or `'realistic'` |
| `speed` | `number` | `300` | Wave propagation speed |
| `ringWidth` | `number` | `40` | Width of wave ring (realistic variant) |
| `slowdownFactor` | `number` | `0.5` | Wave deceleration rate (realistic variant) |
| `displacementStrength` | `number` | `0.05` | Image distortion strength (0.0 - 0.2) |
| `highlightStrength` | `number` | `0.1` | Colored highlight intensity (0.0 - 0.5) |

## Ripple Variants

- **`standard`** - Simple concentric wave pattern
- **`realistic`** - Physics-based ripple with natural deceleration

## See Also

- [Example Screen](../../example/src/screens/RippleScreen.tsx)

## License

MIT
