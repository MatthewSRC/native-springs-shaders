import React, { useState, useRef, useCallback, useEffect } from 'react';
import { StyleSheet, Text, View, Pressable, ScrollView, Image } from 'react-native';
import { RippleShader } from '@native-springs/shaders';

interface RippleScreenProps {
  onBack: () => void;
}

export const RippleScreen: React.FC<RippleScreenProps> = ({ onBack }) => {
  const [touchPoint, setTouchPoint] = useState<[number, number]>([0.5, 0.5]);
  const [touchTime, setTouchTime] = useState(0);
  const [intensity, setIntensity] = useState(1.0);
  const [frequency, setFrequency] = useState(1.2);
  const [color, setColor] = useState<[number, number, number]>([1, 1, 1]);
  const [rippleVariant, setRippleVariant] = useState<'standard' | 'realistic'>('realistic');
  const [speed, setSpeed] = useState(300);
  const [displacementStrength, setDisplacementStrength] = useState(0.05);
  const [highlightStrength, setHighlightStrength] = useState(0.1);

  const viewRef = useRef<View>(null);
  const animationRef = useRef<number>(null);
  const startTimeRef = useRef(0);

  const stopAnimation = useCallback(() => {
    if (animationRef.current) {
      cancelAnimationFrame(animationRef.current);
      animationRef.current = null;
    }
  }, []);

  const startAnimation = useCallback(() => {
    stopAnimation();
    startTimeRef.current = Date.now();

    const animate = () => {
      const elapsed = (Date.now() - startTimeRef.current) / 1000;
      setTouchTime(elapsed);

      if (elapsed < 2.0) {
        animationRef.current = requestAnimationFrame(animate);
      }
    };

    animationRef.current = requestAnimationFrame(animate);
  }, [stopAnimation]);

  useEffect(() => {
    return () => stopAnimation();
  }, [stopAnimation]);

  const handleTouch = useCallback((event: any) => {
    viewRef.current?.measure((_x, _y, width, height, pageX, pageY) => {
      const touchX = event.nativeEvent.pageX - pageX;
      const touchY = event.nativeEvent.pageY - pageY;
      const normalizedX = touchX / width;
      const normalizedY = touchY / height;
      setTouchPoint([normalizedX, normalizedY]);
      startAnimation();
    });
  }, [startAnimation]);

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Pressable onPress={onBack} style={styles.backButton}>
          <Text style={styles.backText}>← Back</Text>
        </Pressable>
      </View>

      <ScrollView style={styles.content} contentContainerStyle={styles.scrollContent}>
        <Pressable onPress={handleTouch}>
          <View ref={viewRef} style={styles.preview}>
            <RippleShader
              parameters={{
                intensity,
                touchPoint: touchPoint,
                touchTime,
                frequency,
                damping: 0.8,
                color: color,
                rippleVariant: rippleVariant,
                speed,
                ringWidth: 40,
                slowdownFactor: 0.5,
                displacementStrength,
                highlightStrength,
              }}
              style={styles.shader}
              initialSnapshotDelay={500}
            >
              <View style={styles.shaderContent}>
                <Image
                  source={{ uri: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800' }}
                  style={styles.backgroundImage}
                  resizeMode="cover"
                />
                <View style={styles.overlay}>
                  <Text style={styles.contentTitle}>Ripple Screen</Text>
                </View>
              </View>
            </RippleShader>
          </View>
        </Pressable>

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
            <Text style={styles.controlLabel}>Frequency: {frequency.toFixed(1)}</Text>
            <View style={styles.buttonRow}>
              {[0.8, 1.2, 2.0].map((val) => (
                <Pressable key={val} style={[styles.button, frequency === val && styles.activeButton]} onPress={() => setFrequency(val)}>
                  <Text style={[styles.buttonText, frequency === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Color</Text>
            <View style={styles.buttonRow}>
              <Pressable style={styles.button} onPress={() => setColor([1, 1, 1])}>
                <Text style={styles.buttonText}>White</Text>
              </Pressable>
              <Pressable style={styles.button} onPress={() => setColor([0.3, 0.7, 1])}>
                <Text style={styles.buttonText}>Blue</Text>
              </Pressable>
              <Pressable style={styles.button} onPress={() => setColor([1, 0.3, 0.5])}>
                <Text style={styles.buttonText}>Pink</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Variant</Text>
            <View style={styles.buttonRow}>
              <Pressable
                style={[styles.button, rippleVariant === 'standard' && styles.activeButton]}
                onPress={() => { setRippleVariant('standard'); setSpeed(2.0); }}
              >
                <Text style={[styles.buttonText, rippleVariant === 'standard' && styles.activeButtonText]}>Standard</Text>
              </Pressable>
              <Pressable
                style={[styles.button, rippleVariant === 'realistic' && styles.activeButton]}
                onPress={() => { setRippleVariant('realistic'); setSpeed(300); }}
              >
                <Text style={[styles.buttonText, rippleVariant === 'realistic' && styles.activeButtonText]}>Realistic</Text>
              </Pressable>
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Speed: {speed}</Text>
            <View style={styles.buttonRow}>
              {rippleVariant === 'realistic'
                ? [150, 300, 500].map((val) => (
                  <Pressable key={val} style={[styles.button, speed === val && styles.activeButton]} onPress={() => setSpeed(val)}>
                    <Text style={[styles.buttonText, speed === val && styles.activeButtonText]}>{val}</Text>
                  </Pressable>
                ))
                : [1.0, 2.0, 3.0].map((val) => (
                  <Pressable key={val} style={[styles.button, speed === val && styles.activeButton]} onPress={() => setSpeed(val)}>
                    <Text style={[styles.buttonText, speed === val && styles.activeButtonText]}>{val}</Text>
                  </Pressable>
                ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Displacement Strength: {displacementStrength.toFixed(2)}</Text>
            <View style={styles.buttonRow}>
              {[0.02, 0.05, 0.1].map((val) => (
                <Pressable key={val} style={[styles.button, displacementStrength === val && styles.activeButton]} onPress={() => setDisplacementStrength(val)}>
                  <Text style={[styles.buttonText, displacementStrength === val && styles.activeButtonText]}>{val}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View style={styles.controlGroup}>
            <Text style={styles.controlLabel}>Highlight Strength: {highlightStrength.toFixed(2)}</Text>
            <View style={styles.buttonRow}>
              {[0.05, 0.1, 0.3].map((val) => (
                <Pressable key={val} style={[styles.button, highlightStrength === val && styles.activeButton]} onPress={() => setHighlightStrength(val)}>
                  <Text style={[styles.buttonText, highlightStrength === val && styles.activeButtonText]}>{val}</Text>
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
  preview: { width: '100%', height: 350, marginBottom: 20 },
  shader: { flex: 1 },
  shaderContent: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  backgroundImage: { position: 'absolute', width: '100%', height: '100%' },
  overlay: { padding: 30, backgroundColor: 'rgba(0, 0, 0, 0.3)', alignItems: 'center' },
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
