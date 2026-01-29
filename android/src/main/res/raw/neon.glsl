#version 300 es

/**
 * Neon Overlay Shader Effect
 *
 * Creates an animated neon glow border effect that encapsulates content.
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
uniform float borderWidth;
uniform float cornerRadius;
uniform vec3 color;
uniform vec3 secondaryColor;
uniform float glowSize;
uniform float glowFalloff;
uniform float flowSpeed;
uniform float flowIntensity;
uniform float pulseSpeed;
uniform float pulseIntensity;
uniform float flickerIntensity;
uniform float colorBlend;
uniform float inset;

const float M_PI_F = 3.14159265359;

float hashNeon(float n) {
    return fract(sin(n) * 43758.5453);
}

float noiseNeon(float t) {
    float fl = floor(t);
    float fc = fract(t);
    return mix(hashNeon(fl), hashNeon(fl + 1.0), fc);
}

float roundedBoxSDFNeon(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
    vec2 uv = vTexCoord;
    float localTime = time;

    vec2 pixelCoord = (uv - 0.5) * viewSize;
    vec2 halfSize = viewSize * 0.5 - inset;

    float radiusPx = min(cornerRadius, min(halfSize.x, halfSize.y) - borderWidth);
    radiusPx = max(radiusPx, 0.0);

    float outerDist = roundedBoxSDFNeon(pixelCoord, halfSize, radiusPx);

    float innerRadius = max(radiusPx - borderWidth, 0.0);
    vec2 innerHalfSize = halfSize - borderWidth;
    float innerDist = roundedBoxSDFNeon(pixelCoord, innerHalfSize, innerRadius);

    float borderMask = smoothstep(1.0, -1.0, outerDist) * smoothstep(-1.0, 1.0, innerDist);

    float glowPixels = glowSize * borderWidth;

    float outerGlowMask = 0.0;
    if (outerDist > 0.0) {
        outerGlowMask = exp(-outerDist / glowPixels * glowFalloff);
    }

    float innerGlowMask = 0.0;
    if (innerDist < 0.0) {
        innerGlowMask = exp(innerDist / glowPixels * glowFalloff);
    }

    float totalMask = borderMask + outerGlowMask * 0.6 + innerGlowMask * 0.6;

    if (totalMask < 0.001) {
        fragColor = vec4(0.0);
        return;
    }

    float pulse = 1.0;
    if (pulseIntensity > 0.001) {
        pulse = 1.0 - pulseIntensity * 0.4 * (0.5 + 0.5 * sin(localTime * pulseSpeed * 3.0));
    }

    float flicker = 1.0;
    if (flickerIntensity > 0.001) {
        float flickerNoise = noiseNeon(localTime * 25.0) * noiseNeon(localTime * 37.0 + 50.0);
        flicker = 1.0 - flickerIntensity * 0.2 * (1.0 - flickerNoise);
    }

    vec2 centeredUV = uv - 0.5;
    float angle = atan(centeredUV.y * viewSize.y, centeredUV.x * viewSize.x);
    float normalizedAngle = (angle + M_PI_F) / (2.0 * M_PI_F);

    float flow = 1.0;
    if (flowIntensity > 0.001 && flowSpeed > 0.001) {
        float flowPos1 = fract(localTime * flowSpeed * 0.15);
        float flowDist1 = normalizedAngle - flowPos1;
        flowDist1 = abs(fract(flowDist1 + 0.5) - 0.5);
        float flowBright1 = smoothstep(0.12, 0.0, flowDist1);
        flowBright1 = pow(flowBright1, 1.5);

        float flowPos2 = fract(localTime * flowSpeed * 0.15 + 0.5);
        float flowDist2 = normalizedAngle - flowPos2;
        flowDist2 = abs(fract(flowDist2 + 0.5) - 0.5);
        float flowBright2 = smoothstep(0.08, 0.0, flowDist2);
        flowBright2 = pow(flowBright2, 1.5);

        flow = 1.0 + flowBright1 * flowIntensity * 1.5 + flowBright2 * flowIntensity * 0.7;
    }

    vec3 primaryColor = color;
    vec3 secColor = secondaryColor;

    float colorMix = 0.0;
    if (colorBlend > 0.001) {
        colorMix = 0.5 + 0.5 * sin(normalizedAngle * 2.0 * M_PI_F + localTime * 0.3);
        colorMix *= colorBlend;
    }

    vec3 neonColor = mix(primaryColor, secColor, colorMix);

    vec3 coreColor = neonColor;

    float coreBrightness = borderMask * 1.2;
    vec3 brightCore = mix(neonColor, vec3(1.0), 0.5);
    coreColor = mix(neonColor, brightCore, coreBrightness * 0.5);

    vec3 glowColor = neonColor * (outerGlowMask * 0.8 + innerGlowMask * 0.8);

    vec3 finalColor = coreColor * borderMask + glowColor;

    finalColor *= pulse * flicker * flow;

    finalColor *= intensity;

    float alpha = clamp(totalMask * intensity, 0.0, 1.0);

    finalColor = max(finalColor, vec3(0.0));

    fragColor = vec4(finalColor * alpha, alpha);
}
