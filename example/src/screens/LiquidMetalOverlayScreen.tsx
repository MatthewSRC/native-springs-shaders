import React, { useState } from 'react';
import { StyleSheet, Text, View, ScrollView, Pressable } from 'react-native';
import { LiquidMetalOverlay } from '@native-springs/shaders';

interface LiquidMetalOverlayScreenProps {
  onBack: () => void;
}

export const LiquidMetalOverlayScreen: React.FC<LiquidMetalOverlayScreenProps> = ({ onBack }) => {
  const [intensity, setIntensity] = useState(1.0);
  const [borderWidth, setBorderWidth] = useState(15.0);
  const [flowSpeed, setFlowSpeed] = useState(1.0);
  const [stripeCount, setStripeCount] = useState(2.0);
  const [distortion, setDistortion] = useState(1);
  const [chromaticAberration, setChromaticAberration] = useState(2.0);
  const [colorPreset, setColorPreset] = useState<'silver' | 'gold' | 'copper' | 'chrome'>('chrome');
  const [cornerRadius, setCornerRadius] = useState(24);
  const [flowOffset, setFlowOffset] = useState<[number, number]>([0.0, 0.0]);
  const [flowAngle, setFlowAngle] = useState(70);
  const [specular, setSpecular] = useState({ intensity: 1.0, position: [0.0, 0.0] as [number, number], size: 0.5 });
  const [roughness, setRoughness] = useState(0.0);

  const colorPresets: Record<string, { base: [number, number, number] | string; highlight: [number, number, number] | string }> = {
    silver: { base: "000000", highlight: 'ffffff' },
    gold: { base: 'a67c00', highlight: 'ffdc73' },
    copper: { base: 'a96148', highlight: 'bf816a'},
    chrome: { base: "ffffff", highlight: '000000' },
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
              <Text style={styles.contentTitle}>Liquid Metal</Text>
              <Text style={styles.contentSubtitle}>Chrome Border Effect</Text>
            </View>
          </View>
          <LiquidMetalOverlay
            parameters={{
              intensity,
              borderWidth,
              cornerRadius,
              baseColor: colorPresets[colorPreset].base,
              highlightColor: colorPresets[colorPreset].highlight,
              flowSpeed,
              stripeCount,
              distortion,
              chromaticAberration,
              flowOffset,
              flowAngle,
              specular,
              roughness,
            }}
            style={styles.overlayShader}
          />
        </View>

        {/* Button Demo Section */}
        <View style={styles.buttonDemoSection}>
          <Text style={styles.sectionTitle}>Button Examples</Text>
          <View style={styles.buttonDemoRow}>
            <View style={styles.demoButtonContainer}>
              <Pressable style={styles.demoButton}>
                <Text style={styles.demoButtonText}>Submit</Text>
              </Pressable>
              <LiquidMetalOverlay
                parameters={{
              intensity,
              borderWidth: 4,
              cornerRadius: 8,
              baseColor: colorPresets[colorPreset].base,
              highlightColor: colorPresets[colorPreset].highlight,
              flowSpeed,
              stripeCount,
              distortion,
              chromaticAberration,
              flowOffset,
              flowAngle,
              specular,
              roughness,
                }}
                style={styles.buttonOverlay}
              />
            </View>
            <View style={styles.demoButtonContainer}>
              <Pressable style={styles.demoButton}>
                <Text style={styles.demoButtonText}>Cancel</Text>
              </Pressable>
              <LiquidMetalOverlay
                parameters={{
                  intensity: 0.7,
                  borderWidth: 2,
                  cornerRadius: 8,
                  baseColor: [0.5, 0.5, 0.55],
                  highlightColor: [0.8, 0.8, 0.85],
                  flowSpeed: 0.5,
                  stripeCount: 4.0,
                  distortion: 0.3,
                  chromaticAberration: 0.8,
                  flowOffset: [0.0, 0.0],
                  flowAngle: 70,
                }}
                style={styles.buttonOverlay}
              />
            </View>
          </View>
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
            <Text style={styles.controlLabel}>Border Width: {borderWidth.toFixed(0)}px</Text>
            <View style={styles.buttonRow}>
              {[3, 6, 10, 15].map((val) => (
                <Pressable key={val} style={[styles.button, borderWidth === val && styles.activeButton]} onPress={() => setBorderWidth(val)}>
                  <Text style={[styles.buttonText, borderWidth === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Metal Type</Text>
            <View style={styles.buttonRow}>
              {(['chrome', 'silver', 'gold', 'copper'] as const).map((preset) => (
                <Pressable
                  key={preset}
                  style={[styles.button, colorPreset === preset && styles.activeButton]}
                  onPress={() => setColorPreset(preset)}
                >
                  <Text style={[styles.buttonText, colorPreset === preset && styles.activeButtonText]}>
                    {preset.charAt(0).toUpperCase() + preset.slice(1)}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Roughness: {roughness.toFixed(2)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.25, 0.5, 0.75, 1.0].map((val) => (
                <Pressable key={val} style={[styles.button, roughness === val && styles.activeButton]} onPress={() => setRoughness(val)}>
                  <Text style={[styles.buttonText, roughness === val && styles.activeButtonText]}>
                    {val === 0 ? 'Mirror' : val === 0.25 ? 'Polished' : val === 0.5 ? 'Satin' : val === 0.75 ? 'Brushed' : 'Matte'}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Flow Speed: {flowSpeed.toFixed(1)}x</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, flowSpeed === val && styles.activeButton]} onPress={() => setFlowSpeed(val)}>
                  <Text style={[styles.buttonText, flowSpeed === val && styles.activeButtonText]}>{val}x</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Stripe Count: {stripeCount.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[2.0, 4.0, 6.0, 8.0].map((val) => (
                <Pressable key={val} style={[styles.button, stripeCount === val && styles.activeButton]} onPress={() => setStripeCount(val)}>
                  <Text style={[styles.buttonText, stripeCount === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Distortion: {distortion.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.3, 0.6, 1.0].map((val) => (
                <Pressable key={val} style={[styles.button, distortion === val && styles.activeButton]} onPress={() => setDistortion(val)}>
                  <Text style={[styles.buttonText, distortion === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Chromatic: {chromaticAberration.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.5, 1.0, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, chromaticAberration === val && styles.activeButton]} onPress={() => setChromaticAberration(val)}>
                  <Text style={[styles.buttonText, chromaticAberration === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Corner Radius: {cornerRadius}px</Text>
            <View style={styles.buttonRow}>
              {[0, 8, 16, 32].map((val) => (
                <Pressable key={val} style={[styles.button, cornerRadius === val && styles.activeButton]} onPress={() => setCornerRadius(val)}>
                  <Text style={[styles.buttonText, cornerRadius === val && styles.activeButtonText]}>
                    {val === 0 ? 'Sharp' : val === 8 ? 'Small' : val === 16 ? 'Medium' : 'Large'}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Flow Offset X: {flowOffset[0].toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[-0.5, -0.25, 0.0, 0.25, 0.5].map((val) => (
                <Pressable key={val} style={[styles.button, flowOffset[0] === val && styles.activeButton]} onPress={() => setFlowOffset([val, flowOffset[1]])}>
                  <Text style={[styles.buttonText, flowOffset[0] === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Flow Offset Y: {flowOffset[1].toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[-0.5, -0.25, 0.0, 0.25, 0.5].map((val) => (
                <Pressable key={val} style={[styles.button, flowOffset[1] === val && styles.activeButton]} onPress={() => setFlowOffset([flowOffset[0], val])}>
                  <Text style={[styles.buttonText, flowOffset[1] === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Flow Angle: {flowAngle}°</Text>
            <View style={styles.buttonRow}>
              {[0, 45, 70, 90, 135].map((val) => (
                <Pressable key={val} style={[styles.button, flowAngle === val && styles.activeButton]} onPress={() => setFlowAngle(val)}>
                  <Text style={[styles.buttonText, flowAngle === val && styles.activeButtonText]}>{val}°</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Specular Intensity: {specular.intensity.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.3, 0.6, 1.0].map((val) => (
                <Pressable key={val} style={[styles.button, specular.intensity === val && styles.activeButton]} onPress={() => setSpecular({ ...specular, intensity: val })}>
                  <Text style={[styles.buttonText, specular.intensity === val && styles.activeButtonText]}>
                    {val === 0 ? 'Off' : val}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Specular Position X: {specular.position[0].toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[-0.8, -0.4, 0.0, 0.4, 0.8].map((val) => (
                <Pressable key={val} style={[styles.button, specular.position[0] === val && styles.activeButton]} onPress={() => setSpecular({ ...specular, position: [val, specular.position[1]] })}>
                  <Text style={[styles.buttonText, specular.position[0] === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Specular Position Y: {specular.position[1].toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[-0.8, -0.4, 0.0, 0.4, 0.8].map((val) => (
                <Pressable key={val} style={[styles.button, specular.position[1] === val && styles.activeButton]} onPress={() => setSpecular({ ...specular, position: [specular.position[0], val] })}>
                  <Text style={[styles.buttonText, specular.position[1] === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Specular Size: {specular.size.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.1, 0.2, 0.3, 0.5].map((val) => (
                <Pressable key={val} style={[styles.button, specular.size === val && styles.activeButton]} onPress={() => setSpecular({ ...specular, size: val })}>
                  <Text style={[styles.buttonText, specular.size === val && styles.activeButtonText]}>
                    {val === 0.1 ? 'Small' : val === 0.2 ? 'Medium' : val === 0.3 ? 'Large' : 'XL'}
                  </Text>
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
  content: { flex: 1 },
  scrollContent: { paddingBottom: 40 },
  preview: { width: '100%', height: 250, marginBottom: 20, position: 'relative' },
  shaderContent: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  overlay: { padding: 30, backgroundColor: 'rgba(0, 0, 0, 0.5)', alignItems: 'center', zIndex: 1 },
  overlayShader: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, zIndex: 2 },
  contentTitle: { fontSize: 28, fontWeight: 'bold', color: '#fff', marginBottom: 4 },
  contentSubtitle: { fontSize: 14, color: '#aaa' },
  buttonDemoSection: { padding: 20, paddingTop: 0 },
  sectionTitle: { fontSize: 18, fontWeight: '600', color: '#ffffff', marginBottom: 16 },
  buttonDemoRow: { flexDirection: 'row', gap: 16 },
  demoButtonContainer: { flex: 1, height: 50, position: 'relative' },
  demoButton: {
    flex: 1,
    backgroundColor: 'rgba(20, 20, 25, 0.9)',
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 8,
  },
  demoButtonText: { color: '#ffffff', fontSize: 16, fontWeight: '600' },
  buttonOverlay: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, zIndex: 2, borderRadius: 8 },
  controls: { padding: 20 },
  controlGroup: { marginBottom: 20 },
  controlLabel: { fontSize: 16, fontWeight: '600', color: '#ffffff', marginBottom: 8 },
  buttonRow: { flexDirection: 'row', gap: 10 },
  button: { flex: 1, backgroundColor: '#000000', paddingVertical: 12, borderRadius: 10, alignItems: 'center', borderWidth: 1, borderColor: '#ffffff' },
  activeButton: { backgroundColor: '#ffffff' },
  buttonText: { color: '#ffffff', fontSize: 14, fontWeight: '600' },
  activeButtonText: { color: '#000000' },
});
