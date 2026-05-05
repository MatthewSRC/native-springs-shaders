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
    rose: { primary: "#F7E6FF", secondary: "#FFF2DB", tertiary: "#EBF6FF" },
  };

  const currentColors = colorPresets[colorPreset];

  return (
    <View style={styles.container}>
      <CloudsOverlay
        unique={true}
        parameters={{
          intensity: 0.6,
          color: "#CC4400",
          secondaryColor: "#993366",
          tertiaryColor: "#CC6600",
          scale: 1,
          speed: 0.3,
          softness: 0.6,
          blobCount: 3,
        }}
        style={styles.overlayShader}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: "#ffffff" },
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
