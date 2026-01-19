import React, { useState } from 'react';
import { StyleSheet, Text, View, Pressable, ScrollView } from 'react-native';
import { SparklesOverlay } from '@native-springs/shaders';

interface SparklesOverlayScreenProps {
  onBack: () => void;
}

export const SparklesOverlayScreen: React.FC<SparklesOverlayScreenProps> = ({ onBack }) => {
  const [intensity, setIntensity] = useState(1.0);
  const [density, setDensity] = useState(3.0);
  const [size, setSize] = useState(1.0);
  const [speed, setSpeed] = useState(1.0);
  const [colorize, setColorize] = useState(true);
  const [color, setColor] = useState<[number, number, number]>([1.0, 1.0, 1.0]);
  const [twinkleSpeed, setTwinkleSpeed] = useState(0.5);
  const [brightnessMultiplier, setBrightnessMultiplier] = useState(2.5);

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
              <Text style={styles.contentTitle}>Sparkles Overlay</Text>
            </View>
          </View>
          <SparklesOverlay
            parameters={{
              intensity,
              density,
              size,
              speed,
              colorize,
              color: color,
              twinkleSpeed,
              brightnessMultiplier,
            }}
            style={styles.overlayShader}
          />
        </View>

        <View style={styles.controls}>
          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Intensity: {intensity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.3, 0.6, 1.0, 1.5].map((val) => (
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
            <Text style={styles.controlLabel}>Density: {density.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[1.0, 3.0, 5.0, 8.0].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, density === val && styles.activeButton]}
                  onPress={() => setDensity(val)}
                >
                  <Text style={[styles.buttonText, density === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Size: {size.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.0].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, size === val && styles.activeButton]}
                  onPress={() => setSize(val)}
                >
                  <Text style={[styles.buttonText, size === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Speed: {speed.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.0].map((val) => (
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
            <Text style={styles.controlLabel}>Mode</Text>
            <View style={styles.buttonRow}>
              <Pressable
                style={[styles.button, colorize && styles.activeButton]}
                onPress={() => setColorize(true)}
              >
                <Text style={[styles.buttonText, colorize && styles.activeButtonText]}>Rainbow</Text>
              </Pressable>
              <Pressable
                style={[styles.button, !colorize && styles.activeButton]}
                onPress={() => setColorize(false)}
              >
                <Text style={[styles.buttonText, !colorize && styles.activeButtonText]}>Solid</Text>
              </Pressable>
            </View>
          </View>

          {!colorize && (
            <View style={styles.controlGroup}>
              <Text style={styles.controlLabel}>Color</Text>
              <View style={styles.buttonRow}>
                <Pressable
                  style={styles.button}
                  onPress={() => setColor([1.0, 1.0, 1.0])}
                >
                  <Text style={styles.buttonText}>White</Text>
                </Pressable>
                <Pressable
                  style={styles.button}
                  onPress={() => setColor([1.0, 0.84, 0.0])}
                >
                  <Text style={styles.buttonText}>Gold</Text>
                </Pressable>
                <Pressable
                  style={styles.button}
                  onPress={() => setColor([0.5, 0.8, 1.0])}
                >
                  <Text style={styles.buttonText}>Ice</Text>
                </Pressable>
                <Pressable
                  style={styles.button}
                  onPress={() => setColor([1.0, 0.4, 0.7])}
                >
                  <Text style={styles.buttonText}>Pink</Text>
                </Pressable>
              </View>
            </View>
          )}

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Twinkle Speed: {twinkleSpeed.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.2, 0.5, 1.0].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, twinkleSpeed === val && styles.activeButton]}
                  onPress={() => setTwinkleSpeed(val)}
                >
                  <Text style={[styles.buttonText, twinkleSpeed === val && styles.activeButtonText]}>{val}x</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Brightness Multiplier: {brightnessMultiplier.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[1.0, 2.5, 5.0].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, brightnessMultiplier === val && styles.activeButton]}
                  onPress={() => setBrightnessMultiplier(val)}
                >
                  <Text style={[styles.buttonText, brightnessMultiplier === val && styles.activeButtonText]}>{val}x</Text>
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
  button: { flex: 1, backgroundColor: '#000000', paddingVertical: 12, borderRadius: 10, alignItems: 'center', borderWidth: 1, borderColor: '#ffffff' },
  activeButton: { backgroundColor: '#ffffff' },
  buttonText: { color: '#ffffff', fontSize: 14, fontWeight: '600' },
  activeButtonText: { color: '#000000' },
});
