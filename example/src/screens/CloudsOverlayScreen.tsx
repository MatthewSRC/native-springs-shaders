import React, { useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View, useWindowDimensions } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { CloudsOverlay } from '@native-springs/shaders';
import { Chip, Group, Options, Swatch } from '../components/ui';

interface CloudsOverlayScreenProps {
  onBack: () => void;
  onOpenDemo: () => void;
}

// Three blob colors per set. Rose is pastel, for light backgrounds.
const COLOR_SETS = [
  { name: 'Midnight', colors: ['#26338C', '#402680', '#1A4D80'] },
  { name: 'Sunset', colors: ['#CC4400', '#993366', '#CC6600'] },
  { name: 'Ocean', colors: ['#0A4466', '#1A3366', '#0D5580'] },
  { name: 'Aurora', colors: ['#0D4D33', '#1A3366', '#336644'] },
  { name: 'Rose', colors: ['#F7E6FF', '#FFF2DB', '#EBF6FF'] },
];

// The overlay is made to sit on top of any background, so try a few
const BACKGROUNDS = [
  { name: 'Dark', color: '#000000', text: '#ffffff' },
  { name: 'Navy', color: '#0e1226', text: '#ffffff' },
  { name: 'Light', color: '#ffffff', text: '#14182b' },
];

const INTENSITIES = [0.3, 0.6, 1];
const SCALES = [0.6, 1, 1.6, 2.4];
const SPEEDS = [0, 0.3, 1, 2];
const SOFTNESSES = [0.2, 0.6, 1];
const BLOB_COUNTS = [1, 2, 3, 4, 5];

const ACCENT = '#8fa8ff';

const DEFAULTS = { colors: 0, background: 0, intensity: 0.6, scale: 1, speed: 0.3, softness: 0.6, blobCount: 3 };

