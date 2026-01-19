import React, { useState } from 'react';
import { StyleSheet, Text, View, Pressable, ScrollView, Image } from 'react-native';
import { GlitchShader } from '@native-springs/shaders';

interface GlitchScreenProps {
  onBack: () => void;
}

export const GlitchScreen: React.FC<GlitchScreenProps> = ({ onBack }) => {
  const [intensity, setIntensity] = useState(0.7);
  const [chromaticAberration, setChromatic] = useState(1.0);
  const [scanlineIntensity, setScanline] = useState(0.5);
  const [glitchFrequency, setGlitchFrequency] = useState(0.15);
  const [blockSize, setBlockSize] = useState(50);
  const [grainIntensity, setGrainIntensity] = useState(0.04);
  const [vignetteStrength, setVignetteStrength] = useState(0.5);
  const [chromaticSpread, setChromaticSpread] = useState(1.0);

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Pressable onPress={onBack} style={styles.backButton}>
          <Text style={styles.backText}>← Back</Text>
        </Pressable>
      </View>

      <ScrollView style={styles.content} contentContainerStyle={styles.scrollContent}>
        <View style={styles.preview}>
          <GlitchShader
            parameters={{
              intensity,
              chromaticAberration,
              scanlineIntensity,
              glitchFrequency,
              blockSize,
              grainIntensity,
              vignetteStrength,
              chromaticSpread,
            }}
            initialSnapshotDelay={500}
            style={styles.shader}
          >
            <View style={styles.shaderContent}>
              <Image
                source={{ uri: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800' }}
                style={styles.backgroundImage}
                resizeMode="cover"
              />
              <View style={styles.overlay}>
                <Text style={styles.contentTitle}>GLITCH SCREEN</Text>
                <View style={styles.statusBar}>
                  <View style={styles.statusDot} />
                  <Text style={styles.statusText}>CORRUPTED</Text>
                </View>
              </View>
            </View>
          </GlitchShader>
        </View>

        <View style={styles.controls}>
          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Intensity: {intensity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              <Pressable style={[styles.button, intensity === 0.3 && styles.activeButton]} onPress={() => setIntensity(0.3)}>
                <Text style={[styles.buttonText, intensity === 0.3 && styles.activeButtonText]}>Low</Text>
              </Pressable>
              <Pressable style={[styles.button, intensity === 0.7 && styles.activeButton]} onPress={() => setIntensity(0.7)}>
                <Text style={[styles.buttonText, intensity === 0.7 && styles.activeButtonText]}>Med</Text>
              </Pressable>
              <Pressable style={[styles.button, intensity === 1.0 && styles.activeButton]} onPress={() => setIntensity(1.0)}>
                <Text style={[styles.buttonText, intensity === 1.0 && styles.activeButtonText]}>High</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Glitch Frequency: {glitchFrequency.toFixed(2)}</Text>
            <Text style={styles.controlHint}>How often glitches occur</Text>
            <View style={styles.buttonRow}>
              <Pressable style={[styles.button, glitchFrequency === 0.05 && styles.activeButton]} onPress={() => setGlitchFrequency(0.05)}>
                <Text style={[styles.buttonText, glitchFrequency === 0.05 && styles.activeButtonText]}>Rare</Text>
              </Pressable>
              <Pressable style={[styles.button, glitchFrequency === 0.15 && styles.activeButton]} onPress={() => setGlitchFrequency(0.15)}>
                <Text style={[styles.buttonText, glitchFrequency === 0.15 && styles.activeButtonText]}>Default</Text>
              </Pressable>
              <Pressable style={[styles.button, glitchFrequency === 0.4 && styles.activeButton]} onPress={() => setGlitchFrequency(0.4)}>
                <Text style={[styles.buttonText, glitchFrequency === 0.4 && styles.activeButtonText]}>Frequent</Text>
              </Pressable>
              <Pressable style={[styles.button, glitchFrequency === 1.0 && styles.activeButton]} onPress={() => setGlitchFrequency(1.0)}>
                <Text style={[styles.buttonText, glitchFrequency === 1.0 && styles.activeButtonText]}>Chaos</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Chromatic Aberration: {chromaticAberration.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              <Pressable style={[styles.button, chromaticAberration === 0.5 && styles.activeButton]} onPress={() => setChromatic(0.5)}>
                <Text style={[styles.buttonText, chromaticAberration === 0.5 && styles.activeButtonText]}>0.5</Text>
              </Pressable>
              <Pressable style={[styles.button, chromaticAberration === 1.0 && styles.activeButton]} onPress={() => setChromatic(1.0)}>
                <Text style={[styles.buttonText, chromaticAberration === 1.0 && styles.activeButtonText]}>1.0</Text>
              </Pressable>
              <Pressable style={[styles.button, chromaticAberration === 1.5 && styles.activeButton]} onPress={() => setChromatic(1.5)}>
                <Text style={[styles.buttonText, chromaticAberration === 1.5 && styles.activeButtonText]}>1.5</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Scanline Intensity: {scanlineIntensity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              <Pressable style={[styles.button, scanlineIntensity === 0.0 && styles.activeButton]} onPress={() => setScanline(0.0)}>
                <Text style={[styles.buttonText, scanlineIntensity === 0.0 && styles.activeButtonText]}>Off</Text>
              </Pressable>
              <Pressable style={[styles.button, scanlineIntensity === 0.5 && styles.activeButton]} onPress={() => setScanline(0.5)}>
                <Text style={[styles.buttonText, scanlineIntensity === 0.5 && styles.activeButtonText]}>0.5</Text>
              </Pressable>
              <Pressable style={[styles.button, scanlineIntensity === 1.0 && styles.activeButton]} onPress={() => setScanline(1.0)}>
                <Text style={[styles.buttonText, scanlineIntensity === 1.0 && styles.activeButtonText]}>1.0</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Block Size: {blockSize}px</Text>
            <Text style={styles.controlHint}>Size of glitch blocks</Text>
            <View style={styles.buttonRow}>
              <Pressable style={[styles.button, blockSize === 20 && styles.activeButton]} onPress={() => setBlockSize(20)}>
                <Text style={[styles.buttonText, blockSize === 20 && styles.activeButtonText]}>Fine</Text>
              </Pressable>
              <Pressable style={[styles.button, blockSize === 50 && styles.activeButton]} onPress={() => setBlockSize(50)}>
                <Text style={[styles.buttonText, blockSize === 50 && styles.activeButtonText]}>Default</Text>
              </Pressable>
              <Pressable style={[styles.button, blockSize === 100 && styles.activeButton]} onPress={() => setBlockSize(100)}>
                <Text style={[styles.buttonText, blockSize === 100 && styles.activeButtonText]}>Chunky</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Grain Intensity: {grainIntensity.toFixed(2)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.04, 0.1].map((val) => (
                <Pressable key={val} style={[styles.button, grainIntensity === val && styles.activeButton]} onPress={() => setGrainIntensity(val)}>
                  <Text style={[styles.buttonText, grainIntensity === val && styles.activeButtonText]}>{val === 0.0 ? 'Off' : val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Vignette Strength: {vignetteStrength.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.5, 1.0].map((val) => (
                <Pressable key={val} style={[styles.button, vignetteStrength === val && styles.activeButton]} onPress={() => setVignetteStrength(val)}>
                  <Text style={[styles.buttonText, vignetteStrength === val && styles.activeButtonText]}>{val === 0.0 ? 'Off' : val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Chromatic Spread: {chromaticSpread.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, chromaticSpread === val && styles.activeButton]} onPress={() => setChromaticSpread(val)}>
                  <Text style={[styles.buttonText, chromaticSpread === val && styles.activeButtonText]}>{val}</Text>
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
  container: {
    flex: 1,
    backgroundColor: '#0a0a0a',
  },
  header: {
    padding: 20,
    paddingTop: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#1a1a2e',
  },
  backButton: {
    marginBottom: 10,
  },
  backText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#888',
  },
  content: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: 40,
  },
  preview: {
    width: '100%',
    height: 300,
    marginBottom: 20,
  },
  shader: {
    flex: 1,
  },
  shaderContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  backgroundImage: {
    position: 'absolute',
    width: '100%',
    height: '100%',
  },
  overlay: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 30,
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
  },
  contentTitle: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 12,
    textAlign: 'center',
    letterSpacing: 4,
  },
  contentText: {
    color: '#aaa',
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 20,
  },
  statusBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.2)',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#ffffff',
    marginRight: 8,
  },
  statusText: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: '600',
  },
  controls: {
    padding: 20,
  },
  controlGroup: {
    marginBottom: 24,
  },
  controlLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#ffffff',
    marginBottom: 4,
  },
  controlHint: {
    fontSize: 12,
    color: '#666',
    marginBottom: 12,
  },
  buttonRow: {
    flexDirection: 'row',
    gap: 10,
  },
  button: { flex: 1, backgroundColor: '#000000', paddingVertical: 12, borderRadius: 10, alignItems: 'center', borderWidth: 1, borderColor: '#ffffff' },
  activeButton: { backgroundColor: '#ffffff' },
  buttonText: { color: '#ffffff', fontSize: 14, fontWeight: '600' },
  activeButtonText: { color: '#000000' },
});
