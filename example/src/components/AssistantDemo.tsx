import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  Animated,
  Keyboard,
  KeyboardAvoidingView,
  LayoutAnimation,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import type {
  ConversationMode,
  ConversationState,
  ConversationalOverlayRef,
} from '@native-springs/shaders';
import { ModePalette, OFFLINE_COLOR } from './palettes';
import { Chip, ConversationalOverlayComponent, OverlayParameters } from './ui';
import { useScreenExit } from './useScreenExit';

interface AssistantDemoProps {
  Overlay: ConversationalOverlayComponent;
  /** Colors per mode - the app owns colors, the overlay cross-fades them */
  palette: ModePalette;
  overlayParameters?: OverlayParameters;
  /** Called by Android back and by swiping in from the left edge */
  onBack: () => void;
}

interface Topic {
  label: string;
  mode: ConversationMode;
  prompt: string;
}

// The app decides what each visual mode means. Here they map to topics.
const TOPICS: Topic[] = [
  { label: 'Plan my day', mode: 'focused', prompt: 'Help me plan my day.' },
  { label: 'Weigh a decision', mode: 'balanced', prompt: 'Help me weigh a decision.' },
  { label: 'What if…', mode: 'prismatic', prompt: 'What if I tried something completely different?' },
  { label: 'Just talk', mode: 'default', prompt: 'Can we just talk for a bit?' },
];

const REPLIES: Record<ConversationMode, string[]> = {
  default: [
    'I’m here. What’s on your mind?',
    'That makes sense. Want to dig into it a little?',
    'Tell me more, I’m listening.',
  ],
  focused: [
    'Let’s keep it tight. Start with the one thing that makes everything else easier.',
    'Pick the first step you can finish in ten minutes, and begin there.',
  ],
  balanced: [
    'There are two real sides here. Let’s put them next to each other and see which one you keep coming back to.',
    'Both options are good. The question is which one you’d regret not trying.',
  ],
  prismatic: [
    'Here’s one way it could play out, and one you probably haven’t considered yet.',
    'Imagine it worked. What’s the first thing that would look different?',
  ],
};

const VOICE: Record<ConversationMode, string[]> = {
  default: ['Can we just talk for a bit?', 'I had a strange day.', 'Tell me something interesting.'],
  focused: ['What should I do first?', 'How do I stay on track?'],
  balanced: ['Which option feels right?', 'What am I missing?'],
  prismatic: ['What if it all worked out?', 'What would change if I started over?'],
};

/** The overlay is at most this much taller than wide, so its glow never clips at the sides */
const MAX_ASPECT = 1.25;

/** Tracks the on-screen keyboard, animating layout changes on iOS. */
function useKeyboardVisible() {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const ios = Platform.OS === 'ios';
    const change = (next: boolean) => () => {
      if (ios) LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
      setVisible(next);
    };
    const show = Keyboard.addListener(ios ? 'keyboardWillShow' : 'keyboardDidShow', change(true));
    const hide = Keyboard.addListener(ios ? 'keyboardWillHide' : 'keyboardDidHide', change(false));
    return () => {
      show.remove();
      hide.remove();
    };
  }, []);

  return visible;
}

const MicIcon: React.FC<{ color: string }> = ({ color }) => (
  <View style={{ alignItems: 'center' }}>
    <View style={{ width: 10, height: 16, borderRadius: 5, backgroundColor: color }} />
    <View
      style={{
        width: 18,
        height: 9,
        marginTop: -3,
        borderWidth: 2,
        borderTopWidth: 0,
        borderBottomLeftRadius: 9,
        borderBottomRightRadius: 9,
        borderColor: color,
      }}
    />
    <View style={{ width: 2, height: 4, backgroundColor: color }} />
  </View>
);

const MicButton: React.FC<{
  listening: boolean;
  accent: string;
  disabled: boolean;
  onPress: () => void;
}> = ({ listening, accent, disabled, onPress }) => {
  const pulse = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (!listening) {
      pulse.setValue(0);
      return;
    }
    const loop = Animated.loop(
      Animated.timing(pulse, { toValue: 1, duration: 1200, useNativeDriver: true }),
    );
    loop.start();
    return () => loop.stop();
  }, [listening, pulse]);

  return (
    <Pressable onPress={onPress} disabled={disabled} style={styles.micWrap}>
      {listening && (
        <Animated.View
          pointerEvents="none"
          style={[
            styles.micRing,
            {
              borderColor: accent,
              opacity: pulse.interpolate({ inputRange: [0, 1], outputRange: [0.5, 0] }),
              transform: [{ scale: pulse.interpolate({ inputRange: [0, 1], outputRange: [1, 1.7] }) }],
            },
          ]}
        />
      )}
      <View
        style={[
          styles.mic,
          { backgroundColor: listening ? accent : 'rgba(255, 255, 255, 0.12)', opacity: disabled ? 0.4 : 1 },
        ]}
      >
        {listening ? <View style={styles.stopIcon} /> : <MicIcon color="#ffffff" />}
      </View>
    </Pressable>
  );
};

