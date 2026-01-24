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
import { SafeAreaView } from 'react-native-safe-area-context';

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
  | 'liquidMetal';

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
      default:
        return <HomeScreen onNavigate={setCurrentScreen} />;
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      {renderScreen()}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0a0a0a',
  },
});
