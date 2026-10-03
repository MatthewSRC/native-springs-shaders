import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import type {
  ConversationalOverlayProps,
  ConversationalOverlayRef,
} from '@native-springs/shaders';

/** Any conversational overlay (Orb, Blob) */
export type ConversationalOverlayComponent = React.ForwardRefExoticComponent<
  ConversationalOverlayProps & React.RefAttributes<ConversationalOverlayRef>
>;

export type OverlayParameters = NonNullable<ConversationalOverlayProps['parameters']>;

export const Chip: React.FC<{
  label: string;
  active?: boolean;
  accent: string;
  onPress: () => void;
  grow?: boolean;
}> = ({ label, active = false, accent, onPress, grow }) => (
  <Pressable
    onPress={onPress}
    style={[
      styles.chip,
      grow && styles.chipGrow,
      active && { backgroundColor: accent, borderColor: accent },
    ]}
  >
    <Text style={[styles.chipText, active && styles.chipTextActive]}>{label}</Text>
  </Pressable>
);

export const Group: React.FC<{ label: string; children: React.ReactNode }> = ({
  label,
  children,
}) => (
  <View style={styles.group}>
    <Text style={styles.groupLabel}>{label}</Text>
    <View style={styles.row}>{children}</View>
  </View>
);

const same = (a: number, b: number) => Math.abs(a - b) < 0.001;

/** A row of numeric choices */
export const Options: React.FC<{
  values: number[];
  value: number;
  accent: string;
  onChange: (value: number) => void;
  format?: (value: number) => string;
}> = ({ values, value, accent, onChange, format = String }) => (
  <>
    {values.map((v) => (
      <Chip
        key={v}
        grow
        label={format(v)}
        accent={accent}
        active={same(v, value)}
        onPress={() => onChange(v)}
      />
    ))}
  </>
);

/** A named set of colors to pick from */
export const Swatch: React.FC<{
  name: string;
  colors: string[];
  active: boolean;
  /** Fill color while active */
  accent: string;
  onPress: () => void;
}> = ({ name, colors, active, accent, onPress }) => (
  <Pressable
    onPress={onPress}
    style={[styles.swatch, active && { backgroundColor: accent, borderColor: accent }]}
  >
    <View style={styles.swatchDots}>
      {colors.map((color, index) => (
        <View
          key={index}
          style={[styles.swatchDot, { backgroundColor: color }, index > 0 && { marginLeft: -4 }]}
        />
      ))}
    </View>
    <Text style={[styles.swatchText, active && styles.chipTextActive]}>{name}</Text>
  </Pressable>
);

const styles = StyleSheet.create({
  group: { marginBottom: 18 },
  groupLabel: {
    color: 'rgba(255, 255, 255, 0.45)',
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 1.2,
    textTransform: 'uppercase',
    marginBottom: 8,
  },
  row: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  chip: {
    paddingVertical: 9,
    paddingHorizontal: 14,
    borderRadius: 999,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  chipGrow: { flex: 1 },
  chipText: { color: '#ffffff', fontSize: 13, fontWeight: '600' },
  chipTextActive: { color: '#000000' },

  swatch: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingVertical: 9,
    paddingHorizontal: 12,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  swatchDots: { flexDirection: 'row' },
  swatchDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.25)',
  },
  swatchText: { color: '#ffffff', fontSize: 13, fontWeight: '600' },
});
