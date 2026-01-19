# GlitchShader

Creates digital glitch artifacts with chromatic aberration and scanlines 📺

## Import

```tsx
import { GlitchShader } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<GlitchShader
  parameters={{
    intensity: 0.7,
    chromaticAberration: 1.0,
    scanlineIntensity: 0.5,
    glitchFrequency: 0.15,
  }}
  style={styles.shader}
>
  <Image source={yourImage} style={styles.image} />
</GlitchShader>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `0.7` | Overall intensity/opacity (0.0 - 1.0+) |
| `chromaticAberration` | `number` | `1.0` | Chromatic aberration intensity |
| `scanlineIntensity` | `number` | `0.5` | Scanline intensity |
| `glitchFrequency` | `number` | `0.15` | Glitch occurrence frequency (0.0 - 1.0) |
| `blockSize` | `number` | `50` | Size of glitch blocks (pixels) |
| `grainIntensity` | `number` | `0.04` | Film grain/noise intensity (0.0 - 0.2) |
| `vignetteStrength` | `number` | `0.5` | Edge vignette darkness (0.0 - 1.0) |
| `chromaticSpread` | `number` | `1.0` | RGB separation spread multiplier (0.5 - 3.0) |

## See Also

- [Example Screen](../../example/src/screens/GlitchScreen.tsx)

## License

MIT
