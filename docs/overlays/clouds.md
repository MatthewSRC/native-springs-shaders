# CloudsOverlay

Creates soft, blurry gradient clouds that drift slowly, for ambient backgrounds. Made to sit behind blurred cards and frosted glass UI.

## Import

```tsx
import { CloudsOverlay } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<CloudsOverlay
  parameters={{
    intensity: 0.6,
    color: '#26338C',
    secondaryColor: '#402680',
    tertiaryColor: '#1A4D80',
    scale: 1.0,
    speed: 0.3,
    softness: 0.6,
    blobCount: 3,
  }}
  style={styles.overlay}
/>
```

### Behind frosted glass

Fill the screen with the overlay and put translucent cards on top of it:

```tsx
<View style={{ flex: 1, backgroundColor: '#05060f' }}>
  <CloudsOverlay unique parameters={{ blobCount: 4 }} style={StyleSheet.absoluteFill} />

  <View style={styles.card}>{/* backgroundColor: 'rgba(255, 255, 255, 0.08)' */}</View>
</View>
```

It works on dark and light backgrounds. On a light background use pastel colors (for example `#E2CCFF`, `#FFE3B8` and `#C6E4FF`).

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `unique` | `boolean` | `false` | Share one animation clock across every Clouds overlay in the app, so the same background stays in sync across screens and tabs |
| `parameters` | `CloudsParameters` | — | Visual configuration, see below |

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `0.6` | Overall intensity/opacity (0.0 - 1.0+) |
| `color` | `[r, g, b]` or `string` | `[0.15, 0.2, 0.55]` | Primary blob color as RGB or HEX string |
| `secondaryColor` | `[r, g, b]` or `string` | `[0.25, 0.15, 0.5]` | Secondary blob color as RGB or HEX string |
| `tertiaryColor` | `[r, g, b]` or `string` | `[0.1, 0.3, 0.5]` | Tertiary blob color as RGB or HEX string |
| `scale` | `number` | `1.0` | Blob size multiplier (0.5 - 3.0) |
| `speed` | `number` | `0.3` | Drift animation speed multiplier (0.0 - 2.0). `0` freezes the clouds |
| `softness` | `number` | `0.6` | Edge softness of the blobs - higher = more diffuse (0.1 - 1.0) |
| `blobCount` | `number` | `3` | Number of color blobs (1 - 5) |

The first three blobs use the primary, secondary and tertiary colors. The fourth blends primary and secondary, and the fifth blends secondary and tertiary. Color changes apply immediately, with no cross-fade.

## See Also

- [Example Screen](../../example/src/screens/CloudsOverlayScreen.tsx)
- [App Demo Screen](../../example/src/screens/CloudsDemoScreen.tsx)

## License

MIT
