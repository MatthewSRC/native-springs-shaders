import React, { useState } from "react";
import { StyleSheet, Text, View, ScrollView, Pressable } from "react-native";
import { NeonOverlay } from "@native-springs/shaders";

interface NeonOverlayScreenProps {
  onBack: () => void;
}

export const NeonOverlayScreen: React.FC<NeonOverlayScreenProps> = ({
  onBack,
}) => {
  const [intensity, setIntensity] = useState(1.0);
  const [borderWidth, setBorderWidth] = useState(3.0);
  const [cornerRadius, setCornerRadius] = useState(16);
  const [colorPreset, setColorPreset] = useState<
    "cyan" | "magenta" | "green" | "orange" | "rainbow"
  >("cyan");
  const [glowSize, setGlowSize] = useState(4.0);
  const [glowFalloff, setGlowFalloff] = useState(1.2);
  const [flowSpeed, setFlowSpeed] = useState(1.0);
  const [flowIntensity, setFlowIntensity] = useState(1.0);
  const [pulseSpeed, setPulseSpeed] = useState(1.0);
  const [pulseIntensity, setPulseIntensity] = useState(0.2);
  const [flickerIntensity, setFlickerIntensity] = useState(0.0);
  const [colorBlend, setColorBlend] = useState(0.0);
  const [inset, setInset] = useState(15.0);

  const colorPresets: Record<string, { primary: string; secondary: string }> = {
    cyan: { primary: "#00FFE6", secondary: "#00FFE6" },
    magenta: { primary: "#FF00CC", secondary: "#FF00CC" },
    green: { primary: "#00FF66", secondary: "#00FF66" },
    orange: { primary: "#FF6600", secondary: "#FFCC00" },
    rainbow: { primary: "#00FFE6", secondary: "#FF00CC" },
  };

  const currentColors = colorPresets[colorPreset];
  const effectiveColorBlend = colorPreset === "rainbow" ? 0.8 : colorBlend;

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Pressable onPress={onBack} style={styles.backButton}>
          <Text style={styles.backText}>← Back</Text>
        </Pressable>
      </View>

      <ScrollView
        style={styles.content}
        contentContainerStyle={styles.scrollContent}
      >
        <View style={styles.preview}>
          <View style={styles.shaderContent}>
            <View style={styles.overlay}>
              <Text style={styles.contentTitle}>Neon Glow</Text>
              <Text style={styles.contentSubtitle}>Animated Border Effect</Text>
            </View>
          </View>
          <NeonOverlay
            parameters={{
              intensity,
              borderWidth,
              cornerRadius,
              color: currentColors.primary,
              secondaryColor: currentColors.secondary,
              glowSize,
              glowFalloff,
              flowSpeed,
              flowIntensity,
              pulseSpeed,
              pulseIntensity,
              flickerIntensity,
              colorBlend: effectiveColorBlend,
              inset,
            }}
            style={styles.overlayShader}
          />
        </View>

        <View style={styles.buttonDemoSection}>
          <Text style={styles.sectionTitle}>Button Examples</Text>
          <View style={styles.buttonDemoRow}>
            <View style={styles.demoButtonContainer}>
              <Pressable style={styles.demoButton}>
                <Text style={styles.demoButtonText}>Submit</Text>
              </Pressable>
              <NeonOverlay
                parameters={{
                  intensity,
                  borderWidth: 2,
                  cornerRadius: 8,
                  color: currentColors.primary,
                  secondaryColor: currentColors.secondary,
                  glowSize: 2.5,
                  glowFalloff,
                  flowSpeed,
                  flowIntensity,
                  pulseSpeed,
                  pulseIntensity,
                  flickerIntensity,
                  colorBlend: effectiveColorBlend,
                  inset: 0,
                }}
                style={styles.buttonOverlay}
              />
            </View>
            <View style={styles.demoButtonContainer}>
              <Pressable style={styles.demoButton}>
                <Text style={styles.demoButtonText}>Cancel</Text>
              </Pressable>
              <NeonOverlay
                parameters={{
                  intensity: 0.6,
                  borderWidth: 2,
                  cornerRadius: 8,
                  color: "#FF4444",
                  secondaryColor: "#FF4444",
                  glowSize: 2.0,
                  glowFalloff: 2.0,
                  flowSpeed: 0.5,
                  flowIntensity: 0.3,
                  pulseSpeed: 0.0,
                  pulseIntensity: 0.0,
                  flickerIntensity: 0.2,
                  colorBlend: 0.0,
                  inset: 0,
                }}
                style={styles.buttonOverlay}
              />
            </View>
          </View>
        </View>

        <View style={styles.controls}>
          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Color Preset</Text>
            <View style={styles.buttonRow}>
              {(["cyan", "magenta", "green", "orange", "rainbow"] as const).map(
                (preset) => (
                  <Pressable
                    key={preset}
                    style={[
                      styles.button,
                      colorPreset === preset && styles.activeButton,
                    ]}
                    onPress={() => setColorPreset(preset)}
                  >
                    <Text
                      style={[
                        styles.buttonText,
                        colorPreset === preset && styles.activeButtonText,
                      ]}
                    >
                      {preset.charAt(0).toUpperCase() + preset.slice(1)}
                    </Text>
                  </Pressable>
                ),
              )}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Intensity: {intensity.toFixed(1)}
            </Text>
            <View style={styles.buttonRow}>
              {[0.5, 0.75, 1.0, 1.5].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    intensity === val && styles.activeButton,
                  ]}
                  onPress={() => setIntensity(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      intensity === val && styles.activeButtonText,
                    ]}
                  >
                    {val}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Border Width: {borderWidth.toFixed(0)}px
            </Text>
            <View style={styles.buttonRow}>
              {[2, 3, 5, 8].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    borderWidth === val && styles.activeButton,
                  ]}
                  onPress={() => setBorderWidth(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      borderWidth === val && styles.activeButtonText,
                    ]}
                  >
                    {val}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Corner Radius: {cornerRadius}px
            </Text>
            <View style={styles.buttonRow}>
              {[0, 8, 16, 32].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    cornerRadius === val && styles.activeButton,
                  ]}
                  onPress={() => setCornerRadius(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      cornerRadius === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0
                      ? "Sharp"
                      : val === 8
                        ? "Small"
                        : val === 16
                          ? "Medium"
                          : "Large"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Glow Size: {glowSize.toFixed(1)}x
            </Text>
            <View style={styles.buttonRow}>
              {[2.0, 4.0, 6.0, 10.0].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    glowSize === val && styles.activeButton,
                  ]}
                  onPress={() => setGlowSize(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      glowSize === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 2.0
                      ? "Tight"
                      : val === 4.0
                        ? "Normal"
                        : val === 6.0
                          ? "Wide"
                          : "Huge"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Glow Falloff: {glowFalloff.toFixed(1)}
            </Text>
            <View style={styles.buttonRow}>
              {[0.8, 1.2, 1.8, 2.5].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    glowFalloff === val && styles.activeButton,
                  ]}
                  onPress={() => setGlowFalloff(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      glowFalloff === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0.8
                      ? "Soft"
                      : val === 1.2
                        ? "Normal"
                        : val === 1.8
                          ? "Sharp"
                          : "Crisp"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Flow Speed: {flowSpeed.toFixed(1)}x
            </Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.5, 1.0, 2.0].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    flowSpeed === val && styles.activeButton,
                  ]}
                  onPress={() => setFlowSpeed(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      flowSpeed === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0 ? "Off" : val + "x"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Flow Intensity: {flowIntensity.toFixed(1)}
            </Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.5, 1.0, 2.0].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    flowIntensity === val && styles.activeButton,
                  ]}
                  onPress={() => setFlowIntensity(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      flowIntensity === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0
                      ? "Off"
                      : val === 0.5
                        ? "Subtle"
                        : val === 1.0
                          ? "Normal"
                          : "Bright"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Pulse Speed: {pulseSpeed.toFixed(1)}x
            </Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.5, 1.0, 2.0].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    pulseSpeed === val && styles.activeButton,
                  ]}
                  onPress={() => setPulseSpeed(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      pulseSpeed === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0 ? "Off" : val + "x"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Pulse Intensity: {pulseIntensity.toFixed(1)}
            </Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.2, 0.5, 1.0].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    pulseIntensity === val && styles.activeButton,
                  ]}
                  onPress={() => setPulseIntensity(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      pulseIntensity === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0
                      ? "Off"
                      : val === 0.2
                        ? "Subtle"
                        : val === 0.5
                          ? "Medium"
                          : "Strong"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Flicker: {flickerIntensity.toFixed(1)}
            </Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.2, 0.5, 0.8].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    flickerIntensity === val && styles.activeButton,
                  ]}
                  onPress={() => setFlickerIntensity(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      flickerIntensity === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0
                      ? "Off"
                      : val === 0.2
                        ? "Subtle"
                        : val === 0.5
                          ? "Medium"
                          : "Strong"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Color Blend: {colorBlend.toFixed(1)}
            </Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.3, 0.6, 1.0].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    colorBlend === val && styles.activeButton,
                  ]}
                  onPress={() => setColorBlend(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      colorBlend === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0
                      ? "Solid"
                      : val === 0.3
                        ? "Subtle"
                        : val === 0.6
                          ? "Medium"
                          : "Full"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Inset: {inset.toFixed(0)}px</Text>
            <View style={styles.buttonRow}>
              {[0, 10, 15, 25].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, inset === val && styles.activeButton]}
                  onPress={() => setInset(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      inset === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0 ? "None" : val + "px"}
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
  container: { flex: 1, backgroundColor: "#0a0a0a" },
  header: {
    padding: 20,
    paddingTop: 10,
    borderBottomWidth: 1,
    borderBottomColor: "#1a1a2e",
  },
  backButton: { marginBottom: 10 },
  backText: { color: "#ffffff", fontSize: 16, fontWeight: "600" },
  content: { flex: 1 },
  scrollContent: { paddingBottom: 40 },
  preview: {
    width: "100%",
    height: 250,
    marginBottom: 20,
    position: "relative",
  },
  shaderContent: { flex: 1, justifyContent: "center", alignItems: "center" },
  overlay: {
    padding: 30,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    alignItems: "center",
    zIndex: 1,
  },
  overlayShader: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 2,
  },
  contentTitle: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#fff",
    marginBottom: 4,
  },
  contentSubtitle: { fontSize: 14, color: "#aaa" },
  buttonDemoSection: { padding: 20, paddingTop: 0 },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#ffffff",
    marginBottom: 16,
  },
  buttonDemoRow: { flexDirection: "row", gap: 16 },
  demoButtonContainer: { flex: 1, height: 50, position: "relative" },
  demoButton: {
    flex: 1,
    backgroundColor: "rgba(10, 10, 15, 0.9)",
    justifyContent: "center",
    alignItems: "center",
    borderRadius: 8,
  },
  demoButtonText: { color: "#ffffff", fontSize: 16, fontWeight: "600" },
  buttonOverlay: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 2,
    borderRadius: 8,
  },
  controls: { padding: 20 },
  controlGroup: { marginBottom: 20 },
  controlLabel: {
    fontSize: 16,
    fontWeight: "600",
    color: "#ffffff",
    marginBottom: 8,
  },
  buttonRow: { flexDirection: "row", gap: 10 },
  button: {
    flex: 1,
    backgroundColor: "#000000",
    paddingVertical: 12,
    borderRadius: 10,
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#ffffff",
  },
  activeButton: { backgroundColor: "#ffffff" },
  buttonText: { color: "#ffffff", fontSize: 14, fontWeight: "600" },
  activeButtonText: { color: "#000000" },
});
