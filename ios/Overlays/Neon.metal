/**
 * Neon Overlay Shader Effect
 *
 * Creates an animated neon glow border effect that encapsulates content.
 *
 * Created by Matthias Brandolin - 2026
 *
 * License: MIT
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

struct NeonParameters {
    float time;
    float intensity;
    float2 viewSize;
    float borderWidth;
    float cornerRadius;
    float3 color;
    float3 secondaryColor;
    float glowSize;
    float glowFalloff;
    float flowSpeed;
    float flowIntensity;
    float pulseSpeed;
    float pulseIntensity;
    float flickerIntensity;
    float colorBlend;
    float inset;
};

float hashNeon(float n) {
    return fract(sin(n) * 43758.5453);
}

float noiseNeon(float t) {
    float fl = floor(t);
    float fc = fract(t);
    return mix(hashNeon(fl), hashNeon(fl + 1.0), fc);
}

float roundedBoxSDFNeon(float2 p, float2 halfSize, float r) {
    float2 q = abs(p) - halfSize + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

fragment float4 neonFragment(
    VertexOut in [[stage_in]],
    constant NeonParameters &params [[buffer(0)]]
) {
    float2 uv = in.texCoord;
    float time = params.time;

    float2 pixelCoord = (uv - 0.5) * params.viewSize;
    float2 halfSize = params.viewSize * 0.5 - params.inset;

    float radiusPx = min(params.cornerRadius, min(halfSize.x, halfSize.y) - params.borderWidth);
    radiusPx = max(radiusPx, 0.0);

    float outerDist = roundedBoxSDFNeon(pixelCoord, halfSize, radiusPx);

    float innerRadius = max(radiusPx - params.borderWidth, 0.0);
    float2 innerHalfSize = halfSize - params.borderWidth;
    float innerDist = roundedBoxSDFNeon(pixelCoord, innerHalfSize, innerRadius);

    float borderMask = smoothstep(1.0, -1.0, outerDist) * smoothstep(-1.0, 1.0, innerDist);

    float distFromBorder = min(abs(outerDist), abs(innerDist));
    if (innerDist < 0.0) {
        distFromBorder = -innerDist;
    }
    if (outerDist > 0.0) {
        distFromBorder = outerDist;
    }

    float glowPixels = params.glowSize * params.borderWidth;

    float outerGlowMask = 0.0;
    if (outerDist > 0.0) {
        outerGlowMask = exp(-outerDist / glowPixels * params.glowFalloff);
    }

    float innerGlowMask = 0.0;
    if (innerDist < 0.0) {
        innerGlowMask = exp(innerDist / glowPixels * params.glowFalloff);
    }

    float totalMask = borderMask + outerGlowMask * 0.6 + innerGlowMask * 0.6;

    if (totalMask < 0.001) {
        return float4(0.0);
    }

    float pulse = 1.0;
    if (params.pulseIntensity > 0.001) {
        pulse = 1.0 - params.pulseIntensity * 0.4 * (0.5 + 0.5 * sin(time * params.pulseSpeed * 3.0));
    }

    float flicker = 1.0;
    if (params.flickerIntensity > 0.001) {
        float flickerNoise = noiseNeon(time * 25.0) * noiseNeon(time * 37.0 + 50.0);
        flicker = 1.0 - params.flickerIntensity * 0.2 * (1.0 - flickerNoise);
    }

    float2 centeredUV = uv - 0.5;
    float angle = atan2(centeredUV.y * params.viewSize.y, centeredUV.x * params.viewSize.x);
    float normalizedAngle = (angle + M_PI_F) / (2.0 * M_PI_F);

    float flow = 1.0;
    if (params.flowIntensity > 0.001 && params.flowSpeed > 0.001) {
        float flowPos1 = fract(time * params.flowSpeed * 0.15);
        float flowDist1 = normalizedAngle - flowPos1;
        flowDist1 = abs(fract(flowDist1 + 0.5) - 0.5);
        float flowBright1 = smoothstep(0.12, 0.0, flowDist1);
        flowBright1 = pow(flowBright1, 1.5);

        float flowPos2 = fract(time * params.flowSpeed * 0.15 + 0.5);
        float flowDist2 = normalizedAngle - flowPos2;
        flowDist2 = abs(fract(flowDist2 + 0.5) - 0.5);
        float flowBright2 = smoothstep(0.08, 0.0, flowDist2);
        flowBright2 = pow(flowBright2, 1.5);

        flow = 1.0 + flowBright1 * params.flowIntensity * 1.5 + flowBright2 * params.flowIntensity * 0.7;
    }

    float3 primaryColor = params.color;
    float3 secondaryColor = params.secondaryColor;

    float colorMix = 0.0;
    if (params.colorBlend > 0.001) {
        colorMix = 0.5 + 0.5 * sin(normalizedAngle * 2.0 * M_PI_F + time * 0.3);
        colorMix *= params.colorBlend;
    }

    float3 neonColor = mix(primaryColor, secondaryColor, colorMix);

    float3 coreColor = neonColor;

    float coreBrightness = borderMask * 1.2;
    float3 brightCore = mix(neonColor, float3(1.0), 0.5);
    coreColor = mix(neonColor, brightCore, coreBrightness * 0.5);

    float3 glowColor = neonColor * (outerGlowMask * 0.8 + innerGlowMask * 0.8);

    float3 finalColor = coreColor * borderMask + glowColor;

    finalColor *= pulse * flicker * flow;

    finalColor *= params.intensity;

    float alpha = saturate(totalMask * params.intensity);

    finalColor = max(finalColor, float3(0.0));

    return float4(finalColor * alpha, alpha);
}
