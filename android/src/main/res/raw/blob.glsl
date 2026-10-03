#version 300 es

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
uniform float twist;
uniform float iridescence;
uniform float shimmer;
uniform float symmetry;
uniform float core;
uniform float brightness;
uniform float saturation;
uniform float rippleProgress;
uniform float rippleStrength;

mat2 rot(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, s, -s, c);
}

struct BlobSample {
    float d;
    vec3 glow;
};

BlobSample sampleBlob(vec4 p, mat2 R, float t, float centerMask, float shimmerPhase) {
    vec4 X = p;

    p.xw *= R;
    p.wy *= R;
    p.zw *= R;

    // Position-dependent rotations fold the shape organically
    float tw = twist + shimmer * 0.35 * sin(t * 9.0 + X.y * 4.0);
    p.xz *= rot(tw * length(p.yw));
    p.yw *= rot(tw * length(p.xz));

    vec4 P = p * p;

    float deform = length(X - p);
    float phase = 2.0 - X.y + deform + shimmerPhase;
    float weight = 1.0 + sin(phase);
    // Faint churn across the middle of the shape
    weight *= 1.0 + core * centerMask * 0.8 * sin(deform * 5.0 - t * 3.0);

    vec3 rainbow = 1.0 + sin(phase + vec3(0.0, 1.0, 2.0));
    vec3 tint = 2.0 * mix(color, secondaryColor, 0.5 + 0.5 * sin(phase + 1.0));

    BlobSample result;
    result.d = abs(sqrt(sqrt(dot(P, P))) - radius) + 1e-3;
    result.glow = weight * mix(tint, rainbow, iridescence);
    return result;
}

void main() {
    float t = time;

    vec2 C = vec2(vTexCoord.x, 1.0 - vTexCoord.y) * viewSize;
    vec2 uv = (C - 0.5 * viewSize) / viewSize.y / max(scale, 0.001);
    vec3 rayDir = normalize(vec3(uv, 1.0));

    mat2 R = rot(0.3 * t);
    // The 4D slice sets the shape's size; a small swing keeps it steady while it morphs
    float slice = 1.3 + 0.12 * cos(0.1 * t);
    float centerMask = 1.0 - smoothstep(0.0, radius * 0.25, length(uv));
    float shimmerPhase = shimmer * sin(t * 5.0);
    // The surface lies within this 3D radius: a 4D point on the shell has an
    // L2 norm of at most sqrt(2) times the radius, and w is fixed by the slice
    float bound = sqrt(max(2.0 * radius * radius - slice * slice, 0.0)) + 0.4;

    // Exposure widens the glow, brightness dims below 1
    float exposure = max(thickness, 0.05) * brightness * 1e-4;

    // Per-pixel start offset reduces banding
    float z = fract(dot(C, sin(C)));
    vec3 o = vec3(0.0);

    for (int i = 0; i < 65; i++) {
        vec4 p = vec4(z * rayDir, slice);
        p.z -= 4.0;
        vec4 mirrored = vec4(abs(p.x), p.yzw);

        // Blend whole samples: mirroring the coordinates partway would
        // collapse half of the shape onto the center plane
        BlobSample hit;
        if (symmetry < 0.001) {
            hit = sampleBlob(p, R, t, centerMask, shimmerPhase);
        } else if (symmetry > 0.999) {
            hit = sampleBlob(mirrored, R, t, centerMask, shimmerPhase);
        } else {
            BlobSample a = sampleBlob(p, R, t, centerMask, shimmerPhase);
            BlobSample b = sampleBlob(mirrored, R, t, centerMask, shimmerPhase);
            hit.d = mix(a.d, b.d, symmetry);
            hit.glow = mix(a.glow, b.glow, symmetry);
        }

        o += hit.glow / hit.d;

        // Stop once the glow has saturated or the ray has left the shape behind
        vec3 exposed = o * exposure;
        if (min(exposed.r, min(exposed.g, exposed.b)) > 3.0 || max(exposed.r, max(exposed.g, exposed.b)) > 40.0) {
            break;
        }
        if (p.z > 0.0 && length(p.xyz) > bound) {
            break;
        }

        z += 0.6 * hit.d;
    }

    vec3 col = tanh(o * exposure) * min(brightness, 1.0);

    // Single outward ripple
    if (rippleStrength > 0.0) {
        float p = rippleProgress;
        float rippleRadius = radius * 0.25 * (1.05 + p * 1.6);
        float width = 0.01 + 0.03 * p;
        float fade = (1.0 - p) * (1.0 - p) * smoothstep(0.0, 0.08, p);
        float x = (length(uv) - rippleRadius) / width;
        col += color * exp(-x * x) * fade * rippleStrength * 0.6;
    }

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
