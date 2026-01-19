/**
 * Fireworks Overlay Shader Effect
 * 
 * Adapted from shader by Martijn Steinrucken aka BigWings - 2015: https://www.shadertoy.com/view/lscGRl
 * 
 * License: CC BY-NC-SA 3.0 as per original license.
 * If you wish to use this shader for commercial purposes you require permission from original author.
 */


#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

#define TWO_PI 6.283185
#define GOLDEN_RATIO 0.618033

float hash1_1(float p) {
    return fract(sin(p) * 43758.5453);
}

float hash1_2(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float2 hash2_1(float p) {
    return fract(sin(float2(p * 12.9898, p * 78.233)) * 43758.5453);
}

float3 rainbowColor(float h) {
    float hue = hash1_1(h) * 6.0;
    float x = 1.0 - abs(fmod(hue, 2.0) - 1.0);

    if (hue < 1.0) return float3(1.0, x, 0.0);
    if (hue < 2.0) return float3(x, 1.0, 0.0);
    if (hue < 3.0) return float3(0.0, 1.0, x);
    if (hue < 4.0) return float3(0.0, x, 1.0);
    if (hue < 5.0) return float3(x, 0.0, 1.0);
    return float3(1.0, 0.0, x);
}

float3 glow(float2 p, float2 lpos, float intensity, float3 color, float sharpness) {
    float2 q = p - lpos;
    float dist = dot(q, q);

    float atten = 1.0 / (dist * (sharpness * 2.0) + 0.0001);
    atten = pow(atten, 0.5 + sharpness * 0.8);

    return color * atten * intensity;
}

float3 fireworkBurst(float2 uv, float2 center, float age, float duration, float size, float seed, float3 color, float sharpness, float particleCount, float gravity) {
    float3 col = float3(0.0);

    if (age < 0.0 || age > duration) {
        return col;
    }

    float t = age / duration;

    float numParticles = particleCount;

    for (float i = 0.0; i < numParticles; i += 1.0) {
        float f = i / numParticles;
        float r = sqrt(1.0 - f * f);
        float theta = TWO_PI * GOLDEN_RATIO * i;

        float hash = sin(seed + i * 85412.243);
        float weight = 1.0 - 0.2 * hash;
        theta += hash * 3.0 * TWO_PI / numParticles;

        float2 lpos = float2(cos(theta), sin(theta)) * r;

        lpos *= (1.0 - exp(-2.0 * age / weight)) * weight * size;

        lpos.y += age * 0.2 * weight;
        lpos.y -= age * (1.0 - exp(-age * weight)) * gravity * weight;

        lpos += center;

        float intensity = 2e-4;
        intensity *= exp(-2.0 * age);
        intensity *= (1.0 - 0.5 * hash);
        intensity *= (1.0 + 10.0 * exp(-20.0 * age));
        intensity *= (1.0 - pow(t, 1.5));

        col += glow(uv, lpos, intensity, color, sharpness);
    }

    return col;
}

struct FireworkParams {
    float2 position;
    float birthTime;
    float duration;
    float size;
    float3 color;
    float seed;
};

FireworkParams generateFirework(float id, float time, float frequency, float minSize, float maxSize,
                                 float minDuration, float maxDuration, float3 customColor, float useCustomColor) {
    FireworkParams fw;

    float spawnTime = floor(id / frequency);
    float localSeed = id + spawnTime * 123.456;

    fw.seed = localSeed;

    float2 posHash = hash2_1(localSeed);
    fw.position = (posHash - 0.5) * 1.6;

    float spawnWindow = 1.0 / frequency;
    fw.birthTime = spawnTime + hash1_1(localSeed + 1.0) * spawnWindow;

    fw.duration = mix(minDuration, maxDuration, hash1_1(localSeed + 2.0));

    fw.size = mix(minSize, maxSize, hash1_1(localSeed + 3.0));

    if (useCustomColor > 0.5) {
        fw.color = customColor;
    } else {
        fw.color = rainbowColor(localSeed);
    }

    return fw;
}

struct FireworksFragmentParameters {
    float time;
    float intensity;
    float2 viewSize;
    float speed;
    float minSize;
    float maxSize;
    float minDuration;
    float maxDuration;
    float frequency;
    float useCustomColor;
    float sharpness;
    float particleCount;
    float gravity;
    float3 customColor;
};

fragment float4 fireworksFragment(
    VertexOut in [[stage_in]],
    constant FireworksFragmentParameters &params [[buffer(0)]]
) {
    float time = params.time;
    float intensity = params.intensity;
    float2 viewSize = params.viewSize;
    float speed = params.speed;
    float minSize = params.minSize;
    float maxSize = params.maxSize;
    float minDuration = params.minDuration;
    float maxDuration = params.maxDuration;
    float frequency = params.frequency;
    float3 customColor = params.customColor;
    float useCustomColor = params.useCustomColor;
    float sharpness = params.sharpness;
    float particleCount = params.particleCount;
    float gravity = params.gravity;
    float2 texCoord = float2(in.texCoord.x, 1.0 - in.texCoord.y);
    float2 fragCoord = texCoord * viewSize;

    float2 uv = (2.0 * fragCoord - viewSize) / viewSize.y;

    float animTime = time * speed;

    float3 color = float3(0.0);

    int maxFireworks = int(frequency * 5.0) + 2;

    float lookbackTime = 3.0;
    float startId = floor((animTime - lookbackTime) * frequency);
    float endId = floor(animTime * frequency) + float(maxFireworks);

    for (float id = startId; id <= endId; id += 1.0) {
        FireworkParams fw = generateFirework(id, animTime, frequency, minSize, maxSize,
                                             minDuration, maxDuration, customColor, useCustomColor);

        float age = animTime - fw.birthTime;

        if (age >= 0.0 && age <= fw.duration) {
            color += fireworkBurst(uv, fw.position, age, fw.duration, fw.size, fw.seed, fw.color, sharpness, particleCount, gravity);
        }
    }

    color *= intensity;

    color = max(color, 0.0);

    color = (color * (2.51 * color + 0.03)) / (color * (2.43 * color + 0.59) + 0.14);

    color = sqrt(color);

    float alpha = clamp(dot(color, float3(0.299, 0.587, 0.114)), 0.0, 1.0);

    return float4(color, alpha);
}
