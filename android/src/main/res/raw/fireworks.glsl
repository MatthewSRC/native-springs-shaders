#version 300 es

/**
 * Fireworks Overlay Shader Effect
 *
 * Adapted from shader by Martijn Steinrucken aka BigWings - 2015: https://www.shadertoy.com/view/lscGRl
 *
 * License: CC BY-NC-SA 3.0 as per original license.
 * If you wish to use this shader for commercial purposes you require permission from original author.
 */
precision highp float;

in vec2 vTexCoord;

out vec4 fragColor;

uniform float time;
uniform float intensity;
uniform vec2 viewSize;
uniform float speed;
uniform float minSize;
uniform float maxSize;
uniform float minDuration;
uniform float maxDuration;
uniform float frequency;
uniform vec3 customColor;
uniform float useCustomColor;
uniform float sharpness;
uniform float u_ParticleCount;
uniform float u_Gravity;

#define TWO_PI 6.283185
#define GOLDEN_RATIO 0.618033
float hash1_1(float p) {
    return fract(sin(p) * 43758.5453);
}

float hash1_2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 hash2_1(float p) {
    return fract(sin(vec2(p * 12.9898, p * 78.233)) * 43758.5453);
}

vec3 rainbowColor(float h) {
    float hue = hash1_1(h) * 6.0;
    float x = 1.0 - abs(mod(hue, 2.0) - 1.0);

    if (hue < 1.0) return vec3(1.0, x, 0.0);
    if (hue < 2.0) return vec3(x, 1.0, 0.0);
    if (hue < 3.0) return vec3(0.0, 1.0, x);
    if (hue < 4.0) return vec3(0.0, x, 1.0);
    if (hue < 5.0) return vec3(x, 0.0, 1.0);
    return vec3(1.0, 0.0, x);
}

vec3 glow(vec2 p, vec2 lpos, float glowIntensity, vec3 color, float glowSharpness) {
    vec2 q = p - lpos;
    float dist = dot(q, q);

    float atten = 1.0 / (dist * (glowSharpness * 2.0) + 0.0001);
    atten = pow(atten, 0.5 + glowSharpness * 0.8);

    return color * atten * glowIntensity;
}

vec3 fireworkBurst(vec2 uv, vec2 center, float age, float duration, float size, float seed, vec3 color, float burstSharpness) {
    vec3 col = vec3(0.0);

    if (age < 0.0 || age > duration) {
        return col;
    }

    float t = age / duration;

    float numParticles = u_ParticleCount;

    for (float i = 0.0; i < numParticles; i += 1.0) {
        float f = i / numParticles;
        float r = sqrt(1.0 - f * f);
        float theta = TWO_PI * GOLDEN_RATIO * i;

        float hashVal = sin(seed + i * 85412.243);
        float weight = 1.0 - 0.2 * hashVal;
        theta += hashVal * 3.0 * TWO_PI / numParticles;

        vec2 lpos = vec2(cos(theta), sin(theta)) * r;

        lpos *= (1.0 - exp(-2.0 * age / weight)) * weight * size;

        float gravity = u_Gravity;
        lpos.y += age * 0.2 * weight;
        lpos.y -= age * (1.0 - exp(-age * weight)) * gravity * weight;

        lpos += center;

        float particleIntensity = 2e-4;
        particleIntensity *= exp(-2.0 * age);
        particleIntensity *= (1.0 - 0.5 * hashVal);
        particleIntensity *= (1.0 + 10.0 * exp(-20.0 * age));
        particleIntensity *= (1.0 - pow(t, 1.5));

        col += glow(uv, lpos, particleIntensity, color, burstSharpness);
    }

    return col;
}
struct FireworkParams {
    vec2 position;
    float birthTime;
    float duration;
    float size;
    vec3 color;
    float seed;
};

FireworkParams generateFirework(float id, float currentTime, float freq, float minSz, float maxSz,
                                 float minDur, float maxDur, vec3 custColor, float useCustColor) {
    FireworkParams fw;

    float spawnTime = floor(id / freq);
    float localSeed = id + spawnTime * 123.456;

    fw.seed = localSeed;

    vec2 posHash = hash2_1(localSeed);
    fw.position = (posHash - 0.5) * 1.6;

    float spawnWindow = 1.0 / freq;
    fw.birthTime = spawnTime + hash1_1(localSeed + 1.0) * spawnWindow;

    fw.duration = mix(minDur, maxDur, hash1_1(localSeed + 2.0));

    fw.size = mix(minSz, maxSz, hash1_1(localSeed + 3.0));

    if (useCustColor > 0.5) {
        fw.color = custColor;
    } else {
        fw.color = rainbowColor(localSeed);
    }

    return fw;
}

void main() {
    vec2 texCoord = vec2(vTexCoord.x, 1.0 - vTexCoord.y);
    vec2 fragCoord = texCoord * viewSize;

    vec2 uv = (2.0 * fragCoord - viewSize) / viewSize.y;

    float animTime = time * speed;

    vec3 color = vec3(0.0);

    int maxFireworks = int(frequency * 5.0) + 2;

    float lookbackTime = 3.0;
    float startId = floor((animTime - lookbackTime) * frequency);
    float endId = floor(animTime * frequency) + float(maxFireworks);

    for (float id = startId; id <= endId; id += 1.0) {
        FireworkParams fw = generateFirework(id, animTime, frequency, minSize, maxSize,
                                             minDuration, maxDuration, customColor, useCustomColor);

        float age = animTime - fw.birthTime;

        if (age >= 0.0 && age <= fw.duration) {
            color += fireworkBurst(uv, fw.position, age, fw.duration, fw.size, fw.seed, fw.color, sharpness);
        }
    }

    color *= intensity;

    color = max(color, 0.0);

    color = (color * (2.51 * color + 0.03)) / (color * (2.43 * color + 0.59) + 0.14);

    color = sqrt(color);

    float alpha = clamp(dot(color, vec3(0.299, 0.587, 0.114)), 0.0, 1.0);

    fragColor = vec4(color, alpha);
}
