# LiquidMetalOverlay

Creates a flowing, chrome-like metallic border effect.

## Import

```tsx
import { LiquidMetalOverlay } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<LiquidMetalOverlay
  parameters={{
    intensity: 1.0,
    borderWidth: 8.0,
    cornerRadius: 16.0,
    baseColor: '#B3BFCC',
    highlightColor: '#FFFFFF',
    flowSpeed: 1.0,
    stripeCount: 3.0,
  }}
  style={styles.overlay}
/>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `borderWidth` | `number` | `8.0` | Border width in pixels (1.0 - 20.0) |
| `cornerRadius` | `number` | `0.0` | Corner radius in pixels |
| `baseColor` | `[r, g, b]` or `string` | `[0.7, 0.75, 0.8]` | Base metallic color as RGB or HEX string |
| `highlightColor` | `[r, g, b]` or `string` | `[1, 1, 1]` | Highlight/reflection color as RGB or HEX string |
| `flowSpeed` | `number` | `1.0` | Flow animation speed multiplier (0.1 - 3.0) |
| `stripeCount` | `number` | `3.0` | Number of metallic stripe bands (1.0 - 10.0) |
| `distortion` | `number` | `0.3` | Distortion strength (0.0 - 1.0) |
| `chromaticAberration` | `number` | `0.0` | Chromatic aberration intensity (0.0 - 2.0) |
| `flowOffset` | `[x, y]` | `[0, 0]` | Flow offset position (-1.0 - 1.0) |
| `flowAngle` | `number` | `0` | Flow angle in degrees (0 - 360) |
| `specular` | `object` | - | Specular highlight configuration (see below) |
| `roughness` | `number` | `0.0` | Surface roughness - 0.0 = polished chrome, 1.0 = brushed matte (0.0 - 1.0) |

### Specular Object

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `0.5` | Specular highlight intensity (0.0 - 1.0) |
| `position` | `[x, y]` | `[0, 0]` | Specular highlight position (-1.0 - 1.0) |
| `size` | `number` | `0.3` | Specular highlight size (0.0 - 1.0) |

## See Also

- [Example Screen](../../example/src/screens/LiquidMetalOverlayScreen.tsx)

## License

MIT
