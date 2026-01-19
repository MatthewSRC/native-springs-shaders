import React, { useState } from 'react';
import { StyleSheet, Text, View, Pressable, ScrollView, Image } from 'react-native';
import { LiquidDistortionShader } from '@native-springs/shaders';

interface LiquidDistortionScreenProps {
  onBack: () => void;
}

export const LiquidDistortionScreen: React.FC<LiquidDistortionScreenProps> = ({ onBack }) => {
  const [intensity, setIntensity] = useState(1.0);
  const [speed, setSpeed] = useState(1.0);
  const [waveScale, setWaveScale] = useState(3.0);
  const [turbulence, setTurbulence] = useState(1.0);
  const [chromaticAberration, setChromaticAberration] = useState(0.3);
  const [variant, setVariant] = useState<'water' | 'glass' | 'oil'>('water');
  const [shineStrength, setShineStrength] = useState(0.15);
  const [colorTintStrength, setColorTintStrength] = useState(0.2);

  const getColorForVariant = (): [number, number, number] => {
    switch (variant) {
      case 'water':
        return [0.85, 0.95, 1.0];
      case 'glass':
        return [1.0, 1.0, 1.0];
      case 'oil':
        return [0.9, 0.9, 0.9];
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Pressable onPress={onBack} style={styles.backButton}>
          <Text style={styles.backText}>← Back</Text>
        </Pressable>
      </View>

      <ScrollView style={styles.content} contentContainerStyle={styles.scrollContent}>
        <View style={styles.preview}>
          <LiquidDistortionShader
            parameters={{
              intensity,
              speed,
              waveScale,
              turbulence,
              chromaticAberration,
              liquidVariant: variant,
              color: getColorForVariant(),
              flowDirection: [0.7, -1.0],
              shineStrength,
              colorTintStrength,
            }}
            initialSnapshotDelay={500}
            style={styles.shader}
          >
            <View style={styles.shaderContent}>
              <Image
                source={{ uri: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800' }}
                style={styles.backgroundImage}
                resizeMode="cover"
              />
              <View style={styles.overlay}>
                <Text style={styles.contentTitle}>Liquid Distortion Screen</Text>
              </View>
            </View>
          </LiquidDistortionShader>
        </View>

        <View style={styles.controls}>
          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Variant</Text>
            <View style={styles.buttonRow}>
              {(['water', 'glass', 'oil'] as const).map((val) => (
                <Pressable key={val} style={[styles.button, variant === val && styles.activeButton]} onPress={() => setVariant(val)}>
                  <Text style={[styles.buttonText, variant === val && styles.activeButtonText]}>{val.charAt(0).toUpperCase() + val.slice(1)}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Intensity: {intensity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, intensity === val && styles.activeButton]} onPress={() => setIntensity(val)}>
                  <Text style={[styles.buttonText, intensity === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Turbulence: {turbulence.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, turbulence === val && styles.activeButton]} onPress={() => setTurbulence(val)}>
                  <Text style={[styles.buttonText, turbulence === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Speed: {speed.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, speed === val && styles.activeButton]} onPress={() => setSpeed(val)}>
                  <Text style={[styles.buttonText, speed === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Chromatic Aberration: {chromaticAberration.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.3, 0.6, 1.0].map((val) => (
                <Pressable key={val} style={[styles.button, chromaticAberration === val && styles.activeButton]} onPress={() => setChromaticAberration(val)}>
                  <Text style={[styles.buttonText, chromaticAberration === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Wave Scale: {waveScale.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[2.0, 3.0, 4.0, 5.0].map((val) => (
                <Pressable key={val} style={[styles.button, waveScale === val && styles.activeButton]} onPress={() => setWaveScale(val)}>
                  <Text style={[styles.buttonText, waveScale === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Shine Strength: {shineStrength.toFixed(2)}</Text>
            <View style={styles.buttonRow}>
              {[0.1, 0.15, 0.3].map((val) => (
                <Pressable key={val} style={[styles.button, shineStrength === val && styles.activeButton]} onPress={() => setShineStrength(val)}>
                  <Text style={[styles.buttonText, shineStrength === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Color Tint Strength: {colorTintStrength.toFixed(2)}</Text>
            <View style={styles.buttonRow}>
              {[0.05, 0.2, 0.5].map((val) => (
                <Pressable key={val} style={[styles.button, colorTintStrength === val && styles.activeButton]} onPress={() => setColorTintStrength(val)}>
                  <Text style={[styles.buttonText, colorTintStrength === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0a0a0a' },
  header: { padding: 20, paddingTop: 10, borderBottomWidth: 1, borderBottomColor: '#1a1a2e' },
  backButton: { marginBottom: 10 },
  backText: { color: '#ffffff', fontSize: 16, fontWeight: '600' },
  title: { fontSize: 28, fontWeight: 'bold', color: '#ffffff', marginBottom: 4 },
  subtitle: { fontSize: 14, color: '#888' },
  content: { flex: 1 },
  scrollContent: { paddingBottom: 40 },
  preview: { width: '100%', height: 350, marginBottom: 20 },
  shader: { flex: 1 },
  shaderContent: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  backgroundImage: { position: 'absolute', width: '100%', height: '100%' },
  overlay: { padding: 30, backgroundColor: 'rgba(0, 0, 0, 0.3)', alignItems: 'center' },
  contentTitle: { fontSize: 28, fontWeight: 'bold', color: '#fff', marginBottom: 8 },
  contentText: { color: '#aaa', fontSize: 14 },
  controls: { padding: 20 },
  controlGroup: { marginBottom: 20 },
  controlLabel: { fontSize: 16, fontWeight: '600', color: '#ffffff', marginBottom: 8 },
  buttonRow: { flexDirection: 'row', gap: 10 },
  button: { flex: 1, backgroundColor: '#000000', paddingVertical: 12, borderRadius: 10, alignItems: 'center', borderWidth: 1, borderColor: '#ffffff' },
  activeButton: { backgroundColor: '#ffffff' },
  buttonText: { color: '#ffffff', fontSize: 14, fontWeight: '600' },
  activeButtonText: { color: '#000000' },
});
