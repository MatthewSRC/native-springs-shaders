import React, { useState } from 'react';
import { StyleSheet, Text, View, ScrollView, Pressable } from 'react-native';
import { FireSparksOverlay } from '@native-springs/shaders';

interface FireSparksOverlayScreenProps {
  onBack: () => void;
}

export const FireSparksOverlayScreen: React.FC<FireSparksOverlayScreenProps> = ({ onBack }) => {
  const [intensity, setIntensity] = useState(1.0);
  const [direction, setDirection] = useState<'up' | 'down' | 'left' | 'right'>('up');
  const [travelDistance, setTravelDistance] = useState(1.0);
  const [colorPreset, setColorPreset] = useState<'fire' | 'blue' | 'purple' | 'green'>('fire');
  const [particleSize, setParticleSize] = useState(0.009);
  const [animationSpeed, setAnimationSpeed] = useState(1.5);
  const [smokeIntensity, setSmokeIntensity] = useState(0.8);
  const [particleBloom, setParticleBloom] = useState(1.0);
  const [movementSpeed, setMovementSpeed] = useState(1.0);

  const directionVectors: Record<string, [number, number]> = {
    up: [0, -1],
    down: [0, 1],
    left: [-1, 0],
    right: [1, 0],
  };

  const colorPresets: Record<string, [number, number, number]> = {
    fire: [1.0, 0.4, 0.05],
    blue: [0.2, 0.6, 1.0],
    purple: [0.8, 0.2, 1.0],
    green: [0.2, 1.0, 0.4],
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
              <Text style={styles.contentTitle}>Fire Sparks Overlay</Text>
            </View>
          </View>
          <FireSparksOverlay
            parameters={{
              intensity,
              direction: directionVectors[direction],
              travelDistance,
              color: colorPresets[colorPreset],
              particleSize,
              animationSpeed,
              smokeIntensity,
              particleBloom,
              movementSpeed,
            }}
            style={styles.overlayShader}
          />
        </View>

        <View style={styles.controls}>
          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Intensity: {intensity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5].map((val) => (
                <Pressable key={val} style={[styles.button, intensity === val && styles.activeButton]} onPress={() => setIntensity(val)}>
                  <Text style={[styles.buttonText, intensity === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Direction</Text>
            <View style={styles.buttonRow}>
              {['up', 'down', 'left', 'right'].map((dir) => (
                <Pressable key={dir} style={[styles.button, direction === dir && styles.activeButton]} onPress={() => setDirection(dir as any)}>
                  <Text style={[styles.buttonText, direction === dir && styles.activeButtonText]}>{dir}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Travel Distance: {travelDistance.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, travelDistance === val && styles.activeButton]} onPress={() => setTravelDistance(val)}>
                  <Text style={[styles.buttonText, travelDistance === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Color</Text>
            <View style={styles.buttonRow}>
              {[
                { key: 'fire', label: 'Fire' },
                { key: 'blue', label: 'Blue' },
                { key: 'purple', label: 'Purple' },
                { key: 'green', label: 'Green' },
              ].map((preset) => (
                <Pressable
                  key={preset.key}
                  style={[
                    styles.button,
                    colorPreset === preset.key && styles.activeButton,
                  ]}
                  onPress={() => setColorPreset(preset.key as any)}
                >
                  <Text style={[styles.buttonText, colorPreset === preset.key && styles.activeButtonText]}>{preset.label}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Particle Size: {particleSize.toFixed(4)}</Text>
            <View style={styles.buttonRow}>
              {[0.005, 0.009, 0.015, 0.02].map((val) => (
                <Pressable key={val} style={[styles.button, Math.abs(particleSize - val) < 0.001 && styles.activeButton]} onPress={() => setParticleSize(val)}>
                  <Text style={[styles.buttonText, Math.abs(particleSize - val) < 0.001 && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Animation Speed: {animationSpeed.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.5].map((val) => (
                <Pressable key={val} style={[styles.button, animationSpeed === val && styles.activeButton]} onPress={() => setAnimationSpeed(val)}>
                  <Text style={[styles.buttonText, animationSpeed === val && styles.activeButtonText]}>{val}x</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Smoke Intensity: {smokeIntensity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.8, 1.5].map((val) => (
                <Pressable key={val} style={[styles.button, smokeIntensity === val && styles.activeButton]} onPress={() => setSmokeIntensity(val)}>
                  <Text style={[styles.buttonText, smokeIntensity === val && styles.activeButtonText]}>{val === 0.0 ? 'Off' : val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Particle Bloom: {particleBloom.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.3, 1.0, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, particleBloom === val && styles.activeButton]} onPress={() => setParticleBloom(val)}>
                  <Text style={[styles.buttonText, particleBloom === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Movement Speed: {movementSpeed.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.3, 1.0, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, movementSpeed === val && styles.activeButton]} onPress={() => setMovementSpeed(val)}>
                  <Text style={[styles.buttonText, movementSpeed === val && styles.activeButtonText]}>{val}x</Text>
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
  backgroundImage: { position: 'absolute', width: '100%', height: '100%' },
  overlay: { padding: 30, backgroundColor: 'rgba(0, 0, 0, 0.3)', alignItems: 'center', zIndex: 1 },
  overlayShader: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, zIndex: 2 },
  contentTitle: { fontSize: 28, fontWeight: 'bold', color: '#ffffff', marginBottom: 8 },
  controls: { padding: 20 },
  controlGroup: { marginBottom: 20 },
  controlLabel: { fontSize: 16, fontWeight: '600', color: '#ffffff', marginBottom: 8 },
  buttonRow: { flexDirection: 'row', gap: 10 },
  button: { flex: 1, backgroundColor: '#000000', paddingVertical: 12, borderRadius: 10, alignItems: 'center', borderWidth: 1, borderColor: '#ffffff' },
  activeButton: { backgroundColor: '#ffffff' },
  buttonText: { color: '#ffffff', fontSize: 14, fontWeight: '600' },
  activeButtonText: { color: '#000000' },
});
