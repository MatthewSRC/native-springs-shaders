# LightRayOverlay

Creates volumetric light rays emanating from a source point ☀️

## Import

```tsx
import { LightRayOverlay } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<LightRayOverlay
  parameters={{
    intensity: 1.0,
    color: [1.0, 0.95, 0.8],
    rayPosition: [0.5, 0.5],
    numRays: 8,
    rayLength: 1.0,
  }}
  style={styles.overlay}
/>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `color` | `[r, g, b]` or `string` | `[1.0, 0.95, 0.8]` | Light ray color as RGB or HEX string |
| `rayPosition` | `[x, y]` | `[0.5, 0.5]` | Light source position (0.0 - 1.0) |
| `speed` | `number` | `1.0` | Animation speed multiplier |
| `numRays` | `number` | `8` | Number of light rays |
| `depthAttenuation` | `number` | `1.0` | Depth-based intensity falloff |
| `rayLength` | `number` | `1.0` | Length of light rays |
| `rayDirection` | `[x, y]` | `[0, 0]` | Ray direction vector |
| `rayWidth` | `number` | `1.0` | Width/spread of light rays (0.5 - 3.0) |

## See Also

- [Example Screen](../../example/src/screens/LightRayOverlayScreen.tsx)

## License

License not specified by original author. Commercial use may require permission from the original author.
