/**
 * Blob Overlay Shader Effect
 *
 * Raymarches a glowing, rotating 4D superellipsoid whose shape folds as it
 * turns. The look is driven by uniforms that the native side animates
 * between conversational states. The original rainbow coloring becomes a
 * gradient between two colors, with `iridescence` blending the rainbow back in.
 *
 * Adapted from shader by mrange: https://www.shadertoy.com/view/WXc3D4
 *
 * License: Not specified by original author
 * Commercial use may require permission from original author.
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

struct BlobParameters {
    float time;
    float intensity;
    float2 viewSize;
    float3 color;
    float3 secondaryColor;
    float scale;
    float radius;
    float thickness;
    float twist;
    float iridescence;
    float shimmer;
    float symmetry;
    float core;
    float brightness;
    float saturation;
    float rippleProgress;
    float rippleStrength;
};

float2x2 rotBlob(float a) {
    float c = cos(a);
    float s = sin(a);
    return float2x2(float2(c, s), float2(-s, c));
}

struct BlobSample {
    float d;
    float3 glow;
};

BlobSample sampleBlob(
    float4 p,
    float2x2 R,
    float t,
    float centerMask,
    float shimmerPhase,
    constant BlobParameters &params
) {
    float4 X = p;

    p.xw = p.xw * R;
    p.wy = p.wy * R;
    p.zw = p.zw * R;

    // Position-dependent rotations fold the shape organically
    float twist = params.twist + params.shimmer * 0.35 * sin(t * 9.0 + X.y * 4.0);
    p.xz = p.xz * rotBlob(twist * length(p.yw));
    p.yw = p.yw * rotBlob(twist * length(p.xz));

    float4 P = p * p;

    float deform = length(X - p);
    float phase = 2.0 - X.y + deform + shimmerPhase;
    float weight = 1.0 + sin(phase);
    // Faint churn across the middle of the shape
    weight *= 1.0 + params.core * centerMask * 0.8 * sin(deform * 5.0 - t * 3.0);

    float3 rainbow = 1.0 + sin(phase + float3(0.0, 1.0, 2.0));
    float3 tint = 2.0 * mix(params.color, params.secondaryColor, 0.5 + 0.5 * sin(phase + 1.0));

    BlobSample result;
    result.d = abs(sqrt(sqrt(dot(P, P))) - params.radius) + 1e-3;
    result.glow = weight * mix(tint, rainbow, params.iridescence);
    return result;
}

fragment float4 blobFragment(
    VertexOut in [[stage_in]],
    constant BlobParameters &params [[buffer(0)]]
) {
    float t = params.time;

    float2 C = float2(in.texCoord.x, 1.0 - in.texCoord.y) * params.viewSize;
    float2 uv = (C - 0.5 * params.viewSize) / params.viewSize.y / max(params.scale, 0.001);
    float3 rayDir = normalize(float3(uv, 1.0));

    float2x2 R = rotBlob(0.3 * t);
    // The 4D slice sets the shape's size; a small swing keeps it steady while it morphs
    float slice = 1.3 + 0.12 * cos(0.1 * t);
    float centerMask = 1.0 - smoothstep(0.0, params.radius * 0.25, length(uv));
    float shimmerPhase = params.shimmer * sin(t * 5.0);
    float symmetry = params.symmetry;
    // The surface lies within this 3D radius: a 4D point on the shell has an
    // L2 norm of at most sqrt(2) times the radius, and w is fixed by the slice
    float bound = sqrt(max(2.0 * params.radius * params.radius - slice * slice, 0.0)) + 0.4;

    // Exposure widens the glow, brightness dims below 1
    float exposure = max(params.thickness, 0.05) * params.brightness * 1e-4;

    // Per-pixel start offset reduces banding
    float z = fract(dot(C, sin(C)));
    float3 o = float3(0.0);

    for (int i = 0; i < 65; i++) {
        float4 p = float4(z * rayDir, slice);
        p.z -= 4.0;
        float4 mirrored = float4(abs(p.x), p.yzw);

        // Blend whole samples: mirroring the coordinates partway would
        // collapse half of the shape onto the center plane
        BlobSample hit;
        if (symmetry < 0.001) {
            hit = sampleBlob(p, R, t, centerMask, shimmerPhase, params);
        } else if (symmetry > 0.999) {
            hit = sampleBlob(mirrored, R, t, centerMask, shimmerPhase, params);
        } else {
            BlobSample a = sampleBlob(p, R, t, centerMask, shimmerPhase, params);
            BlobSample b = sampleBlob(mirrored, R, t, centerMask, shimmerPhase, params);
            hit.d = mix(a.d, b.d, symmetry);
            hit.glow = mix(a.glow, b.glow, symmetry);
        }

        o += hit.glow / hit.d;

        // Stop once the glow has saturated or the ray has left the shape behind
        float3 exposed = o * exposure;
        if (min(exposed.r, min(exposed.g, exposed.b)) > 3.0 || max(exposed.r, max(exposed.g, exposed.b)) > 40.0) {
            break;
        }
        if (p.z > 0.0 && length(p.xyz) > bound) {
            break;
        }

        z += 0.6 * hit.d;
    }

    float3 col = tanh(o * exposure) * min(params.brightness, 1.0);

    // Single outward ripple
    if (params.rippleStrength > 0.0) {
        float p = params.rippleProgress;
        float rippleRadius = params.radius * 0.25 * (1.05 + p * 1.6);
        float width = 0.01 + 0.03 * p;
        float fade = (1.0 - p) * (1.0 - p) * smoothstep(0.0, 0.08, p);
        float x = (length(uv) - rippleRadius) / width;
        col += params.color * exp(-x * x) * fade * params.rippleStrength * 0.6;
    }

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
