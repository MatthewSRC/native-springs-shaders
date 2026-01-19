/**
 * RGB color tuple [0-1, 0-1, 0-1] or [0-255, 0-255, 0-255]
 */
export type RGB = [number, number, number];

/**
 * Flexible color input
 */
export type ColorValue = RGB | string;


function isRGB255(color: [number, number, number]): boolean {
  return color.some((v) => v > 1);
}

/**
 * Converts a hex color string to normalized RGB [0-1]
 * Supports formats: "#RGB", "#RRGGBB", "RGB", "RRGGBB"
 *
 */
export function hex(hexColor: string): RGB {
  let h = hexColor.replace('#', '');

  if (h.length === 3) {
    h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
  }

  if (h.length !== 6) {
    console.warn(`Invalid hex color: ${hexColor}, returning white`);
    return [1, 1, 1];
  }

  return [
    parseInt(h.slice(0, 2), 16) / 255,
    parseInt(h.slice(2, 4), 16) / 255,
    parseInt(h.slice(4, 6), 16) / 255,
  ];
}

/**
 * Creates a normalized RGB color from 0-255 values
 */
export function rgb(r: number, g: number, b: number): RGB {
  return [r / 255, g / 255, b / 255];
}

/**
 * Normalizes any supported color format to [0-1] RGB
 */
export function normalizeColor(color: ColorValue): RGB {
  if (typeof color === 'string') {
    return hex(color);
  }

  if (isRGB255(color)) {
    return [color[0] / 255, color[1] / 255, color[2] / 255];
  }

  return color;
}
