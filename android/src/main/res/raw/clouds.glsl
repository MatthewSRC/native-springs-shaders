#version 300 es

/**
 * Clouds Overlay Shader Effect
 *
 * Creates soft, blurry gradient blobs for ambient backgrounds.
 * Designed for use behind blurred cards and frosted glass UI elements.
 *
 * Created by Matthias Brandolin - 2026
 *
 * License: MIT
 */

precision highp float;

in vec2 vTexCoord;

out vec4 fragColor;

uniform float time;
uniform float intensity;
uniform vec2 viewSize;
uniform vec3 color;
uniform vec3 secondaryColor;
uniform vec3 tertiaryColor;
uniform float scale;
uniform float speed;
uniform float softness;
uniform float blobCount;

float blob(vec2 uv, vec2 center, float radius, float soft) {
    float d = length(uv - center);
    float falloff = radius * (0.3 + soft * 0.7);
    return exp(-(d * d) / (2.0 * falloff * falloff));
}

void main() {
    vec2 uv = vTexCoord;
    float t = time * speed;

    float aspect = viewSize.x / viewSize.y;
    vec2 p = vec2((uv.x - 0.5) * aspect, uv.y - 0.5);

    float baseRadius = scale * 0.3;
    float soft = softness;
    int count = clamp(int(blobCount), 1, 5);

    vec3 result = vec3(0.0);

    if (count >= 1) {
        vec2 c1 = vec2(
            sin(t * 0.23 + 1.0) * 0.25 - 0.15,
            cos(t * 0.19 + 2.0) * 0.2 + 0.05
        );
        float b1 = blob(p, c1, baseRadius * 1.2, soft);
        result += color * b1;
    }

    if (count >= 2) {
        vec2 c2 = vec2(
            cos(t * 0.17 + 4.0) * 0.3 + 0.2,
            sin(t * 0.21 + 0.5) * 0.25 - 0.1
        );
        float b2 = blob(p, c2, baseRadius * 1.0, soft);
        result += secondaryColor * b2;
    }

    if (count >= 3) {
        vec2 c3 = vec2(
            sin(t * 0.15 + 3.5) * 0.2 + 0.0,
            cos(t * 0.25 + 5.0) * 0.3 - 0.15
        );
        float b3 = blob(p, c3, baseRadius * 0.9, soft);
        result += tertiaryColor * b3;
    }

    if (count >= 4) {
        vec2 c4 = vec2(
            cos(t * 0.13 + 6.0) * 0.35 - 0.1,
            sin(t * 0.18 + 1.5) * 0.2 + 0.2
        );
        float b4 = blob(p, c4, baseRadius * 0.8, soft);
        vec3 mixColor = mix(color, secondaryColor, 0.5);
        result += mixColor * b4;
    }

    if (count >= 5) {
        vec2 c5 = vec2(
            sin(t * 0.2 + 8.0) * 0.25 + 0.15,
            cos(t * 0.14 + 3.0) * 0.25 + 0.1
        );
        float b5 = blob(p, c5, baseRadius * 0.7, soft);
        vec3 mixColor = mix(secondaryColor, tertiaryColor, 0.5);
        result += mixColor * b5;
    }

    float alpha = clamp(length(result) * intensity, 0.0, 1.0);

    if (alpha < 0.001) {
        fragColor = vec4(0.0);
        return;
    }

    result *= intensity;

    fragColor = vec4(result * alpha, alpha);
}
