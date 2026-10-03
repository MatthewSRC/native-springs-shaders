import { useState } from 'react';
import { StyleSheet, StatusBar, View } from 'react-native';

import { HomeScreen } from './src/screens/HomeScreen';
import { RippleScreen } from './src/screens/RippleScreen';
import { GlitchScreen } from './src/screens/GlitchScreen';
import { LiquidDistortionScreen } from './src/screens/LiquidDistortionScreen';
import { FireSparksOverlayScreen } from './src/screens/FireSparksOverlayScreen';
import { AuroraOverlayScreen } from './src/screens/AuroraOverlayScreen';
import { FireworksOverlayScreen } from './src/screens/FireworksOverlayScreen';
import { LightRayOverlayScreen } from './src/screens/LightRayOverlayScreen';
import { SparklesOverlayScreen } from './src/screens/SparklesOverlayScreen';
import { LiquidMetalOverlayScreen } from './src/screens/LiquidMetalOverlayScreen';
import { NeonOverlayScreen } from './src/screens/NeonOverlayScreen';
import { CloudsOverlayScreen } from './src/screens/CloudsOverlayScreen';
import { OrbOverlayScreen } from './src/screens/OrbOverlayScreen';
import { BlobOverlayScreen } from './src/screens/BlobOverlayScreen';
import { OrbDemoScreen } from './src/screens/OrbDemoScreen';
import { BlobDemoScreen } from './src/screens/BlobDemoScreen';
import { CloudsDemoScreen } from './src/screens/CloudsDemoScreen';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';

type Screen =
  | 'home'
  | 'ripple'
  | 'glitch'
  | 'liquidDistortion'
  | 'fireSparks'
  | 'aurora'
  | 'fireworks'
  | 'lightRay'
  | 'sparkles'
  | 'liquidMetal'
  | 'neon'
  | 'clouds'
  | 'cloudsDemo'
  | 'orb'
  | 'orbDemo'
  | 'blob'
  | 'blobDemo';

// These screens handle safe areas themselves and draw edge to edge
const EDGE_TO_EDGE: Screen[] = ['clouds', 'cloudsDemo', 'orb', 'orbDemo', 'blob', 'blobDemo'];

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('home');

  const renderScreen = () => {
    switch (currentScreen) {
      case 'home':
        return <HomeScreen onNavigate={setCurrentScreen} />;
      case 'ripple':
        return <RippleScreen onBack={() => setCurrentScreen('home')} />;
      case 'glitch':
        return <GlitchScreen onBack={() => setCurrentScreen('home')} />;
      case 'liquidDistortion':
        return <LiquidDistortionScreen onBack={() => setCurrentScreen('home')} />;
      case 'fireSparks':
        return <FireSparksOverlayScreen onBack={() => setCurrentScreen('home')} />;
      case 'aurora':
        return <AuroraOverlayScreen onBack={() => setCurrentScreen('home')} />;
      case 'fireworks':
        return <FireworksOverlayScreen onBack={() => setCurrentScreen('home')} />;
      case 'lightRay':
        return <LightRayOverlayScreen onBack={() => setCurrentScreen('home')} />;
      case 'sparkles':
        return <SparklesOverlayScreen onBack={() => setCurrentScreen('home')} />;
      case 'liquidMetal':
        return <LiquidMetalOverlayScreen onBack={() => setCurrentScreen('home')} />;
      case 'neon':
        return <NeonOverlayScreen onBack={() => setCurrentScreen('home')} />;
      case 'clouds':
        return (
          <CloudsOverlayScreen
            onBack={() => setCurrentScreen('home')}
            onOpenDemo={() => setCurrentScreen('cloudsDemo')}
          />
        );
      case 'cloudsDemo':
        return <CloudsDemoScreen onBack={() => setCurrentScreen('clouds')} />;
      case 'orb':
        return (
          <OrbOverlayScreen
            onBack={() => setCurrentScreen('home')}
            onOpenDemo={() => setCurrentScreen('orbDemo')}
          />
        );
      case 'orbDemo':
        return <OrbDemoScreen onBack={() => setCurrentScreen('orb')} />;
      case 'blob':
        return (
          <BlobOverlayScreen
            onBack={() => setCurrentScreen('home')}
            onOpenDemo={() => setCurrentScreen('blobDemo')}
          />
        );
      case 'blobDemo':
        return <BlobDemoScreen onBack={() => setCurrentScreen('blob')} />;
      default:
        return <HomeScreen onNavigate={setCurrentScreen} />;
    }
  };

  const Root = EDGE_TO_EDGE.includes(currentScreen) ? View : SafeAreaView;

  return (
    <SafeAreaProvider>
      <Root style={styles.container}>
        <StatusBar barStyle="light-content" />
        {renderScreen()}
      </Root>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0a0a0a',
  },
});
