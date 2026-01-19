/**
 * Sparkles Overlay Shader Effect
 *
 * Inspired from shader by Nimphious: https://www.shadertoy.com/view/XcfcWj
 * Created by Matthias Brandolin - 2025
 *
 * License: MIT
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

float3 hash33(float3 p) {
    uint3 q = uint3(int3(p)) * uint3(1597334673u, 3812015801u, 2798796415u);
    q = (q.x ^ q.y ^ q.z) * uint3(1597334673u, 3812015801u, 2798796415u);
    return float3(q) * 2.328306437080797e-10;
}

float4 HSV_to_RGB(float4 hsv) {
    float3 k = fmod(float3(5.0, 3.0, 1.0) + hsv.x * 3.0 / M_PI_F, 6.0);
    float3 rgb = hsv.z - hsv.z * hsv.y * max(float3(0.0), min(min(k, 4.0 - k), float3(1.0)));
    return float4(rgb, hsv.w);
}

float minkowski_dist(float3 a, float3 b, float p) {
    return pow(
        pow(abs(a.x - b.x), p) +
        pow(abs(a.y - b.y), p) +
        pow(abs(a.z - b.z), p),
        1.0 / p
    );
}

struct Voronoi3DTile {
    float4 pd;
    float3 id;
};

Voronoi3DTile voronoi3D(float3 p) {
    float3 pg = floor(p);
    float3 pc = fract(p);

    float d = 1.0;
    float3 c = float3(100.0);
    float3 pv = float3(0.0);

    for (int i = 0; i < 27; i++) {
        float3 n = float3(
            float(i % 3),
            float((i / 3) % 3),
            float(i / 9)
        ) - 1.0;

        float3 pn = hash33(pg + n);
        float dn = minkowski_dist(n + hash33(pg + n), pc, 0.4);

        if (d > dn) {
            d = dn;
            c = n;
            pv = pn + n - pc;
        }
    }

    return Voronoi3DTile{float4(pv, d), pg + c};
}

struct SparklesParameters {
    float time;
    float intensity;
    float2 viewSize;
    float density;
    float size;
    float speed;
    float colorize;
    float twinkleSpeed;
    float brightnessMultiplier;
    float3 color;
};

fragment float4 sparklesFragment(
    VertexOut in [[stage_in]],
    constant SparklesParameters &params [[buffer(0)]]
) {
    float time = params.time;
    float intensity = params.intensity;
    float2 viewSize = params.viewSize;
    float density = params.density;
    float size = params.size;
    float speed = params.speed;
    float3 color = params.color;
    float colorize = params.colorize;
    float twinkleSpeed = params.twinkleSpeed;
    float brightnessMultiplier = params.brightnessMultiplier;
    float2 uv = in.texCoord;
    float t = time * speed * 0.3;

    float sparkleValue = 0.0;
    float3 sparkleColor = float3(0.0);

    for (int layer = 0; layer < 3; layer++) {
        float3 layerSeed = float3(float(layer) * 234.567, float(layer) * 891.234, 0.0);
        float3 layerRand = hash33(layerSeed);

        float timeOffset = layerRand.x * 10.0;
        float layerTime = t + timeOffset;

        float2 spatialOffset = layerRand.xy * 100.0;

        float scale = 6.0;
        float3 p = float3((uv + spatialOffset) * scale, layerTime);

        Voronoi3DTile vt = voronoi3D(p);

        float cellHash = fract(sin(dot(vt.id, float3(12.9898, 78.233, 45.164))) * 43758.5453);

        float densityThreshold = clamp(density / 8.0, 0.0, 1.0);
        if (cellHash > densityThreshold) {
            continue;
        }

        float sizeHash = fract(sin(dot(vt.id, float3(45.164, 12.9898, 78.233))) * 43758.5453);
        float minSize = size * 0.5;
        float maxSize = size * 1.5;
        float sparkleSize = mix(minSize, maxSize, sizeHash);

        float dist = vt.pd.w;

        float threshold = min(sparkleSize * 0.6, 0.95);

        float sparkle = smoothstep(threshold, threshold * 0.3, dist);

        float twinklePhase = fract(layerTime * twinkleSpeed + cellHash);
        float twinkle = smoothstep(0.0, 0.2, twinklePhase) * smoothstep(1.0, 0.8, twinklePhase);

        sparkle *= twinkle;

        if (sparkle > 0.0) {
            sparkleValue = max(sparkleValue, sparkle);

            if (colorize > 0.5) {
                float hue = fract(vt.id.x * 0.1 + vt.id.y * 0.13 + vt.id.z * 0.17) * 2.0 * M_PI_F;
                sparkleColor = max(sparkleColor, HSV_to_RGB(float4(hue, 1.0, 1.0, 1.0)).rgb * sparkle);
            } else {
                sparkleColor = max(sparkleColor, color * sparkle);
            }
        }
    }

    float3 finalColor = sparkleColor * brightnessMultiplier;
    float alpha = sparkleValue * intensity;

    return float4(finalColor, alpha);
}
