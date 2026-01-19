#version 300 es

/**
 * Sparkles Overlay Shader Effect
 *
 * Inspired from shader by Nimphious: https://www.shadertoy.com/view/XcfcWj
 * Created by Matthias Brandolin - 2025
 *
 * License: MIT
 */
precision highp float;

in vec2 vTexCoord;

out vec4 fragColor;

uniform float time;
uniform float intensity;
uniform vec2 viewSize;
uniform float density;
uniform float size;
uniform float speed;
uniform vec3 color;
uniform float colorize;
uniform float u_TwinkleSpeed;
uniform float u_BrightnessMultiplier;
vec3 hash33(vec3 p) {
    uvec3 q = uvec3(ivec3(p)) * uvec3(1597334673u, 3812015801u, 2798796415u);
    q = (q.x ^ q.y ^ q.z) * uvec3(1597334673u, 3812015801u, 2798796415u);
    return vec3(q) * 2.328306437080797e-10;
}

vec4 HSV_to_RGB(vec4 hsv) {
    vec3 k = mod(vec3(5.0, 3.0, 1.0) + hsv.x * 3.0 / 3.14159265, 6.0);
    vec3 rgb = hsv.z - hsv.z * hsv.y * max(vec3(0.0), min(min(k, 4.0 - k), vec3(1.0)));
    return vec4(rgb, hsv.w);
}

float minkowski_dist(vec3 a, vec3 b, float p) {
    return pow(
        pow(abs(a.x - b.x), p) +
        pow(abs(a.y - b.y), p) +
        pow(abs(a.z - b.z), p),
        1.0 / p
    );
}

struct Voronoi3DTile {
    vec4 pd;
    vec3 id;
};

Voronoi3DTile voronoi3D(vec3 p) {
    vec3 pg = floor(p);
    vec3 pc = fract(p);

    float d = 1.0;
    vec3 c = vec3(100.0);
    vec3 pv = vec3(0.0);

    for (int i = 0; i < 27; i++) {
        vec3 n = vec3(
            float(i % 3),
            float((i / 3) % 3),
            float(i / 9)
        ) - 1.0;

        vec3 pn = hash33(pg + n);
        float dn = minkowski_dist(n + hash33(pg + n), pc, 0.4);

        if (d > dn) {
            d = dn;
            c = n;
            pv = pn + n - pc;
        }
    }

    return Voronoi3DTile(vec4(pv, d), pg + c);
}

void main() {
    vec2 uv = vTexCoord;
    float t = time * speed * 0.3;

    float sparkleValue = 0.0;
    vec3 sparkleColor = vec3(0.0);

    for (int layer = 0; layer < 3; layer++) {
        vec3 layerSeed = vec3(float(layer) * 234.567, float(layer) * 891.234, 0.0);
        vec3 layerRand = hash33(layerSeed);

        float timeOffset = layerRand.x * 10.0;
        float layerTime = t + timeOffset;

        vec2 spatialOffset = layerRand.xy * 100.0;

        float scale = 6.0;
        vec3 p = vec3((uv + spatialOffset) * scale, layerTime);

        Voronoi3DTile vt = voronoi3D(p);

        float cellHash = fract(sin(dot(vt.id, vec3(12.9898, 78.233, 45.164))) * 43758.5453);

        float densityThreshold = clamp(density / 8.0, 0.0, 1.0);
        if (cellHash > densityThreshold) {
            continue;
        }

        float sizeHash = fract(sin(dot(vt.id, vec3(45.164, 12.9898, 78.233))) * 43758.5453);
        float minSize = size * 0.5;
        float maxSize = size * 1.5;
        float sparkleSize = mix(minSize, maxSize, sizeHash);

        float dist = vt.pd.w;

        float threshold = min(sparkleSize * 0.6, 0.95);

        float sparkle = smoothstep(threshold, threshold * 0.3, dist);

        float twinklePhase = fract(layerTime * u_TwinkleSpeed + cellHash);
        float twinkle = smoothstep(0.0, 0.2, twinklePhase) * smoothstep(1.0, 0.8, twinklePhase);

        sparkle *= twinkle;

        if (sparkle > 0.0) {
            sparkleValue = max(sparkleValue, sparkle);

            if (colorize > 0.5) {
                float hue = fract(vt.id.x * 0.1 + vt.id.y * 0.13 + vt.id.z * 0.17) * 2.0 * 3.14159265;
                sparkleColor = max(sparkleColor, HSV_to_RGB(vec4(hue, 1.0, 1.0, 1.0)).rgb * sparkle);
            } else {
                sparkleColor = max(sparkleColor, color * sparkle);
            }
        }
    }

    vec3 finalColor = sparkleColor * u_BrightnessMultiplier;
    float alpha = sparkleValue * intensity;

    fragColor = vec4(finalColor, alpha);
}
