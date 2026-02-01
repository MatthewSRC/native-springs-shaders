# NeonOverlay

Creates an animated glowing neon border that encapsulates content.

## Import

```tsx
import { NeonOverlay } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<NeonOverlay
  parameters={{
    intensity: 1.0,
    borderWidth: 4.0,
    cornerRadius: 16.0,
    color: '#00FFE6',
    secondaryColor: '#FF00CC',
    glowSize: 3.0,
    flowSpeed: 1.0,
    pulseSpeed: 1.0,
  }}
  style={styles.overlay}
/>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `borderWidth` | `number` | `4.0` | Border width in pixels (1.0 - 20.0) |
| `cornerRadius` | `number` | `0.0` | Corner radius in pixels |
| `color` | `[r, g, b]` or `string` | `[0, 1, 0.9]` | Primary neon color as RGB or HEX string |
| `secondaryColor` | `[r, g, b]` or `string` | `[1, 0, 0.8]` | Secondary neon color for gradient blending |
| `glowSize` | `number` | `3.0` | Glow size multiplier relative to border width (1.0 - 10.0) |
| `glowFalloff` | `number` | `1.5` | Glow falloff exponent - higher = sharper glow (0.5 - 3.0) |
| `flowSpeed` | `number` | `1.0` | Animated flow speed - light traveling around border (0.0 - 3.0) |
| `flowIntensity` | `number` | `0.5` | Flow brightness intensity (0.0 - 2.0) |
| `pulseSpeed` | `number` | `1.0` | Pulse/breathing animation speed (0.0 - 3.0) |
| `pulseIntensity` | `number` | `0.2` | Pulse intensity - how much brightness varies (0.0 - 1.0) |
| `flickerIntensity` | `number` | `0.0` | Flicker intensity for realistic neon effect (0.0 - 1.0) |
| `colorBlend` | `number` | `0.5` | Color blend between primary and secondary colors (0.0 - 1.0) |
| `inset` | `number` | `0.0` | Inset border from view edges for outer glow (0.0 - 50.0 pixels) |

## See Also

- [Example Screen](../../example/src/screens/NeonOverlayScreen.tsx)

## License

MIT
