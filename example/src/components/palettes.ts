import type { ConversationMode } from '@native-springs/shaders';

export interface Palette {
  primary: string;
  secondary: string;
}

export type ModePalette = Record<ConversationMode, Palette>;

/** Used while offline, in place of any mode color */
export const OFFLINE_COLOR = '#8a8f9c';

export const ORB_PALETTE: ModePalette = {
  default: { primary: '#FFCC66', secondary: '#BFCC66' },
  focused: { primary: '#FF9966', secondary: '#CC6699' },
  balanced: { primary: '#66CCFF', secondary: '#99AAFF' },
  prismatic: { primary: '#CC99FF', secondary: '#66E0FF' },
};

export const BLOB_PALETTE: ModePalette = {
  default: { primary: '#6699FF', secondary: '#E666CC' },
  focused: { primary: '#FF8855', secondary: '#FFCC66' },
  balanced: { primary: '#55CCFF', secondary: '#88FFDD' },
  prismatic: { primary: '#BB88FF', secondary: '#55E0FF' },
};

/** One color pair for every mode, to try out color cross-fades */
export const COLOR_PRESETS: { name: string; palette: Palette }[] = [
  { name: 'Sunset', palette: { primary: '#FF7A59', secondary: '#FFC857' } },
  { name: 'Ocean', palette: { primary: '#3DA5FF', secondary: '#4DFFD2' } },
  { name: 'Aurora', palette: { primary: '#63FF9A', secondary: '#7A6BFF' } },
  { name: 'Rose', palette: { primary: '#FF6FB5', secondary: '#FFB3D9' } },
  { name: 'Mono', palette: { primary: '#E8EAF0', secondary: '#9AA0B4' } },
];
