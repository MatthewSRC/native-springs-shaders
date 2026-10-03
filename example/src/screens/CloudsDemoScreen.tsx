import React, { useState } from 'react';
import { Pressable, ScrollView, StatusBar, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { CloudsOverlay } from '@native-springs/shaders';
import { useScreenExit } from '../components/useScreenExit';

interface CloudsDemoScreenProps {
  onBack: () => void;
}

const THEMES = {
  dark: {
    background: '#05060f',
    statusBar: 'light-content' as const,
    text: '#ffffff',
    muted: 'rgba(255, 255, 255, 0.6)',
    card: 'rgba(255, 255, 255, 0.08)',
    border: 'rgba(255, 255, 255, 0.16)',
    track: 'rgba(255, 255, 255, 0.16)',
    fill: '#ffffff',
    clouds: {
      intensity: 0.75,
      color: '#26338C',
      secondaryColor: '#402680',
      tertiaryColor: '#1A4D80',
      scale: 1.4,
      speed: 0.3,
      softness: 0.7,
      blobCount: 4,
    },
  },
  light: {
    background: '#ffffff',
    statusBar: 'dark-content' as const,
    text: '#14182b',
    muted: 'rgba(20, 24, 43, 0.55)',
    card: 'rgba(255, 255, 255, 0.6)',
    border: 'rgba(20, 24, 43, 0.08)',
    track: 'rgba(20, 24, 43, 0.1)',
    fill: '#14182b',
    clouds: {
      intensity: 1,
      color: '#E2CCFF',
      secondaryColor: '#FFE3B8',
      tertiaryColor: '#C6E4FF',
      scale: 1.4,
      speed: 0.3,
      softness: 0.7,
      blobCount: 4,
    },
  },
};

type ThemeName = keyof typeof THEMES;

const UP_NEXT = [
  { time: '18:30', title: 'Review notes' },
  { time: '21:00', title: 'Wind down' },
];

export const CloudsDemoScreen: React.FC<CloudsDemoScreenProps> = ({ onBack }) => {
  const insets = useSafeAreaInsets();
  const exitHandlers = useScreenExit(onBack);
  const [themeName, setThemeName] = useState<ThemeName>('dark');
  const theme = THEMES[themeName];

  // Frosted glass: a translucent fill with a hairline border over the clouds
  const glass = { backgroundColor: theme.card, borderColor: theme.border };

  return (
    <View style={[styles.container, { backgroundColor: theme.background }]} {...exitHandlers}>
      <StatusBar barStyle={theme.statusBar} />
      <CloudsOverlay unique parameters={theme.clouds} style={styles.overlay} />

      <ScrollView
        style={styles.scroll}
        contentContainerStyle={[
          styles.content,
          { paddingTop: insets.top + 20, paddingBottom: insets.bottom + 32 },
        ]}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <View>
            <Text style={[styles.eyebrow, { color: theme.muted }]}>TODAY</Text>
            <Text style={[styles.title, { color: theme.text }]}>Good evening</Text>
          </View>
          <View style={[styles.toggle, glass]}>
            {(Object.keys(THEMES) as ThemeName[]).map((name) => (
              <Pressable
                key={name}
                onPress={() => setThemeName(name)}
                style={[styles.toggleItem, themeName === name && { backgroundColor: theme.fill }]}
              >
                <Text
                  style={[
                    styles.toggleText,
                    { color: themeName === name ? theme.background : theme.muted },
                  ]}
                >
                  {name === 'dark' ? 'Dark' : 'Light'}
                </Text>
              </Pressable>
            ))}
          </View>
        </View>

        <View style={[styles.card, glass]}>
          <Text style={[styles.label, { color: theme.muted }]}>Focus</Text>
          <Text style={[styles.hero, { color: theme.text }]}>2h 15m</Text>
          <Text style={[styles.caption, { color: theme.muted }]}>of your 3h goal</Text>
          <View style={[styles.track, { backgroundColor: theme.track }]}>
            <View style={[styles.fill, { backgroundColor: theme.fill, width: '75%' }]} />
          </View>
        </View>

        <View style={styles.row}>
          <View style={[styles.card, styles.half, glass]}>
            <Text style={[styles.label, { color: theme.muted }]}>Steps</Text>
            <Text style={[styles.value, { color: theme.text }]}>8,240</Text>
            <Text style={[styles.caption, { color: theme.muted }]}>of 10,000</Text>
          </View>
          <View style={[styles.card, styles.half, glass]}>
            <Text style={[styles.label, { color: theme.muted }]}>Sleep</Text>
            <Text style={[styles.value, { color: theme.text }]}>7h 32m</Text>
            <Text style={[styles.caption, { color: theme.muted }]}>last night</Text>
          </View>
        </View>

        <View style={[styles.card, glass]}>
          <Text style={[styles.label, { color: theme.muted }]}>Up next</Text>
          {UP_NEXT.map((item, index) => (
            <View
              key={item.title}
              style={[
                styles.item,
                index > 0 && { borderTopWidth: StyleSheet.hairlineWidth, borderColor: theme.border },
              ]}
            >
              <Text style={[styles.itemTime, { color: theme.muted }]}>{item.time}</Text>
              <Text style={[styles.itemTitle, { color: theme.text }]}>{item.title}</Text>
            </View>
          ))}
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1 },
  overlay: { ...StyleSheet.absoluteFillObject, zIndex: 0 },
  scroll: { flex: 1, zIndex: 1 },
  content: { paddingHorizontal: 20, gap: 14 },

  header: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  eyebrow: { fontSize: 12, fontWeight: '700', letterSpacing: 1.6 },
  title: { fontSize: 32, fontWeight: '800', marginTop: 2 },
  toggle: {
    flexDirection: 'row',
    padding: 3,
    borderRadius: 999,
    borderWidth: 1,
  },
  toggleItem: { paddingVertical: 6, paddingHorizontal: 12, borderRadius: 999 },
  toggleText: { fontSize: 13, fontWeight: '700' },

  card: { padding: 18, borderRadius: 24, borderWidth: 1 },
  row: { flexDirection: 'row', gap: 14 },
  half: { flex: 1 },
  label: { fontSize: 13, fontWeight: '600', marginBottom: 6 },
  hero: { fontSize: 44, fontWeight: '800' },
  value: { fontSize: 28, fontWeight: '800' },
  caption: { fontSize: 13, marginTop: 2 },
  track: { height: 6, borderRadius: 3, marginTop: 14, overflow: 'hidden' },
  fill: { height: 6, borderRadius: 3 },

  item: { flexDirection: 'row', alignItems: 'center', gap: 14, paddingVertical: 12 },
  itemTime: { width: 48, fontSize: 14, fontWeight: '600' },
  itemTitle: { fontSize: 17, fontWeight: '600' },
});