export const AssistantDemo: React.FC<AssistantDemoProps> = ({
  Overlay,
  palette,
  overlayParameters,
  onBack,
}) => {
  const insets = useSafeAreaInsets();
  const keyboardVisible = useKeyboardVisible();

  const overlayRef = useRef<ConversationalOverlayRef>(null);
  const timers = useRef<ReturnType<typeof setTimeout>[]>([]);
  const exchangesRef = useRef(0);
  // True while the mic (not the keyboard) is driving the listening state
  const voiceRef = useRef(false);

  const [state, setState] = useState<ConversationState>('idle');
  const [mode, setMode] = useState<ConversationMode>('default');
  const [draft, setDraft] = useState('');
  // The one line shown under the overlay: the current question, then the reply
  const [text, setText] = useState('');
  const [textFrom, setTextFrom] = useState<'you' | 'assistant'>('assistant');
  const [exchanges, setExchanges] = useState(0);
  const [offline, setOffline] = useState(false);
  const [reconnecting, setReconnecting] = useState(false);
  const [hero, setHero] = useState({ width: 0, height: 0 });

  // The assistant gets to know you: confidence grows with every exchange
  const confidence = Math.min(1, 0.4 + exchanges * 0.15);
  const accent = offline ? OFFLINE_COLOR : palette[mode].primary;

  const parameters = useMemo(
    () => ({
      ...overlayParameters,
      color: palette[mode].primary,
      secondaryColor: palette[mode].secondary,
    }),
    [overlayParameters, palette, mode],
  );

  // There is no back button: Android back and a swipe in from the left edge leave the screen
  const exitHandlers = useScreenExit(onBack);

  const later = (fn: () => void, ms: number) => {
    timers.current.push(setTimeout(fn, ms));
  };

  const cancelAll = () => {
    timers.current.forEach(clearTimeout);
    timers.current = [];
  };

  useEffect(() => cancelAll, []);

  /** Shows a question, then thinks and speaks a reply in the given mode. */
  const send = (question: string, replyMode: ConversationMode) => {
    cancelAll();
    voiceRef.current = false;
    setText(question);
    setTextFrom('you');
    setState('thinking');

    later(() => {
      const options = REPLIES[replyMode];
      const reply = options[exchangesRef.current % options.length];
      const words = reply.split(' ');
      // The key line of a non-default reply lands with a flash
      const flashAt = replyMode === 'default' ? -1 : Math.ceil(words.length * 0.7);

      setState('speaking');
      setTextFrom('assistant');
      let shown = 0;
      const tick = () => {
        shown += 1;
        setText(words.slice(0, shown).join(' '));
        if (shown === flashAt) overlayRef.current?.trigger('flash');

        if (shown < words.length) {
          later(tick, 260);
          return;
        }
        // The finished reply stays on screen until the next question
        later(() => {
          setState('idle');
          exchangesRef.current += 1;
          setExchanges(exchangesRef.current);
        }, 700);
      };
      tick();
    }, 1500);
  };

  const submit = () => {
    const question = draft.trim();
    if (!question || offline) return;
    setDraft('');
    send(question, mode);
  };

  const onChangeText = (value: string) => {
    setDraft(value);
    if (voiceRef.current) return;
    // Typing counts as listening
    if (value && state === 'idle') setState('listening');
    else if (!value && state === 'listening') setState('idle');
  };

  const toggleVoice = () => {
    if (offline) return;

    // Tapping again while listening cancels
    if (state === 'listening' && voiceRef.current) {
      cancelAll();
      voiceRef.current = false;
      setText('');
      setState('idle');
      return;
    }

    cancelAll();
    voiceRef.current = true;
    setDraft('');
    Keyboard.dismiss();
    setState('listening');
    setTextFrom('you');
    setText('');

    const options = VOICE[mode];
    const phrase = options[exchangesRef.current % options.length];
    const words = phrase.split(' ');
    let shown = 0;
    const tick = () => {
      shown += 1;
      setText(words.slice(0, shown).join(' '));
      if (shown < words.length) later(tick, 320);
      else later(() => send(phrase, mode), 700);
    };
    later(tick, 500);
  };

  const pickTopic = (topic: Topic) => {
    if (offline) return;
    // Changing mode is just the overlay morphing, with no extra moment on top
    setMode(topic.mode);
    setDraft('');
    send(topic.prompt, topic.mode);
  };

  const endMode = () => {
    setMode('default');
    overlayRef.current?.trigger('exhale');
  };

  const toggleOffline = () => {
    cancelAll();
    voiceRef.current = false;
    setDraft('');
    setTextFrom('assistant');

    if (!offline) {
      setOffline(true);
      setState('error');
      setText('You’re offline.');
      return;
    }
    setReconnecting(true);
    setText('Reconnecting…');
    later(() => {
      setReconnecting(false);
      setOffline(false);
      setState('idle');
      setText('Back online.');
    }, 1400);
  };

  const hasDraft = draft.trim().length > 0;
  const listeningByVoice = state === 'listening' && voiceRef.current;

  // The overlay is the hero: as big as the space allows, centered below the status bar
  const availableHeight = Math.max(hero.height - insets.top, 0);
  const overlayHeight = Math.min(availableHeight, hero.width * MAX_ASPECT);
  const overlayTop = insets.top + (availableHeight - overlayHeight) / 2;

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      {...exitHandlers}
    >
      <View style={styles.hero} onLayout={(e) => setHero(e.nativeEvent.layout)}>
        {hero.width > 0 && (
          <Overlay
            ref={overlayRef}
            state={state}
            mode={mode}
            confidence={confidence}
            parameters={parameters}
            style={{
              position: 'absolute',
              left: 0,
              top: overlayTop,
              width: hero.width,
              height: overlayHeight,
            }}
          />
        )}
      </View>

      <View style={styles.caption}>
        <Text
          numberOfLines={4}
          style={[styles.captionText, textFrom === 'you' ? styles.captionYou : styles.captionAssistant]}
        >
          {text}
        </Text>
      </View>

      <ScrollView
        horizontal
        style={styles.chips}
        contentContainerStyle={styles.chipsContent}
        showsHorizontalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        {offline ? (
          <Chip
            label={reconnecting ? 'Reconnecting…' : 'Reconnect'}
            accent={accent}
            onPress={reconnecting ? () => {} : toggleOffline}
          />
        ) : (
          <>
            {mode !== 'default' && <Chip label="Done" active accent={accent} onPress={endMode} />}
            {TOPICS.map((topic) => (
              <Chip
                key={topic.label}
                label={topic.label}
                accent={accent}
                onPress={() => pickTopic(topic)}
              />
            ))}
            <Chip label="Go offline" accent={accent} onPress={toggleOffline} />
          </>
        )}
      </ScrollView>

      <View
        style={[
          styles.composer,
          { paddingBottom: keyboardVisible ? 10 : Math.max(insets.bottom, 12) },
        ]}
      >
        <TextInput
          style={styles.input}
          value={draft}
          onChangeText={onChangeText}
          onSubmitEditing={submit}
          blurOnSubmit={false}
          returnKeyType="send"
          editable={!offline}
          placeholder={offline ? 'You’re offline' : 'Message'}
          placeholderTextColor="rgba(255, 255, 255, 0.35)"
          selectionColor={accent}
          keyboardAppearance="dark"
        />
        {hasDraft ? (
          <Pressable onPress={submit} style={[styles.send, { backgroundColor: accent }]}>
            <Text style={styles.sendText}>↑</Text>
          </Pressable>
        ) : (
          <MicButton
            listening={listeningByVoice}
            accent={accent}
            disabled={offline}
            onPress={toggleVoice}
          />
        )}
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000000' },

  hero: { flex: 1 },

  caption: {
    minHeight: 108,
    paddingHorizontal: 28,
    paddingBottom: 8,
    justifyContent: 'flex-end',
  },
  captionText: { fontSize: 22, lineHeight: 30, fontWeight: '600', textAlign: 'center' },
  captionAssistant: { color: '#ffffff' },
  captionYou: { color: 'rgba(255, 255, 255, 0.55)' },

  chips: { flexGrow: 0 },
  chipsContent: { paddingHorizontal: 16, paddingVertical: 8, gap: 8 },

  composer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingHorizontal: 16,
    paddingTop: 8,
  },
  input: {
    flex: 1,
    height: 48,
    paddingHorizontal: 18,
    borderRadius: 24,
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
    color: '#ffffff',
    fontSize: 16,
  },
  send: { width: 48, height: 48, borderRadius: 24, alignItems: 'center', justifyContent: 'center' },
  sendText: { color: '#000000', fontSize: 22, fontWeight: '800', marginTop: -2 },

  micWrap: { width: 48, height: 48, alignItems: 'center', justifyContent: 'center' },
  micRing: {
    position: 'absolute',
    width: 48,
    height: 48,
    borderRadius: 24,
    borderWidth: 2,
  },
  mic: { width: 48, height: 48, borderRadius: 24, alignItems: 'center', justifyContent: 'center' },
  stopIcon: { width: 14, height: 14, borderRadius: 3, backgroundColor: '#000000' },
});
