/**
 * Liquid Metal Overlay Shader Effect
 *
 * Created by Matthias Brandolin - 2026
 *
 * License: MIT
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

constant float kFresnelF0 = 0.92;
constant float kRoughUniformReflect = 0.7;
constant float kBandSharpMin = 0.4;
constant float kBandSharpMax = 3.0;
constant float kContrastPolished = 3.5;
constant float kContrastRough = 1.3;
constant float kContrastCenterPolished = 0.48;
constant float kContrastCenterRough = 0.45;
constant float kSCurvePolished = 0.55;

constant float kBaseDarken = 0.02;
constant float kHighlightBoost = 1.2;
constant float kRimFalloff = 6.0;
constant float kSpecColorBoost = 1.5;

constant float3 kFlowDark = float3(0.02, 0.02, 0.03);
constant float3 kFlowBright = float3(0.95, 0.96, 1.0);
constant float3 kWarmTint = float3(1.0, 0.9, 0.85);
constant float3 kCoolTint = float3(0.85, 0.92, 1.0);
constant float3 kChromaBlue = float3(0.2, 0.5, 1.0);
constant float3 kChromaOrange = float3(1.0, 0.5, 0.2);
constant float3 kSpecWarmWhite = float3(1.0, 0.98, 0.95);

struct LiquidMetalParameters {
    float time;
    float intensity;
    float2 viewSize;
    float borderWidth;
    float cornerRadius;
    float3 baseColor;
    float3 highlightColor;
    float flowSpeed;
    float repetition;
    float distortion;
    float chromaticAberration;
    float2 flowOffset;
    float flowAngle;
    float specularIntensity;
    float2 specularPosition;
    float specularSize;
    float roughness;
};

float hashLM(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float noiseLM(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    return mix(mix(hashLM(i), hashLM(i + float2(1, 0)), f.x),
               mix(hashLM(i + float2(0, 1)), hashLM(i + float2(1, 1)), f.x), f.y);
}

float flowingBand(float2 coord, float bandFlowAngle, float bandTime, float frequency, float edgeFactor, float noiseInfluence, float sharpnessExp) {
    float c = cos(bandFlowAngle);
    float s = sin(bandFlowAngle);
    float flowPos = coord.x * c + coord.y * s;

    float noise = noiseLM(coord * 3.0 + bandTime * 0.05);
    flowPos += noise * noiseInfluence;
    flowPos += edgeFactor * noise * 0.2;
    flowPos -= bandTime * 0.08;

    float band = sin(flowPos * frequency * 6.28318530718);
    band = sign(band) * pow(abs(band), sharpnessExp);

    return band * 0.5 + 0.5;
}

float3 flowingReflections(float2 uv, float reflTime, float borderDepth, float frequency, float reflDistortion, float chromatic, float reflFlowAngle, float roughness, float aspectRatio) {

    float sharpnessExp = mix(kBandSharpMin, kBandSharpMax, roughness);
    float effectiveChromatic = chromatic * (1.0 - roughness * 0.8);

    float2 correctedUV = float2(uv.x * aspectRatio, uv.y);

    float edgeFactor = smoothstep(0.0, 0.5, borderDepth) * smoothstep(1.0, 0.5, borderDepth);
    edgeFactor = 1.0 - edgeFactor;

    float baseNoise = noiseLM(correctedUV * 2.5 + reflTime * 0.02);

    float band1 = flowingBand(correctedUV, reflFlowAngle, reflTime, frequency, edgeFactor, reflDistortion * 0.5, sharpnessExp);
    float band2 = flowingBand(correctedUV * 1.2, reflFlowAngle + 0.15, reflTime * 0.85, frequency * 0.8, edgeFactor, reflDistortion * 0.4, sharpnessExp);
    float band3 = flowingBand(correctedUV * 0.9, reflFlowAngle - 0.1, reflTime * 1.1, frequency * 1.3, edgeFactor, reflDistortion * 0.3, sharpnessExp);

    float combinedBand = band1 * 0.5 + band2 * 0.3 + band3 * 0.2;
    combinedBand += (baseNoise - 0.5) * 0.15 * reflDistortion;

    float redOffset = effectiveChromatic * 0.03 * (1.0 - baseNoise);
    float blueOffset = -effectiveChromatic * 0.025 * (0.5 + baseNoise * 0.5);

    float rBand = flowingBand(correctedUV + float2(redOffset, redOffset * 0.5), reflFlowAngle, reflTime, frequency, edgeFactor, reflDistortion * 0.5, sharpnessExp);
    float gBand = combinedBand;
    float bBand = flowingBand(correctedUV + float2(blueOffset, blueOffset * 0.5), reflFlowAngle, reflTime, frequency, edgeFactor, reflDistortion * 0.5, sharpnessExp);

    rBand = rBand * 0.6 + band2 * 0.4;
    bBand = bBand * 0.6 + band3 * 0.4;

    return float3(rBand, gBand, bBand);
}

float roundedBoxSDF(float2 p, float2 halfSize, float r) {
    float2 q = abs(p) - halfSize + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

fragment float4 liquidMetalFragment(
    VertexOut in [[stage_in]],
    constant LiquidMetalParameters &params [[buffer(0)]]
) {
    float2 uv = in.texCoord;
    float time = params.time * params.flowSpeed * 0.3;
    float aspectRatio = params.viewSize.x / params.viewSize.y;

    float2 pixelCoord = (uv - 0.5) * params.viewSize;
    float2 halfSize = params.viewSize * 0.5;

    float radiusPx = min(params.cornerRadius, min(halfSize.x, halfSize.y) - params.borderWidth);
    radiusPx = max(radiusPx, 0.0);

    float outerDist = roundedBoxSDF(pixelCoord, halfSize, radiusPx);
    float innerRadiusPx = max(radiusPx - params.borderWidth, 0.0);
    float2 innerHalfSize = halfSize - params.borderWidth;
    float innerDist = roundedBoxSDF(pixelCoord, innerHalfSize, innerRadiusPx);

    float outerMask = 1.0 - smoothstep(-1.0, 1.0, outerDist);
    float innerMask = smoothstep(-1.0, 1.0, innerDist);
    float borderMask = outerMask * innerMask;

    if (borderMask < 0.001) {
        return float4(0.0);
    }

    float borderDepth = saturate(-outerDist / params.borderWidth);

    float pipeAngle = (borderDepth - 0.5) * M_PI_F;
    float pipeNormalY = cos(pipeAngle);

    float fresnelTerm = kFresnelF0 + (1.0 - kFresnelF0) * pow(1.0 - max(pipeNormalY, 0.0), 5.0);

    float baseReflect = mix(fresnelTerm, kRoughUniformReflect, params.roughness);

    float3 darkBase = params.baseColor * kBaseDarken;
    float3 peakWhite = params.highlightColor * kHighlightBoost;
    float3 metalColor = darkBase;

    float2 offsetUV = uv + params.flowOffset;
    float3 flowBands = flowingReflections(offsetUV, time, borderDepth, params.repetition, params.distortion, params.chromaticAberration, params.flowAngle, params.roughness, aspectRatio);

    float3 flowColor;
    flowColor.r = mix(kFlowDark.r, kFlowBright.r, flowBands.r);
    flowColor.g = mix(kFlowDark.g, kFlowBright.g, flowBands.g);
    flowColor.b = mix(kFlowDark.b, kFlowBright.b, flowBands.b);

    float contrastMult = mix(kContrastPolished, kContrastRough, params.roughness);
    float contrastCenter = mix(kContrastCenterPolished, kContrastCenterRough, params.roughness);
    flowColor = saturate((flowColor - contrastCenter) * contrastMult + contrastCenter);

    flowColor *= (0.3 + 0.7 * baseReflect);

    float noiseVal = noiseLM(uv * 15.0 + time * 0.02);
    flowColor *= (0.9 + noiseVal * 0.2);

    metalColor = mix(darkBase, flowColor * params.baseColor, 0.9);

    float flowHighlight = max(max(flowBands.r, flowBands.g), flowBands.b);
    float flowPeak = smoothstep(0.8, 0.95, flowHighlight) * baseReflect;
    metalColor = mix(metalColor, peakWhite, flowPeak * params.chromaticAberration * 0.7);

    float colorBalance = (flowBands.r - flowBands.b) * 0.5 + 0.5;
    float3 tint = mix(kCoolTint, kWarmTint, colorBalance);
    metalColor *= mix(float3(1.0), tint, flowHighlight * 0.3 * params.chromaticAberration);

    float edgeChroma = smoothstep(0.3, 0.7, flowHighlight) * (1.0 - smoothstep(0.7, 0.95, flowHighlight));
    float3 chromaColor = mix(kChromaBlue, kChromaOrange, flowBands.r);
    metalColor += chromaColor * edgeChroma * baseReflect * params.chromaticAberration * 0.15;

    float edgeDark = smoothstep(0.0, 0.15, borderDepth) * smoothstep(1.0, 0.85, borderDepth);
    metalColor *= (0.85 + 0.15 * edgeDark);

    float outerRim = exp(-borderDepth * kRimFalloff) * 0.1;
    metalColor += params.highlightColor * outerRim * baseReflect;

    if (params.specularIntensity > 0.001) {
        float effectiveSpecSize = params.specularSize * (1.0 + params.roughness * 3.0);
        float effectiveSpecIntensity = params.specularIntensity * (1.0 - params.roughness * 0.6);

        float2 specUV = params.specularPosition * 0.5 + 0.5;
        float2 toSpec = uv - specUV;
        toSpec.x *= aspectRatio;

        float specDist = length(toSpec);
        float specFalloff = 1.0 - smoothstep(0.0, effectiveSpecSize, specDist);
        float specSharpness = mix(2.0, 0.8, params.roughness);
        specFalloff = pow(specFalloff, specSharpness);

        float specStrength = specFalloff * effectiveSpecIntensity * borderMask;
        specStrength *= (0.3 + 0.7 * baseReflect);

        float shimmer = noiseLM(uv * 8.0 + time * 0.1) * 0.3 + 0.7;
        specStrength *= shimmer;

        float3 specColor = params.highlightColor * kSpecColorBoost;
        specColor = mix(specColor, kSpecWarmWhite, 0.3);

        metalColor = mix(metalColor, specColor, saturate(specStrength));
    }

    float3 sCurve = metalColor * metalColor * (3.0 - 2.0 * metalColor);
    float sCurveBlend = mix(kSCurvePolished, 0.0, params.roughness);
    metalColor = mix(metalColor, sCurve, sCurveBlend);

    metalColor = saturate(max(metalColor, darkBase * 0.3));

    float alpha = borderMask * params.intensity;
    return float4(metalColor * alpha, alpha);
}
