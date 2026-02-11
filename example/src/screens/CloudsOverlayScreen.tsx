import React, { useState } from "react";
import { StyleSheet, Text, View, ScrollView, Pressable } from "react-native";
import { CloudsOverlay } from "@native-springs/shaders";

interface CloudsOverlayScreenProps {
  onBack: () => void;
}

export const CloudsOverlayScreen: React.FC<CloudsOverlayScreenProps> = ({
  onBack,
}) => {
  const [intensity, setIntensity] = useState(0.6);
  const [colorPreset, setColorPreset] = useState<
    "midnight" | "sunset" | "ocean" | "aurora" | "rose"
  >("midnight");
  const [scale, setScale] = useState(1.0);
  const [speed, setSpeed] = useState(0.3);
  const [softness, setSoftness] = useState(0.6);
  const [blobCount, setBlobCount] = useState(3);

  const colorPresets: Record<
    string,
    { primary: string; secondary: string; tertiary: string }
  > = {
    midnight: { primary: "#26338C", secondary: "#402680", tertiary: "#1A4D80" },
    sunset: { primary: "#CC4400", secondary: "#993366", tertiary: "#CC6600" },
    ocean: { primary: "#0A4466", secondary: "#1A3366", tertiary: "#0D5580" },
    aurora: { primary: "#0D4D33", secondary: "#1A3366", tertiary: "#336644" },
    rose: { primary: "#802050", secondary: "#603060", tertiary: "#993355" },
  };

  const currentColors = colorPresets[colorPreset];

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
              <Text style={styles.contentTitle}>Soft Clouds</Text>
              <Text style={styles.contentSubtitle}>
                Ambient Background Blobs
              </Text>
            </View>
          </View>
          <CloudsOverlay
            parameters={{
              intensity,
              color: currentColors.primary,
              secondaryColor: currentColors.secondary,
              tertiaryColor: currentColors.tertiary,
              scale,
              speed,
              softness,
              blobCount,
            }}
            style={styles.overlayShader}
          />
        </View>

        <View style={styles.cardDemoSection}>
          <Text style={styles.sectionTitle}>Card Background Examples</Text>
          <View style={styles.cardDemoRow}>
            <View style={styles.demoCardContainer}>
              <View style={styles.demoCard}>
                <Text style={styles.demoCardTitle}>Welcome</Text>
                <Text style={styles.demoCardSubtitle}>Tap to get started</Text>
              </View>
              <CloudsOverlay
                parameters={{
                  intensity: 0.5,
                  color: currentColors.primary,
                  secondaryColor: currentColors.secondary,
                  tertiaryColor: currentColors.tertiary,
                  scale: 1.2,
                  speed: 0.2,
                  softness: 0.7,
                  blobCount: 3,
                }}
                style={styles.cardOverlay}
              />
            </View>
            <View style={styles.demoCardContainer}>
              <View style={styles.demoCard}>
                <Text style={styles.demoCardTitle}>Settings</Text>
                <Text style={styles.demoCardSubtitle}>Customize</Text>
              </View>
              <CloudsOverlay
                parameters={{
                  intensity: 0.4,
                  color: "#0A4466",
                  secondaryColor: "#1A3366",
                  tertiaryColor: "#0D5580",
                  scale: 1.5,
                  speed: 0.15,
                  softness: 0.8,
                  blobCount: 2,
                }}
                style={styles.cardOverlay}
              />
            </View>
          </View>
        </View>

        <View style={styles.controls}>
          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Color Preset</Text>
            <View style={styles.buttonRow}>
              {(["midnight", "sunset", "ocean", "aurora", "rose"] as const).map(
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
              {[0.3, 0.5, 0.6, 0.9].map((val) => (
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
            <Text style={styles.controlLabel}>Scale: {scale.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.5, 1.0, 1.5, 2.5].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, scale === val && styles.activeButton]}
                  onPress={() => setScale(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      scale === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0.5
                      ? "small"
                      : val === 1.0
                        ? "Medium"
                        : val === 1.5
                          ? "Large"
                          : "Huge"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Speed: {speed.toFixed(2)}x</Text>
            <View style={styles.buttonRow}>
              {[0.0, 0.15, 0.3, 0.8].map((val) => (
                <Pressable
                  key={val}
                  style={[styles.button, speed === val && styles.activeButton]}
                  onPress={() => setSpeed(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      speed === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0
                      ? "Still"
                      : val === 0.15
                        ? "Slow"
                        : val === 0.3
                          ? "Drift"
                          : "Fast"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>
              Softness: {softness.toFixed(1)}
            </Text>
            <View style={styles.buttonRow}>
              {[0.2, 0.4, 0.6, 0.9].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    softness === val && styles.activeButton,
                  ]}
                  onPress={() => setSoftness(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      softness === val && styles.activeButtonText,
                    ]}
                  >
                    {val === 0.2
                      ? "Defined"
                      : val === 0.4
                        ? "Soft"
                        : val === 0.6
                          ? "Blurry"
                          : "Diffuse"}
                  </Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Blobs: {blobCount}</Text>
            <View style={styles.buttonRow}>
              {[1, 2, 3, 5].map((val) => (
                <Pressable
                  key={val}
                  style={[
                    styles.button,
                    blobCount === val && styles.activeButton,
                  ]}
                  onPress={() => setBlobCount(val)}
                >
                  <Text
                    style={[
                      styles.buttonText,
                      blobCount === val && styles.activeButtonText,
                    ]}
                  >
                    {val}
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
    backgroundColor: "rgba(0, 0, 0, 0.3)",
    borderRadius: 16,
    alignItems: "center",
    zIndex: 1,
  },
  overlayShader: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 0,
  },
  contentTitle: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#fff",
    marginBottom: 4,
  },
  contentSubtitle: { fontSize: 14, color: "#ddd" },
  cardDemoSection: { padding: 20, paddingTop: 0 },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "600",
    color: "#ffffff",
    marginBottom: 16,
  },
  cardDemoRow: { flexDirection: "row", gap: 16 },
  demoCardContainer: {
    flex: 1,
    height: 120,
    position: "relative",
    borderRadius: 16,
    overflow: "hidden",
  },
  demoCard: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.2)",
    justifyContent: "center",
    alignItems: "center",
    borderRadius: 16,
    zIndex: 1,
  },
  demoCardTitle: {
    color: "#ffffff",
    fontSize: 18,
    fontWeight: "700",
    marginBottom: 4,
  },
  demoCardSubtitle: { color: "#eee", fontSize: 12 },
  cardOverlay: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 0,
    borderRadius: 16,
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
