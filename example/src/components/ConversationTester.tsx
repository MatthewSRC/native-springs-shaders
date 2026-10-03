import React, { useMemo, useRef, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View, useWindowDimensions } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import type {
  ConversationMode,
  ConversationMoment,
  ConversationState,
  ConversationalOverlayRef,
} from '@native-springs/shaders';
import { COLOR_PRESETS, ModePalette, OFFLINE_COLOR } from './palettes';
import { Chip, ConversationalOverlayComponent, Group, Options, Swatch } from './ui';

interface ConversationTesterProps {
  title: string;
  Overlay: ConversationalOverlayComponent;
  /** Colors per mode - the app owns colors, the overlay cross-fades them */
  palette: ModePalette;
  /** The overlay's built-in render resolution, to reset to */
  defaultRenderScale: number;
  onBack: () => void;
  onOpenDemo: () => void;
}

const STATES: ConversationState[] = ['idle', 'listening', 'thinking', 'speaking', 'error'];
const MODES: ConversationMode[] = ['default', 'focused', 'balanced', 'prismatic'];
const MOMENTS: ConversationMoment[] = ['flash', 'exhale', 'ripple'];
const CONFIDENCES = [0.2, 0.6, 1];
const INTENSITIES = [0.5, 1, 1.5];
const SCALES = [0.7, 1, 1.4];
const SPEEDS = [0.5, 1, 2];
const RENDER_SCALES = [0.35, 0.5, 0.75, 1];
const TRANSITIONS = [0.3, 0.7, 1.5];

