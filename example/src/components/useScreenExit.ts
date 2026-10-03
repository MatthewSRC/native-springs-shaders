import { useEffect, useRef } from 'react';
import { BackHandler, PanResponder } from 'react-native';

/**
 * For screens without a back button: Android back and a swipe in from the
 * left edge both go back. Spread the result on the screen's root view.
 */
export function useScreenExit(onBack: () => void) {
  const onBackRef = useRef(onBack);
  useEffect(() => {
    onBackRef.current = onBack;
  }, [onBack]);

  useEffect(() => {
    const subscription = BackHandler.addEventListener('hardwareBackPress', () => {
      onBackRef.current();
      return true;
    });
    return () => subscription.remove();
  }, []);

  return useRef(
    PanResponder.create({
      onMoveShouldSetPanResponderCapture: (_, g) =>
        g.x0 < 28 && g.dx > 12 && Math.abs(g.dx) > Math.abs(g.dy) * 1.5,
      onPanResponderRelease: (_, g) => {
        if (g.dx > 70) onBackRef.current();
      },
    }),
  ).current.panHandlers;
}
