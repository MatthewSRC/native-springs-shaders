import React from 'react';
import { StyleSheet, Text, View, ScrollView, Pressable } from 'react-native';

interface HomeScreenProps {
  onNavigate: (screen: any) => void;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({ onNavigate }) => {
  const shaders = [
    { id: 'ripple', title: 'Ripple Shader', description: 'Touch-reactive water ripples' },
    { id: 'glitch', title: 'Glitch Shader', description: 'Digital glitch effects' },
    { id: 'liquidDistortion', title: 'Liquid Distortion', description: 'Animated liquid warping' },
  ];

  const overlays = [
    { id: 'fireSparks', title: 'Fire Sparks Overlay', description: 'Fire and spark particles' },
    { id: 'aurora', title: 'Aurora Overlay', description: 'Northern lights effect' },
    { id: 'fireworks', title: 'Fireworks Overlay', description: 'Explosive particle celebrations' },
    { id: 'lightRay', title: 'Light Ray Overlay', description: 'Volumetric light beams' },
    { id: 'sparkles', title: 'Sparkles Overlay', description: 'Magical twinkling stars' },
  ];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <View style={styles.header}>
        <Text style={styles.title}>Native Springs</Text>
        <Text style={styles.subtitle}>Shader Effects Demo</Text>
        <Text style={styles.description}>
          Explore visual effects for React Native
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Shaders</Text>
        <Text style={styles.sectionDescription}>
          Effects that transform your content
        </Text>
        {shaders.map((shader) => (
          <Pressable
            key={shader.id}
            style={styles.card}
            onPress={() => onNavigate(shader.id)}
          >
            <View style={styles.cardHeader}>
              <Text style={styles.cardTitle}>{shader.title}</Text>
              <Text style={styles.arrow}>→</Text>
            </View>
            <Text style={styles.cardDescription}>{shader.description}</Text>
          </Pressable>
        ))}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Overlays</Text>
        <Text style={styles.sectionDescription}>
          Effects that render on top of content
        </Text>
        {overlays.map((overlay) => (
          <Pressable
            key={overlay.id}
            style={styles.card}
            onPress={() => onNavigate(overlay.id)}
          >
            <View style={styles.cardHeader}>
              <Text style={styles.cardTitle}>{overlay.title}</Text>
              <Text style={styles.arrow}>→</Text>
            </View>
            <Text style={styles.cardDescription}>{overlay.description}</Text>
          </Pressable>
        ))}
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0a0a0a',
  },
  contentContainer: {
    padding: 20,
    paddingBottom: 40,
  },
  header: {
    marginBottom: 40,
    alignItems: 'center',
  },
  title: {
    fontSize: 42,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 18,
    color: '#888',
    marginBottom: 12,
  },
  description: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    maxWidth: 300,
  },
  section: {
    marginBottom: 32,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 8,
  },
  sectionDescription: {
    fontSize: 14,
    color: '#666',
    marginBottom: 16,
  },
  card: {
    backgroundColor: '#000000',
    borderRadius: 16,
    padding: 20,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#ffffff',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#ffffff',
  },
  cardDescription: {
    fontSize: 14,
    color: '#888',
  },
  arrow: {
    fontSize: 24,
    color: '#ffffff',
    fontWeight: 'bold',
  },
});
