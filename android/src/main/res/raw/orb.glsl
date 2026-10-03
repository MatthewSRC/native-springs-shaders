#version 300 es

/**
 * Orb Overlay Shader Effect
 *
 * Creates a glowing energy orb with noise-lit filaments. The look is driven
 * by uniforms that the native side animates between conversational states.
 * The noise texture of the original is replaced by tileable value noise.
 *
 * Adapted from shader by SnoopethDuckDuck: https://www.shadertoy.com/view/mdd3D4
 *
 * License: Not specified by original author
 * Commercial use may require permission from original author.
 */

precision highp float;

in vec2 vTexCoord;

out vec4 fragColor;

uniform float time;
uniform float intensity;
uniform vec2 viewSize;
uniform vec3 color;
uniform vec3 secondaryColor;
uniform float scale;
uniform float radius;
uniform float thickness;
uniform float dispersion;
uniform float spread;
uniform float turbulence;
uniform float chromatic;
uniform float shimmer;
uniform float symmetry;
uniform float core;
uniform float brightness;
uniform float saturation;
uniform float rippleProgress;
uniform float rippleStrength;

const float PI = 3.14159265;

// Noise lattice cells per uv unit, and cells per tile. Time offsets are
// wrapped to one tile so the pattern stays seamless and precise over time.
const float NOISE_FREQ = 8.0;
const float NOISE_CELLS = 64.0;
const float TILE = NOISE_CELLS / NOISE_FREQ;

mat2 rot(float a) {
    return mat2(cos(a), sin(a), -sin(a), cos(a));
}

float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float valueNoise(vec2 p) {
    p *= NOISE_FREQ;
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    vec2 i1 = mod(i + 1.0, NOISE_CELLS);
    i = mod(i, NOISE_CELLS);

    float a = hash(i);
    float b = hash(vec2(i1.x, i.y));
    float c = hash(vec2(i.x, i1.y));
    float d = hash(i1);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Noise-lit filaments around the ring, sampled with chromatic offsets
vec3 filaments(vec2 uv, float t, float d0, float scroll) {
    float turb = turbulence;
    vec2 o = chromatic * (0.05 * uv + vec2(0.0, 0.015));

    vec2 uv2 = uv;
    vec3 tx = vec3(0.0);
    for (int i = 0; i < 8; i++) {
        float io = 2.0 * PI * float(i) / 8.0;
        uv2 *= rot(-0.01 * t + io);
        vec2 q = uv2 - scroll;
        vec2 oi = o + shimmer * 0.012 * vec2(sin(t * 6.1 + io * 3.0), cos(t * 4.7 + io * 2.0));
        vec3 tx2 = vec3(valueNoise(q - oi), valueNoise(q), valueNoise(q + oi));
        uv2 *= rot(-0.01 * t - io);

        tx2 *= tx2;
        tx2 *= tx2;
        tx2 *= tx2;
        tx2 *= 1.0 + shimmer * 0.5 * sin(t * 9.0 + io * 5.0);
        tx += d0 * tx2;

        float a = 0.1 * d0 - 0.4 * t;
        uv2 = mix(uv2 * 1.2 - 0.5 * turb,
                  uv + 0.8 * vec2(cos(a), sin(a)) + turb,
                  turb);
    }
    return tx;
}

void main() {
    float t = time;
    float turb = turbulence;

    vec2 uv = vec2(
        (vTexCoord.x - 0.5) * viewSize.x,
        (0.5 - vTexCoord.y) * viewSize.y
    ) / viewSize.y;
    uv /= max(scale, 0.001);
    uv.y += 0.02 * cos(t);
    uv *= 1.0 - 0.4 * turb;
    float r = length(uv);

    float d0 = exp(mix(0.3, 0.5, turb) - mix(spread, 4.0, turb) * sqrt(abs(radius + 0.02 - r)));
    float scroll = mod(0.15 * t, TILE);

    // Blend whole filament fields: mirroring the coordinates partway would
    // collapse the left half onto the center line
    vec3 tx;
    if (symmetry < 0.001) {
        tx = filaments(uv, t, d0, scroll);
    } else if (symmetry > 0.999) {
        tx = filaments(vec2(abs(uv.x), uv.y), t, d0, scroll);
    } else {
        tx = mix(filaments(uv, t, d0, scroll),
                 filaments(vec2(abs(uv.x), uv.y), t, d0, scroll),
                 symmetry);
    }

    vec3 d = abs(0.04 * turb + radius + dispersion * tx - r);

    float th = max(thickness, 0.1);
    vec3 col = mix(color, secondaryColor, 2.5 * d / th) * exp(0.45 - (3.0 / th) * sqrt(d));
    col = max(col, 0.0);

    // Faint churn inside the dark center
    if (core > 0.001) {
        float inner = 1.0 - smoothstep(radius * 0.35, radius * 0.95, r);
        vec2 cp = uv * rot(0.15 * t);
        float n1 = valueNoise(cp * 0.6 + mod(0.05 * t, TILE));
        float n2 = valueNoise(cp * 1.1 - mod(0.07 * t, TILE));
        float churn = n1 * n2;
        col += mix(color, secondaryColor, 0.5) * core * inner * churn * churn * 0.6;
    }

    // Single outward ripple
    if (rippleStrength > 0.0) {
        float p = rippleProgress;
        float rippleRadius = radius + 0.02 + p * 0.5;
        float width = 0.012 + 0.03 * p;
        float fade = (1.0 - p) * (1.0 - p) * smoothstep(0.0, 0.08, p);
        float x = (r - rippleRadius) / width;
        col += color * exp(-x * x) * fade * rippleStrength * 0.6;
    }

    col *= brightness;
    float luminance = dot(col, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(luminance), col, saturation);
    col = clamp(col * intensity, 0.0, 1.0);

    // Glow is luminance-keyed so it only brightens what is behind it
    float alpha = max(col.r, max(col.g, col.b));

    if (alpha < 0.001) {
        fragColor = vec4(0.0);
        return;
    }

    // Straight alpha: the blend stage multiplies rgb by alpha again
    fragColor = vec4(col / alpha, alpha);
}
