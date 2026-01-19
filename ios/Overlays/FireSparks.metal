/**
 * FireSparks Overlay Shader Effect
 *
 * Adapted from shader by Jan Mróz (jaszunio15): https://www.shadertoy.com/view/wl2Gzc
 * Adapted by Matthias Brandolin - 2025
 *
 * License: MIT
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

#define PARTICLE_SCALE (float2(0.5, 1.6))
#define PARTICLE_SCALE_VAR (float2(0.25, 0.2))

#define PARTICLE_BLOOM_SCALE (float2(0.5, 0.8))
#define PARTICLE_BLOOM_SCALE_VAR (float2(0.3, 0.1))

#define SIZE_MOD 1.05
#define ALPHA_MOD 0.9
#define LAYERS_COUNT 15

float hash1_2(float2 x) {
    return fract(sin(dot(x, float2(52.127, 61.2871))) * 521.582);
}

float2 hash2_2(float2 x) {
    return fract(sin(x * float2x2(20.52, 24.1994, 70.291, 80.171)) * 492.194);
}

float2 noise2_2(float2 uv) {
    float2 f = smoothstep(0.0, 1.0, fract(uv));

    float2 uv00 = floor(uv);
    float2 uv01 = uv00 + float2(0, 1);
    float2 uv10 = uv00 + float2(1, 0);
    float2 uv11 = uv00 + 1.0;
    float2 v00 = hash2_2(uv00);
    float2 v01 = hash2_2(uv01);
    float2 v10 = hash2_2(uv10);
    float2 v11 = hash2_2(uv11);

    float2 v0 = mix(v00, v01, f.y);
    float2 v1 = mix(v10, v11, f.y);
    float2 v = mix(v0, v1, f.x);

    return v;
}

float noise1_2(float2 uv) {
    float2 f = fract(uv);

    float2 uv00 = floor(uv);
    float2 uv01 = uv00 + float2(0, 1);
    float2 uv10 = uv00 + float2(1, 0);
    float2 uv11 = uv00 + 1.0;

    float v00 = hash1_2(uv00);
    float v01 = hash1_2(uv01);
    float v10 = hash1_2(uv10);
    float v11 = hash1_2(uv11);

    float v0 = mix(v00, v01, f.y);
    float v1 = mix(v10, v11, f.y);
    float v = mix(v0, v1, f.x);

    return v;
}

float layeredNoise1_2(float2 uv, float sizeMod, float alphaMod, int layers, float animation, float time, float2 movementDirection, float movementSpeed) {
    float noise = 0.0;
    float alpha = 1.0;
    float size = 1.0;
    float2 offset = float2(0.0);

    for (int i = 0; i < layers; i++) {
        offset += hash2_2(float2(alpha, size)) * 10.0;

        noise += noise1_2(uv * size - time * animation * 8.0 * movementDirection * movementSpeed + offset) * alpha;
        alpha *= alphaMod;
        size *= sizeMod;
    }

    noise *= (1.0 - alphaMod) / (1.0 - pow(alphaMod, float(layers)));
    return noise;
}

float2 rotate(float2 point, float deg) {
    float s = sin(deg);
    float c = cos(deg);
    return float2x2(s, c, -c, s) * point;
}

float2 voronoiPointFromRoot(float2 root, float deg) {
    float2 point = hash2_2(root) - 0.5;
    float s = sin(deg);
    float c = cos(deg);
    point = float2x2(s, c, -c, s) * point * 0.66;
    point += root + 0.5;
    return point;
}

float degFromRootUV(float2 uv, float time, float animationSpeed) {
    return time * animationSpeed * (hash1_2(uv) - 0.5) * 2.0;
}

float2 randomAround2_2(float2 point, float2 range, float2 uv) {
    return point + (hash2_2(uv) - 0.5) * range;
}

float3 fireParticles(float2 uv, float2 originalUV, float time, float2 movementDirection, float travelDistance, float3 sparkColor, float particleSize, float animationSpeed, float particleBloom) {
    float3 particles = float3(0.0);
    float2 rootUV = floor(uv);
    float deg = degFromRootUV(rootUV, time, animationSpeed);
    float2 pointUV = voronoiPointFromRoot(rootUV, deg);
    float dist = 2.0;
    float distBloom = 0.0;

    float2 tempUV = uv + (noise2_2(uv * 2.0) - 0.5) * 0.1;
    tempUV += -(noise2_2(uv * 3.0 + time) - 0.5) * 0.07;

    dist = length(rotate(tempUV - pointUV, 0.7) * randomAround2_2(PARTICLE_SCALE, PARTICLE_SCALE_VAR, rootUV));

    distBloom = length(rotate(tempUV - pointUV, 0.7) * randomAround2_2(PARTICLE_BLOOM_SCALE, PARTICLE_BLOOM_SCALE_VAR, rootUV));

    particles += (1.0 - smoothstep(particleSize * 0.6, particleSize * 3.0, dist)) * (sparkColor * 1.5);

    particles += pow((1.0 - smoothstep(0.0, particleSize * 6.0, distBloom)) * particleBloom, 3.0) * (sparkColor * 0.8);

    float2 normDir = normalize(movementDirection);
    float posAlongDirection = dot(originalUV, normDir);

    float maxRange = 1.8;
    float fadeStart = -maxRange * travelDistance;
    float fadeEnd = maxRange * travelDistance;

    float border = (hash1_2(rootUV) - 0.5) * 2.0;
    float fadeOut = smoothstep(fadeStart + border, fadeEnd + border, posAlongDirection);

    return particles * (1.0 - fadeOut);
}

float3 layeredParticles(float2 uv, float sizeMod, float alphaMod, int layers, float smoke, float time, float2 movementDirection, float travelDistance, float3 sparkColor, float particleSize, float animationSpeed, float particleBloom, float movementSpeed) {
    float3 particles = float3(0);
    float size = 1.0;
    float alpha = 1.0;
    float2 offset = float2(0.0);
    float2 noiseOffset;
    float2 bokehUV;

    for (int i = 0; i < layers; i++) {
        noiseOffset = (noise2_2(uv * size * 2.0 + 0.5) - 0.5) * 0.15;

        bokehUV = (uv * size - time * movementDirection * movementSpeed) + offset + noiseOffset;

        particles += fireParticles(bokehUV, uv, time, movementDirection, travelDistance, sparkColor, particleSize, animationSpeed, particleBloom) * alpha * (1.0 - smoothstep(0.0, 1.0, smoke) * (float(i) / float(layers)));

        offset += hash2_2(float2(alpha, alpha)) * 10.0;

        alpha *= alphaMod;
        size *= sizeMod;
    }

    return particles;
}

struct FireSparksParameters {
    float time;
    float intensity;
    float2 viewSize;
    float2 movementDirection;
    float travelDistance;
    float particleSize;
    float animationSpeed;
    float smokeIntensity;
    float particleBloom;
    float movementSpeed;
    float3 sparkColor;
};

fragment float4 fireSparksFragment(
    VertexOut in [[stage_in]],
    constant FireSparksParameters &params [[buffer(0)]]
) {
    float time = params.time;
    float intensity = params.intensity;
    float2 viewSize = params.viewSize;
    float2 movementDirection = params.movementDirection;
    float travelDistance = params.travelDistance;
    float3 sparkColor = params.sparkColor;
    float particleSize = params.particleSize;
    float animationSpeed = params.animationSpeed;
    float smokeIntensity = params.smokeIntensity;
    float particleBloom = params.particleBloom;
    float movementSpeed = params.movementSpeed;
    float2 texCoord = float2(in.texCoord.x, 1.0 - in.texCoord.y);

    float2 fragCoord = texCoord * viewSize;

    float minDim = min(viewSize.x, viewSize.y);
    float2 uv = (2.0 * fragCoord - viewSize) / minDim;

    uv *= 1.8;

    float2 normDir = normalize(movementDirection);

    float smokeIntensityValue = layeredNoise1_2(uv * 10.0 - time * 4.0 * movementDirection * movementSpeed, 1.7, 0.7, 6, 0.2, time, movementDirection, movementSpeed);

    float posAlongDirection = dot(uv, normDir);
    smokeIntensityValue *= pow(1.0 - smoothstep(-1.8, 1.8, posAlongDirection), 2.0);

    float3 smokeBaseColor = sparkColor * float3(1.0, 1.075, 1.25);
    float3 smoke = smokeIntensityValue * smokeBaseColor * smokeIntensity;

    smoke *= pow(layeredNoise1_2(uv * 4.0 - time * 0.5 * movementDirection * movementSpeed, 1.8, 0.5, 3, 0.2, time, movementDirection, movementSpeed), 2.0) * 1.5;

    float3 particles = layeredParticles(uv, SIZE_MOD, ALPHA_MOD, LAYERS_COUNT, smokeIntensityValue, time, movementDirection, travelDistance, sparkColor, particleSize, animationSpeed, particleBloom, movementSpeed);

    float3 col = particles + smoke + smokeBaseColor * 0.02;

    col = smoothstep(-0.08, 1.0, col);

    float alpha = clamp(length(col) * intensity, 0.0, 1.0);

    return float4(col * intensity, alpha);
}