export const ConversationTester: React.FC<ConversationTesterProps> = ({
  title,
  Overlay,
  palette,
  defaultRenderScale,
  onBack,
  onOpenDemo,
}) => {
  const insets = useSafeAreaInsets();
  const { height } = useWindowDimensions();
  const overlayRef = useRef<ConversationalOverlayRef>(null);

  const [state, setState] = useState<ConversationState>('idle');
  const [mode, setMode] = useState<ConversationMode>('default');
  const [confidence, setConfidence] = useState(1);

  // Customization. A null color choice follows the per-mode palette.
  const [colorChoice, setColorChoice] = useState<number | null>(null);
  const [intensity, setIntensity] = useState(1);
  const [scale, setScale] = useState(1);
  const [speed, setSpeed] = useState(1);
  const [renderScale, setRenderScale] = useState(defaultRenderScale);
  const [transition, setTransition] = useState(0.7);

  const colors = colorChoice === null ? palette[mode] : COLOR_PRESETS[colorChoice].palette;
  const accent = state === 'error' ? OFFLINE_COLOR : colors.primary;

  const parameters = useMemo(
    () => ({
      color: colors.primary,
      secondaryColor: colors.secondary,
      intensity,
      scale,
      speed,
      renderScale,
      transitionDuration: transition,
    }),
    [colors.primary, colors.secondary, intensity, scale, speed, renderScale, transition],
  );

  const reset = () => {
    setColorChoice(null);
    setIntensity(1);
    setScale(1);
    setSpeed(1);
    setRenderScale(defaultRenderScale);
    setTransition(0.7);
  };

  const previewHeight = Math.min(380, Math.round(height * 0.38));

  return (
    <View style={[styles.container, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <Pressable onPress={onBack} hitSlop={12} style={styles.headerSide}>
          <Text style={styles.backText}>‹ Back</Text>
        </Pressable>
        <Text style={styles.title}>{title}</Text>
        <View style={[styles.headerSide, styles.headerRight]}>
          <Pressable onPress={onOpenDemo} style={[styles.demoButton, { borderColor: accent }]}>
            <Text style={[styles.demoButtonText, { color: accent }]}>App demo ›</Text>
          </Pressable>
        </View>
      </View>

      <View style={[styles.preview, { height: previewHeight }]}>
        <Overlay
          ref={overlayRef}
          state={state}
          mode={mode}
          confidence={confidence}
          parameters={parameters}
          style={styles.overlay}
        />
        <View style={styles.previewTag} pointerEvents="none">
          <View style={[styles.previewDot, { backgroundColor: accent }]} />
          <Text style={styles.previewTagText}>
            {state} · {mode}
          </Text>
        </View>
      </View>

      <ScrollView
        style={styles.controls}
        contentContainerStyle={[styles.controlsContent, { paddingBottom: insets.bottom + 32 }]}
        showsVerticalScrollIndicator={false}
      >
        <Text style={styles.section}>Test</Text>

        <Group label="State">
          {STATES.map((value) => (
            <Chip
              key={value}
              label={value}
              accent={accent}
              active={state === value}
              onPress={() => setState(value)}
            />
          ))}
        </Group>

        <Group label="Mode">
          {MODES.map((value) => (
            <Chip
              key={value}
              label={value}
              accent={accent}
              active={mode === value}
              onPress={() => setMode(value)}
            />
          ))}
        </Group>

        <Group label="Moments">
          {MOMENTS.map((moment) => (
            <Chip
              key={moment}
              grow
              label={moment}
              accent={accent}
              onPress={() => overlayRef.current?.trigger(moment)}
            />
          ))}
        </Group>

        <Group label={`Confidence · ${confidence}`}>
          <Options values={CONFIDENCES} value={confidence} accent={accent} onChange={setConfidence} />
        </Group>

        <View style={styles.sectionRow}>
          <Text style={styles.section}>Customize</Text>
          <Pressable onPress={reset} hitSlop={10}>
            <Text style={[styles.reset, { color: accent }]}>Reset</Text>
          </Pressable>
        </View>

        <Group label="Colors">
          <Chip
            label="Per mode"
            accent={accent}
            active={colorChoice === null}
            onPress={() => setColorChoice(null)}
          />
          {COLOR_PRESETS.map((preset, index) => (
            <Swatch
              key={preset.name}
              name={preset.name}
              colors={[preset.palette.primary, preset.palette.secondary]}
              accent={preset.palette.primary}
              active={colorChoice === index}
              onPress={() => setColorChoice(index)}
            />
          ))}
        </Group>

        <Group label={`Intensity · ${intensity}`}>
          <Options values={INTENSITIES} value={intensity} accent={accent} onChange={setIntensity} />
        </Group>

        <Group label={`Scale · ${scale}`}>
          <Options values={SCALES} value={scale} accent={accent} onChange={setScale} />
        </Group>

        <Group label={`Speed · ${speed}`}>
          <Options values={SPEEDS} value={speed} accent={accent} onChange={setSpeed} />
        </Group>

        <Group label={`Transition · ${transition}s`}>
          <Options
            values={TRANSITIONS}
            value={transition}
            accent={accent}
            onChange={setTransition}
            format={(v) => `${v}s`}
          />
        </Group>

        <Group label={`Render scale · ${renderScale}`}>
          <Options values={RENDER_SCALES} value={renderScale} accent={accent} onChange={setRenderScale} />
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
  },
  demoButtonText: { fontSize: 13, fontWeight: '700' },

  preview: {
    marginHorizontal: 16,
    borderRadius: 24,
    overflow: 'hidden',
    backgroundColor: '#000000',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
  },
  overlay: { ...StyleSheet.absoluteFillObject, zIndex: 0 },
  previewTag: {
    position: 'absolute',
    left: 14,
    bottom: 12,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    zIndex: 1,
  },
  previewDot: { width: 7, height: 7, borderRadius: 4 },
  previewTagText: {
    color: 'rgba(255, 255, 255, 0.6)',
    fontSize: 12,
    fontWeight: '600',
    textTransform: 'capitalize',
  },

  controls: { flex: 1 },
  controlsContent: { paddingHorizontal: 20, paddingTop: 20 },
  section: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 14,
  },
  sectionRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    justifyContent: 'space-between',
    marginTop: 8,
  },
  reset: { fontSize: 14, fontWeight: '700' },
});
