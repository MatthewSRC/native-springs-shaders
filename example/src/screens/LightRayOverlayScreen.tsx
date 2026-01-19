import React, { useState } from 'react';
import { StyleSheet, Text, View, Pressable, ScrollView } from 'react-native';
import { LightRayOverlay } from '@native-springs/shaders';

interface LightRayOverlayScreenProps {
  onBack: () => void;
}

export const LightRayOverlayScreen: React.FC<LightRayOverlayScreenProps> = ({ onBack }) => {
  const [intensity, setIntensity] = useState(0.8);
  const [color, setColor] = useState<[number, number, number]>([1.0, 0.95, 0.8]);
  const [rayPosition, setRayPosition] = useState<[number, number]>([0.7, -0.4]);
  const [speed, setSpeed] = useState(1.5);
  const [depthAttenuation, setDepthAttenuation] = useState(1.0);
  const [rayLength, setRayLength] = useState(1.0);
  const [rayDirection, setRayDirection] = useState<[number, number]>([1.0, -0.116]);
  const [rayWidth, setRayWidth] = useState(1.0);
  const [numRays, setNumRays] = useState(2.0);

  const positionPresets: Record<string, [number, number]> = {
    'Top Right': [0.7, -0.4],
    'Top Left': [0.3, -0.4],
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
              <Text style={styles.contentTitle}>Light Ray Overlay</Text>
            </View>
          </View>
          <LightRayOverlay
            parameters={{
              intensity,
              color: color,
              rayPosition: rayPosition,
              speed,
              depthAttenuation,
              rayLength,
              rayDirection,
              rayWidth,
              numRays,
            }}
            style={styles.overlayShader}
          />
        </View>

        <View style={styles.controls}>
          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Intensity: {intensity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.3, 0.5, 0.8, 1.2].map((val) => (
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
            <Text style={styles.controlLabel}>Ray Color</Text>
            <View style={styles.buttonRow}>
              <Pressable
                style={styles.button}
                onPress={() => setColor([1.0, 0.95, 0.8])}
              >
                <Text style={styles.buttonText}>Warm</Text>
              </Pressable>
              <Pressable
                style={styles.button}
                onPress={() => setColor([0.8, 0.9, 1.0])}
              >
                <Text style={styles.buttonText}>Cool</Text>
              </Pressable>
              <Pressable
                style={styles.button}
                onPress={() => setColor([1.0, 1.0, 1.0])}
              >
                <Text style={styles.buttonText}>White</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Light Position</Text>
            <View style={styles.buttonRow}>
              {Object.keys(positionPresets).map((key) => (
                <Pressable
                  key={key}
                  style={[
                    styles.button,
                    rayPosition[0] === positionPresets[key][0] &&
                    rayPosition[1] === positionPresets[key][1] &&
                    styles.activeButton,
                  ]}
                  onPress={() => setRayPosition(positionPresets[key])}
                >
                  <Text style={[styles.buttonText, rayPosition[0] === positionPresets[key][0] &&
                    rayPosition[1] === positionPresets[key][1] && styles.activeButtonText]}>{key}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Animation Speed: {speed.toFixed(2)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.5].map((val) => (
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
            <Text style={styles.controlLabel}>Depth Attenuation: {depthAttenuation.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.5, 1.0].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, depthAttenuation === val && styles.activeButton]}
                  onPress={() => setDepthAttenuation(val)}
                >
                  <Text style={[styles.buttonText, depthAttenuation === val && styles.activeButtonText]}>
                    {val === 0.0 ? 'Off' : val === 0.5 ? 'Medium' : 'Full'}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Ray Length: {rayLength.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.4, 0.7, 1.0, 1.5].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, rayLength === val && styles.activeButton]}
                  onPress={() => setRayLength(val)}
                >
                  <Text style={[styles.buttonText, rayLength === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Ray Direction</Text>
            <View style={styles.buttonRow}>
              <Pressable
                style={[styles.button, rayDirection[0] === 1.0 && rayDirection[1] === 0.0 && styles.activeButton]}
                onPress={() => setRayDirection([1.0, 0.0])}
              >
                <Text style={[styles.buttonText, rayDirection[0] === 1.0 && rayDirection[1] === 0.0 && styles.activeButtonText]}>Horizontal</Text>
              </Pressable>
              <Pressable
                style={[styles.button, rayDirection[0] === 1.0 && rayDirection[1] === -0.116 && styles.activeButton]}
                onPress={() => setRayDirection([1.0, -0.116])}
              >
                <Text style={[styles.buttonText, rayDirection[0] === 1.0 && rayDirection[1] === -0.116 && styles.activeButtonText]}>Diagonal</Text>
              </Pressable>
              <Pressable
                style={[styles.button, rayDirection[0] === 0.0 && rayDirection[1] === 1.0 && styles.activeButton]}
                onPress={() => setRayDirection([0.0, 1.0])}
              >
                <Text style={[styles.buttonText, rayDirection[0] === 0.0 && rayDirection[1] === 1.0 && styles.activeButtonText]}>Vertical</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Ray Width: {rayWidth.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 2.0].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, rayWidth === val && styles.activeButton]}
                  onPress={() => setRayWidth(val)}
                >
                  <Text style={[styles.buttonText, rayWidth === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Number of Rays: {numRays.toFixed(0)}</Text>
            <View style={styles.buttonRow}>
              {[2.0, 3.0, 4.0, 6.0].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, numRays === val && styles.activeButton]}
                  onPress={() => setNumRays(val)}
                >
                  <Text style={[styles.buttonText, numRays === val && styles.activeButtonText]}>{val}</Text>
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
