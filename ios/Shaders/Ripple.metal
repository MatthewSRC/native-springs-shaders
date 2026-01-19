/**
 * Ripple Shader Effect
 *
 * Created by Matthias Brandolin - 2025
 *
 * License: MIT
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

struct RippleParameters {
    float intensity;
    float time;
    float2 touchPoint;
    float touchTime;
    float frequency;
    float damping;
    float rippleVariant;
    float speed;
    float ringWidth;
    float slowdownFactor;
    float displacementStrength;
    float highlightStrength;
    float3 rippleColor;
};

float calculateRealisticRipple(float2 position, float2 center, float time, float amplitude, float maxSpeed, float ringWidth, float damping, float slowdownFactor) {
    if (amplitude <= 0.0 || time <= 0.0) return 0.0;

    float distance = length(position - center);

    float currentRadius = maxSpeed * (1.0 - exp(-time * slowdownFactor)) / slowdownFactor;

    float distanceFromWave = abs(distance - currentRadius);
    if (distanceFromWave > ringWidth) return 0.0;

    float normalizedDistance = distanceFromWave / ringWidth;
    float wavePulse = exp(-normalizedDistance * normalizedDistance * 8.0);

    float timeFade = exp(-time * damping);
    float distanceFade = amplitude / (1.0 + distance / 150.0);

    return wavePulse * timeFade * distanceFade;
}

float calculateDefaultRipple(float2 position, float2 center, float time, float frequency, float damping, float speed) {
    if (time <= 0.0) return 0.0;

    float distance = length(position - center);

    float currentRadius = time * speed;

    float distanceFromWave = abs(distance - currentRadius);

    float wavePulse = exp(-distanceFromWave * frequency * 10.0);

    float timeFade = exp(-time * damping);
    float distanceFade = exp(-distance * damping * 2.0);

    return wavePulse * timeFade * distanceFade;
}

fragment float4 rippleFragment(VertexOut in [[stage_in]],
                               texture2d<float> inputTexture [[texture(0)]],
                               constant RippleParameters &params [[buffer(0)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

    float2 resolution = float2(inputTexture.get_width(), inputTexture.get_height());
    float2 uv = in.texCoord;

    float wave = 0.0;

    if (params.rippleVariant > 0.5) {
        float2 pixelPos = uv * resolution;
        float2 centerPos = params.touchPoint * resolution;
        wave = calculateRealisticRipple(pixelPos, centerPos, params.touchTime, params.intensity, params.speed, params.ringWidth, params.damping, params.slowdownFactor);
    } else {
        float aspect = resolution.x / resolution.y;
        float2 aspectCorrection = float2(aspect, 1.0);

        float2 correctedUV = uv * aspectCorrection;
        float2 correctedTouch = params.touchPoint * aspectCorrection;
        wave = calculateDefaultRipple(correctedUV, correctedTouch, params.touchTime, params.frequency, params.damping, params.speed);
    }

    float2 displacement = float2(0.0);
    if (wave > 0.01) {
        float2 direction = normalize(uv - params.touchPoint);

        float displaceStrength = wave * params.intensity * params.displacementStrength;
        displacement = direction * displaceStrength;
    }

    float2 distortedUV = uv + displacement;

    distortedUV = clamp(distortedUV, float2(0.0), float2(1.0));

    float4 color = inputTexture.sample(textureSampler, distortedUV);

    float highlight = wave * params.intensity * params.highlightStrength;
    color.rgb += params.rippleColor * highlight;

    return color;
}