export const CloudsOverlayScreen: React.FC<CloudsOverlayScreenProps> = ({ onBack, onOpenDemo }) => {
  const insets = useSafeAreaInsets();
  const { height } = useWindowDimensions();

  const [colors, setColors] = useState(DEFAULTS.colors);
  const [background, setBackground] = useState(DEFAULTS.background);
  const [intensity, setIntensity] = useState(DEFAULTS.intensity);
  const [scale, setScale] = useState(DEFAULTS.scale);
  const [speed, setSpeed] = useState(DEFAULTS.speed);
  const [softness, setSoftness] = useState(DEFAULTS.softness);
  const [blobCount, setBlobCount] = useState(DEFAULTS.blobCount);

  const [primary, secondary, tertiary] = COLOR_SETS[colors].colors;
  const parameters = useMemo(
    () => ({
      intensity,
      color: primary,
      secondaryColor: secondary,
      tertiaryColor: tertiary,
      scale,
      speed,
      softness,
      blobCount,
    }),
    [intensity, primary, secondary, tertiary, scale, speed, softness, blobCount],
  );

  const reset = () => {
    setColors(DEFAULTS.colors);
    setBackground(DEFAULTS.background);
    setIntensity(DEFAULTS.intensity);
    setScale(DEFAULTS.scale);
    setSpeed(DEFAULTS.speed);
    setSoftness(DEFAULTS.softness);
    setBlobCount(DEFAULTS.blobCount);
  };

  const { color: backgroundColor, text: textColor } = BACKGROUNDS[background];
  const previewHeight = Math.min(380, Math.round(height * 0.38));

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Pressable onPress={onBack} hitSlop={12} style={styles.headerSide}>
          <Text style={styles.backText}>‹ Back</Text>
        </Pressable>
        <Text style={styles.title}>Clouds</Text>
        <View style={[styles.headerSide, styles.headerRight]}>
          <Pressable onPress={onOpenDemo} style={styles.demoButton}>
            <Text style={styles.demoButtonText}>App demo ›</Text>
          </Pressable>
        </View>
      </View>

      <View style={[styles.preview, { height: previewHeight, backgroundColor }]}>
        <CloudsOverlay unique parameters={parameters} style={styles.overlay} />
        {/* Clouds are made to sit behind frosted glass, so show a card on top */}
        <View style={styles.cardWrap} pointerEvents="none">
          <View
            style={[
              styles.card,
              textColor === '#ffffff' ? styles.cardOnDark : styles.cardOnLight,
            ]}
          >
            <Text style={[styles.cardTitle, { color: textColor }]}>Frosted card</Text>
            <Text style={[styles.cardBody, { color: textColor }]}>
              Soft clouds drifting behind your content
            </Text>
          </View>
        </View>
      </View>

      <ScrollView
        style={styles.controls}
        contentContainerStyle={[styles.controlsContent, { paddingBottom: insets.bottom + 32 }]}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.sectionRow}>
          <Text style={styles.section}>Customize</Text>
          <Pressable onPress={reset} hitSlop={10}>
            <Text style={styles.reset}>Reset</Text>
          </Pressable>
        </View>

        <Group label="Colors">
          {COLOR_SETS.map((set, index) => (
            <Swatch
              key={set.name}
              name={set.name}
              colors={set.colors}
              accent={ACCENT}
              active={colors === index}
              onPress={() => setColors(index)}
            />
          ))}
        </Group>

        <Group label="Background">
          {BACKGROUNDS.map((item, index) => (
            <Chip
              key={item.name}
              grow
              label={item.name}
              accent={ACCENT}
              active={background === index}
              onPress={() => setBackground(index)}
            />
          ))}
        </Group>

        <Group label={`Intensity · ${intensity}`}>
          <Options values={INTENSITIES} value={intensity} accent={ACCENT} onChange={setIntensity} />
        </Group>

        <Group label={`Blobs · ${blobCount}`}>
          <Options values={BLOB_COUNTS} value={blobCount} accent={ACCENT} onChange={setBlobCount} />
        </Group>

        <Group label={`Scale · ${scale}`}>
          <Options values={SCALES} value={scale} accent={ACCENT} onChange={setScale} />
        </Group>

        <Group label={`Softness · ${softness}`}>
          <Options values={SOFTNESSES} value={softness} accent={ACCENT} onChange={setSoftness} />
        </Group>

        <Group label={`Speed · ${speed}`}>
          <Options values={SPEEDS} value={speed} accent={ACCENT} onChange={setSpeed} />
        </Group>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000000' },

  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  headerSide: { flex: 1 },
  headerRight: { alignItems: 'flex-end' },
  backText: { color: '#ffffff', fontSize: 16, fontWeight: '600' },
  title: { color: '#ffffff', fontSize: 17, fontWeight: '700' },
  demoButton: {
    paddingVertical: 6,
    paddingHorizontal: 14,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: ACCENT,
  },
  demoButtonText: { color: ACCENT, fontSize: 13, fontWeight: '700' },

  preview: {
    marginHorizontal: 16,
    borderRadius: 24,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
  },
  overlay: { ...StyleSheet.absoluteFillObject, zIndex: 0 },
  cardWrap: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1,
  },
  card: {
    paddingVertical: 18,
    paddingHorizontal: 24,
    borderRadius: 20,
    borderWidth: 1,
    alignItems: 'center',
  },
  cardOnDark: { backgroundColor: 'rgba(255, 255, 255, 0.1)', borderColor: 'rgba(255, 255, 255, 0.18)' },
  cardOnLight: { backgroundColor: 'rgba(255, 255, 255, 0.55)', borderColor: 'rgba(20, 24, 43, 0.08)' },
  cardTitle: { fontSize: 18, fontWeight: '700', marginBottom: 4 },
  cardBody: { fontSize: 13, opacity: 0.7 },

  controls: { flex: 1 },
  controlsContent: { paddingHorizontal: 20, paddingTop: 20 },
  section: { color: '#ffffff', fontSize: 18, fontWeight: '700', marginBottom: 14 },
  sectionRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    justifyContent: 'space-between',
  },
  reset: { color: ACCENT, fontSize: 14, fontWeight: '700' },
});
