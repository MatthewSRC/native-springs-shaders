# SparklesOverlay

Creates twinkling star-like particles across the view ✨

## Import

```tsx
import { SparklesOverlay } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<SparklesOverlay
  parameters={{
    intensity: 1.0,
    density: 3.0,
    size: 1.0,
    speed: 1.0,
    colorize: true,
    twinkleSpeed: 0.5,
    brightnessMultiplier: 2.5,
  }}
  style={styles.overlay}
/>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `color` | `[r, g, b] ` or `string` | `[1, 1, 1]` | Sparkle color as RGB or HEX string |
| `density` | `number` | `1.0` | Sparkle density (0.0 - 1.0+) |
| `size` | `number` | `1.0` | Sparkle size multiplier |
| `speed` | `number` | `1.0` | Animation speed multiplier |
| `colorize` | `boolean` | `false` | Use rainbow colors instead of fixed color |
| `twinkleSpeed` | `number` | `0.5` | Twinkle fade in/out speed (0.0 - 2.0+) |
| `brightnessMultiplier` | `number` | `1.0` | Overall brightness (0.0 - 5.0+) |


## See Also

- [Example Screen](../../example/src/screens/SparklesOverlayScreen.tsx)

## License

MIT

Inspired by shader from [Nimphious](https://www.shadertoy.com/view/XcfcWj).