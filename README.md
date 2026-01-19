# @native-springs/shaders

High-performance native shader effects for React Native and Expo. Transform your UI with GPU-accelerated visual effects including ripples, glitch distortions, liquid effects, aurora overlays, fireworks, and more.

## Features

- **Native Performance**: Metal (iOS) and OpenGL (Android) implementations
- **8 Visual Effects**: 3 content shaders + 5 overlay effects, more to come in the near future
- **TypeScript Support**: Full type definitions included
- **Expo Compatible**: Works with managed and bare Expo projects

## Effects

### Shaders (transform content)

| Effect | Description |
|--------|-------------|
| **[RippleShader](./docs/shaders/ripple.md)** |  Touch-responsive water ripples |
| **[GlitchShader](./docs/shaders/glitch.md)** |  Digital glitch effects |
| **[LiquidDistortionShader](./docs/shaders/liquid-distortion.md)** | Liquid warping effects |

### Overlays (layer on top)

| Effect | Description |
|--------|-------------|
| **[AuroraOverlay](./docs/overlays/aurora.md)** | Northern lights effect |
| **[FireSparksOverlay](./docs/overlays/fire-sparks.md)** | Fire particles |
| **[FireworksOverlay](./docs/overlays/fireworks.md)** | Firework explosions |
| **[LightRayOverlay](./docs/overlays/light-ray.md)** |  Volumetric light rays |
| **[SparklesOverlay](./docs/overlays/sparkles.md)** |  Twinkling particles |

## Installation

```bash
npm install @native-springs/shaders
```

### iOS

Run pod install:

```bash
npx pod-install
```

### Android

No additional configuration required.

## Example App

Check out the [example app](./example) for interactive demos of all effects with adjustable parameters.

```bash
cd example
npm install
npx expo run:ios # or run:android
```

## Requirements

- Expo SDK 51+
- iOS 15.1+
- Android API 24+

## License

MIT

Some effects may have different licenses. See the documentation for each effect for details.
