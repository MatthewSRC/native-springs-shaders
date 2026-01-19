import React, { useState } from 'react';
import { StyleSheet, Text, View, ScrollView, Pressable } from 'react-native';
import { FireworksOverlay } from '@native-springs/shaders';

interface FireworksOverlayScreenProps {
  onBack: () => void;
}

export const FireworksOverlayScreen: React.FC<FireworksOverlayScreenProps> = ({ onBack }) => {
  const [intensity, setIntensity] = useState(1.0);
  const [colorMode, setColorMode] = useState<'rainbow' | 'custom'>('rainbow');
  const [color, setColor] = useState<[number, number, number]>([1.0, 0.5, 0.0]);
  const [speed, setSpeed] = useState(0.5);
  const [frequency, setFrequency] = useState(1.5);
  const [sizeRange, setSizeRange] = useState<'small' | 'medium' | 'large'>('medium');
  const [sharpness, setSharpness] = useState(1.5);
  const [particleCount, setParticleCount] = useState(50);
  const [gravity, setGravity] = useState(0.4);

  const sizeRanges = {
    small: { min: 0.15, max: 0.35 },
    medium: { min: 0.2, max: 0.6 },
    large: { min: 0.4, max: 1.0 },
  };

  const colorPresets: Record<string, [number, number, number]> = {
    orange: [1.0, 0.5, 0.0],
    red: [1.0, 0.1, 0.1],
    blue: [0.2, 0.5, 1.0],
    purple: [0.8, 0.2, 1.0],
    green: [0.2, 1.0, 0.4],
    gold: [1.0, 0.85, 0.0],
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
          <View style={styles.shaderContent}>
            <View style={styles.overlay}>
              <Text style={styles.contentTitle}>Fireworks Overlay</Text>
            </View>
          </View>
          <FireworksOverlay
            parameters={{
              intensity,
              useCustomColor: colorMode === 'custom',
              color: color,
              speed,
              frequency,
              minSize: sizeRanges[sizeRange].min,
              maxSize: sizeRanges[sizeRange].max,
              minDuration: 1.0,
              maxDuration: 2.5,
              sharpness,
              particleCount,
              gravity,
            }}
            style={styles.overlayShader}
          />
        </View>

        <View style={styles.controls}>
          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Intensity: {intensity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.0].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, intensity === val && styles.activeButton]}
                  onPress={() => setIntensity(val)}
                >
                  <Text style={[styles.buttonText, intensity === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Color Mode</Text>
            <View style={styles.buttonRow}>
              <Pressable
                style={[styles.button, styles.flexButton, colorMode === 'rainbow' && styles.activeButton]}
                onPress={() => setColorMode('rainbow')}
              >
                <Text style={[styles.buttonText, colorMode === 'rainbow' && styles.activeButtonText]}>Multi Color</Text>
              </Pressable>
              <Pressable
                style={[styles.button, styles.flexButton, colorMode === 'custom' && styles.activeButton]}
                onPress={() => setColorMode('custom')}
              >
                <Text style={[styles.buttonText, colorMode === 'custom' && styles.activeButtonText]}>Custom</Text>
              </Pressable>
            </View>
          </View>

          {colorMode === 'custom' && (
            <View style={styles.controlGroup}>
              <Text style={styles.controlLabel}>Custom Color</Text>
              <View style={styles.colorGrid}>
                {Object.entries(colorPresets).map(([name, color]) => (
                  <Pressable
                    key={name}
                    style={[
                      styles.colorButton,
                      color[0] === colorPresets[name][0] &&
                      color[1] === colorPresets[name][1] &&
                      color[2] === colorPresets[name][2] &&
                      {
                        backgroundColor: `rgb(${colorPresets[name][0] * 255}, ${colorPresets[name][1] * 255}, ${colorPresets[name][2] * 255})`,
                      },
                    ]}
                    onPress={() => setColor(colorPresets[name])}
                  >
                    <Text style={styles.colorButtonText}>{name}</Text>
                  </Pressable>
                ))}
              </View>
            </View>
          )}

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Speed: {speed.toFixed(2)}x</Text>
            <View style={styles.buttonRow}>
              {[0.25, 0.5, 0.75, 1.0].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, speed === val && styles.activeButton]}
                  onPress={() => setSpeed(val)}
                >
                  <Text style={[styles.buttonText, speed === val && styles.activeButtonText]}>{val}x</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Frequency: {frequency.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.5].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, frequency === val && styles.activeButton]}
                  onPress={() => setFrequency(val)}
                >
                  <Text style={[styles.buttonText, frequency === val && styles.activeButtonText]}>{val === 0.5 ? 'Sparse' : val === 2.5 ? 'Dense' : val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Explosion Size</Text>
            <View style={styles.buttonRow}>
              {(['small', 'medium', 'large'] as const).map((size) => (
                <Pressable
                  key={size}
                  style={[styles.button, styles.flexButton, sizeRange === size && styles.activeButton]}
                  onPress={() => setSizeRange(size)}
                >
                  <Text style={[styles.buttonText, sizeRange === size && styles.activeButtonText]}>{size.charAt(0).toUpperCase() + size.slice(1)}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Sharpness: {sharpness.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.5].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, sharpness === val && styles.activeButton]}
                  onPress={() => setSharpness(val)}
                >
                  <Text style={[styles.buttonText, sharpness === val && styles.activeButtonText]}>{val === 0.5 ? 'Soft' : val === 2.5 ? 'Sharp' : val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Particle Count: {particleCount}</Text>
            <View style={styles.buttonRow}>
              {[30, 50, 80].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, particleCount === val && styles.activeButton]}
                  onPress={() => setParticleCount(val)}
                >
                  <Text style={[styles.buttonText, particleCount === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Gravity: {gravity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.1, 0.4, 0.8].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, gravity === val && styles.activeButton]}
                  onPress={() => setGravity(val)}
                >
                  <Text style={[styles.buttonText, gravity === val && styles.activeButtonText]}>{val}</Text>
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
  preview: { width: '100%', height: 350, marginBottom: 20, position: 'relative' },
  shaderContent: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  overlay: { padding: 30, backgroundColor: 'rgba(0, 0, 0, 0.3)', alignItems: 'center', zIndex: 1 },
  overlayShader: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, zIndex: 2 },
  contentTitle: { fontSize: 28, fontWeight: 'bold', color: '#fff', marginBottom: 8 },
  contentText: { color: '#aaa', fontSize: 14 },
  controls: { padding: 20 },
  controlGroup: { marginBottom: 20 },
  controlLabel: { fontSize: 16, fontWeight: '600', color: '#ffffff', marginBottom: 8 },
  buttonRow: { flexDirection: 'row', gap: 10 },
  flexButton: { flex: 1 },
  button: { flex: 1, backgroundColor: '#000000', paddingVertical: 12, borderRadius: 10, alignItems: 'center', borderWidth: 1, borderColor: '#ffffff' },
  activeButton: { backgroundColor: '#ffffff' },
  buttonText: { color: '#ffffff', fontSize: 14, fontWeight: '600' },
  activeButtonText: { color: '#000000' },
  colorGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  colorButton: {
    width: 100,
    height: 50,
    borderRadius: 10,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: 'transparent',
  },
  colorButtonText: {
    color: '#ffffff',
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'capitalize',
    textShadowColor: 'rgba(0, 0, 0, 0.75)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 3,
  },
});
