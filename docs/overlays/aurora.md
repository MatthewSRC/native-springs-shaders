# AuroraOverlay

Creates a flowing, colorful aurora borealis animation 🌌

## Import

```tsx
import { AuroraOverlay } from '@native-springs/shaders';
```

## Basic Usage

```tsx
<AuroraOverlay
  parameters={{
    intensity: 1.0,
    color: [0.3, 0.7, 1.0],
    direction: [0, -1],
    borderFade: 0.0,
  }}
  style={styles.overlay}
/>
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `intensity` | `number` | `1.0` | Overall intensity/opacity (0.0 - 1.0+) |
| `color` | `[r, g, b]` or `string` | `[0.3, 0.7, 1.0]` | Color tint as RGB or HEX string |
| `direction` | `[x, y]` | `[0, -1]` | Movement direction vector |
| `borderFade` | `number` | `0.0` | Edge fade intensity (0.0 - 1.0) |

## See Also

- [Example Screen](../../example/src/screens/AuroraOverlayScreen.tsx)

## License

License not specified by original author. Commercial use may require permission from the original author.
