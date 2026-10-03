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

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

struct OrbParameters {
    float time;
    float intensity;
    float2 viewSize;
    float3 color;
    float3 secondaryColor;
    float scale;
    float radius;
    float thickness;
    float dispersion;
    float spread;
    float turbulence;
    float chromatic;
    float shimmer;
    float symmetry;
    float core;
    float brightness;
    float saturation;
    float rippleProgress;
    float rippleStrength;
};

// Noise lattice cells per uv unit, and cells per tile. Time offsets are
// wrapped to one tile so the pattern stays seamless and precise over time.
constant float ORB_NOISE_FREQ = 8.0;
constant float ORB_NOISE_CELLS = 64.0;
constant float ORB_TILE = ORB_NOISE_CELLS / ORB_NOISE_FREQ;

float wrapOrb(float x, float period) {
    return x - period * floor(x / period);
}

float2x2 rotOrb(float a) {
    return float2x2(float2(cos(a), sin(a)), float2(-sin(a), cos(a)));
}

float hashOrb(float2 p) {
    float3 p3 = fract(float3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noiseOrb(float2 p) {
    p *= ORB_NOISE_FREQ;
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);

    float2 i1 = i + 1.0;
    i = i - ORB_NOISE_CELLS * floor(i / ORB_NOISE_CELLS);
    i1 = i1 - ORB_NOISE_CELLS * floor(i1 / ORB_NOISE_CELLS);

    float a = hashOrb(i);
    float b = hashOrb(float2(i1.x, i.y));
    float c = hashOrb(float2(i.x, i1.y));
    float d = hashOrb(i1);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Noise-lit filaments around the ring, sampled with chromatic offsets
float3 filamentsOrb(float2 uv, float t, float d0, float scroll, constant OrbParameters &params) {
    float turb = params.turbulence;
    float2 o = params.chromatic * (0.05 * uv + float2(0.0, 0.015));

    float2 uv2 = uv;
    float3 tx = float3(0.0);
    for (int i = 0; i < 8; i++) {
        float io = 2.0 * M_PI_F * float(i) / 8.0;
        uv2 = uv2 * rotOrb(-0.01 * t + io);
        float2 q = uv2 - scroll;
        float2 oi = o + params.shimmer * 0.012 * float2(sin(t * 6.1 + io * 3.0), cos(t * 4.7 + io * 2.0));
        float3 tx2 = float3(noiseOrb(q - oi), noiseOrb(q), noiseOrb(q + oi));
        uv2 = uv2 * rotOrb(-0.01 * t - io);

        tx2 *= tx2;
        tx2 *= tx2;
        tx2 *= tx2;
        tx2 *= 1.0 + params.shimmer * 0.5 * sin(t * 9.0 + io * 5.0);
        tx += d0 * tx2;

        float a = 0.1 * d0 - 0.4 * t;
        uv2 = mix(uv2 * 1.2 - 0.5 * turb,
                  uv + 0.8 * float2(cos(a), sin(a)) + turb,
                  turb);
    }
    return tx;
}

fragment float4 orbFragment(
    VertexOut in [[stage_in]],
    constant OrbParameters &params [[buffer(0)]]
) {
    float t = params.time;
    float turb = params.turbulence;

    float2 uv = float2(
        (in.texCoord.x - 0.5) * params.viewSize.x,
        (0.5 - in.texCoord.y) * params.viewSize.y
    ) / params.viewSize.y;
    uv /= max(params.scale, 0.001);
    uv.y += 0.02 * cos(t);
    uv *= 1.0 - 0.4 * turb;
    float r = length(uv);

    float d0 = exp(mix(0.3, 0.5, turb) - mix(params.spread, 4.0, turb) * sqrt(abs(params.radius + 0.02 - r)));
    float scroll = wrapOrb(0.15 * t, ORB_TILE);

    // Blend whole filament fields: mirroring the coordinates partway would
    // collapse the left half onto the center line
    float3 tx;
    if (params.symmetry < 0.001) {
        tx = filamentsOrb(uv, t, d0, scroll, params);
    } else if (params.symmetry > 0.999) {
        tx = filamentsOrb(float2(abs(uv.x), uv.y), t, d0, scroll, params);
    } else {
        tx = mix(filamentsOrb(uv, t, d0, scroll, params),
                 filamentsOrb(float2(abs(uv.x), uv.y), t, d0, scroll, params),
                 params.symmetry);
    }

    float3 d = abs(0.04 * turb + params.radius + params.dispersion * tx - r);

    float thickness = max(params.thickness, 0.1);
    float3 col = mix(params.color, params.secondaryColor, 2.5 * d / thickness)
        * exp(0.45 - (3.0 / thickness) * sqrt(d));
    col = max(col, 0.0);

    // Faint churn inside the dark center
    if (params.core > 0.001) {
        float inner = 1.0 - smoothstep(params.radius * 0.35, params.radius * 0.95, r);
        float2 cp = uv * rotOrb(0.15 * t);
        float n1 = noiseOrb(cp * 0.6 + wrapOrb(0.05 * t, ORB_TILE));
        float n2 = noiseOrb(cp * 1.1 - wrapOrb(0.07 * t, ORB_TILE));
        float churn = n1 * n2;
        col += mix(params.color, params.secondaryColor, 0.5) * params.core * inner * churn * churn * 0.6;
    }

    // Single outward ripple
    if (params.rippleStrength > 0.0) {
        float p = params.rippleProgress;
        float rippleRadius = params.radius + 0.02 + p * 0.5;
        float width = 0.012 + 0.03 * p;
        float fade = (1.0 - p) * (1.0 - p) * smoothstep(0.0, 0.08, p);
        float x = (r - rippleRadius) / width;
        col += params.color * exp(-x * x) * fade * params.rippleStrength * 0.6;
    }

    col *= params.brightness;
    float luminance = dot(col, float3(0.299, 0.587, 0.114));
    col = mix(float3(luminance), col, params.saturation);
    col = saturate(col * params.intensity);

    // Glow is luminance-keyed so it only brightens what is behind it
    float alpha = max(col.r, max(col.g, col.b));

    if (alpha < 0.001) {
        return float4(0.0);
    }

    return float4(col, alpha);
}
