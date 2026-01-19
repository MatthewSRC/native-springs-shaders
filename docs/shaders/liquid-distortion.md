# LiquidDistortionShader

Creates flowing liquid-like distortions 🌊

## Import

```tsx
import { LiquidDistortionShader } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<LiquidDistortionShader
  parameters={{
    intensity: 1.0,
    speed: 1.0,
    waveScale: 3.0,
    turbulence: 1.0,
    liquidVariant: 'water',
  }}
  style={styles.shader}
>
  <Image source={yourImage} style={styles.image} />
</LiquidDistortionShader>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `speed` | `number` | `1.0` | Animation speed multiplier |
| `waveScale` | `number` | `3.0` | Wave pattern scale |
| `turbulence` | `number` | `1.0` | Turbulence intensity |
| `chromaticAberration` | `number` | `0.3` | Chromatic aberration intensity |
| `flowDirection` | `[x, y]` | `[0.7, -1.0]` | Flow direction vector |
| `color` | `[r, g, b]` or `string` | `[0.85, 0.95, 1.0]` | Liquid color tint as RGB or HEX string |
| `liquidVariant` | `string` | `'water'` | Liquid style: `'water'`, `'glass'`, or `'oil'` |
| `shineStrength` | `number` | `0.15` | Shine/highlight strength (0.0 - 1.0) |
| `colorTintStrength` | `number` | `0.2` | Color tint strength (0.0 - 1.0) |

## Liquid Variants

- **`water`** - Standard water effect with shine and tint
- **`glass`** - Glass-like effect with subtle shine
- **`oil`** - Iridescent oil effect with color shifting

## See Also

- [Example Screen](../../example/src/screens/LiquidDistortionScreen.tsx)

## License

MIT
