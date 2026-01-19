import React, { useState } from 'react';
import { StyleSheet, Text, View, ScrollView, Pressable } from 'react-native';
import { AuroraOverlay } from '@native-springs/shaders';

interface AuroraOverlayScreenProps {
  onBack: () => void;
}

export const AuroraOverlayScreen: React.FC<AuroraOverlayScreenProps> = ({ onBack }) => {
  const [intensity, setIntensity] = useState(1.0);
  const [color, setColor] = useState<[number, number, number]>([0.3, 0.7, 1.0]);
  const [borderFade, setBorderFade] = useState(0.0);
  const [direction, setDirection] = useState<'up' | 'down' | 'left' | 'right'>('up');

  const directionVectors: Record<string, [number, number]> = {
    up: [0, -1],
    down: [0, 1],
    left: [-1, 0],
    right: [1, 0],
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
              <Text style={styles.contentTitle}>Aurora Overlay</Text>
            </View>
          </View>
          <AuroraOverlay
            parameters={{
              intensity,
              color: color,
              borderFade,
              direction: directionVectors[direction],
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
            <Text style={styles.controlLabel}>Color Tint</Text>
            <View style={styles.buttonRow}>
              <Pressable style={styles.button} onPress={() => setColor([0.3, 0.7, 1.0])}>
                <Text style={styles.buttonText}>Blue</Text>
              </Pressable>
              <Pressable style={styles.button} onPress={() => setColor([0.3, 1.0, 0.5])}>
                <Text style={styles.buttonText}>Green</Text>
              </Pressable>
              <Pressable style={styles.button} onPress={() => setColor([1.0, 0.3, 0.8])}>
                <Text style={styles.buttonText}>Pink</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Border Fade: {borderFade.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.5, 1.0].map((val) => (
                <Pressable key={val} style={[styles.button, borderFade === val && styles.activeButton]} onPress={() => setBorderFade(val)}>
                  <Text style={[styles.buttonText, borderFade === val && styles.activeButtonText]}>{val}</Text>
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
  subtitle: { fontSize: 14, color: '#888' },
  content: { flex: 1 },
  scrollContent: { paddingBottom: 40 },
  preview: { width: '100%', height: 350, marginBottom: 20, position: 'relative' },
  shaderContent: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  backgroundImage: { position: 'absolute', width: '100%', height: '100%' },
  overlay: { padding: 30, backgroundColor: 'rgba(0, 0, 0, 0.3)', alignItems: 'center', zIndex: 1 },
  overlayShader: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, zIndex: 2 },
  contentTitle: { fontSize: 28, fontWeight: 'bold', color: '#fff', marginBottom: 8 },
  controls: { padding: 20 },
  controlGroup: { marginBottom: 20 },
  controlLabel: { fontSize: 16, fontWeight: '600', color: '#ffffff', marginBottom: 8 },
  buttonRow: { flexDirection: 'row', gap: 10 },
  button: { flex: 1, backgroundColor: '#000000', paddingVertical: 12, borderRadius: 10, alignItems: 'center', borderWidth: 1, borderColor: '#ffffff' },
  activeButton: { backgroundColor: '#ffffff' },
  buttonText: { color: '#ffffff', fontSize: 14, fontWeight: '600' },
  activeButtonText: { color: '#000000' },
});
