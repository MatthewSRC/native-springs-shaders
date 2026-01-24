#version 300 es

/**
 * Liquid Metal Overlay Shader Effect
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
uniform vec3 baseColor;
uniform vec3 highlightColor;
uniform float flowSpeed;
uniform float repetition;
uniform float distortion;
uniform float chromaticAberration;
uniform vec2 flowOffset;
uniform float flowAngle;
uniform float specularIntensity;
uniform vec2 specularPosition;
uniform float specularSize;
uniform float roughness;

const float M_PI_F = 3.14159265359;
const float TWO_PI = 6.28318530718;

const float FRESNEL_F0 = 0.92;
const float ROUGH_UNIFORM_REFLECT = 0.7;
const float BAND_SHARP_MIN = 0.4;
const float BAND_SHARP_MAX = 3.0;
const float CONTRAST_POLISHED = 3.5;
const float CONTRAST_ROUGH = 1.3;
const float CONTRAST_CENTER_POLISHED = 0.48;
const float CONTRAST_CENTER_ROUGH = 0.45;
const float S_CURVE_POLISHED = 0.55;

const float BASE_DARKEN = 0.02;
const float HIGHLIGHT_BOOST = 1.2;
const float RIM_FALLOFF = 6.0;
const float SPEC_COLOR_BOOST = 1.5;

const vec3 FLOW_DARK = vec3(0.02, 0.02, 0.03);
const vec3 FLOW_BRIGHT = vec3(0.95, 0.96, 1.0);
const vec3 WARM_TINT = vec3(1.0, 0.9, 0.85);
const vec3 COOL_TINT = vec3(0.85, 0.92, 1.0);
const vec3 CHROMA_BLUE = vec3(0.2, 0.5, 1.0);
const vec3 CHROMA_ORANGE = vec3(1.0, 0.5, 0.2);
const vec3 SPEC_WARM_WHITE = vec3(1.0, 0.98, 0.95);

float hashLM(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noiseLM(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    return mix(mix(hashLM(i), hashLM(i + vec2(1, 0)), f.x),
               mix(hashLM(i + vec2(0, 1)), hashLM(i + vec2(1, 1)), f.x), f.y);
}

float flowingBand(vec2 coord, float bandFlowAngle, float bandTime, float frequency, float edgeFactor, float noiseInfluence, float sharpnessExp) {
    float c = cos(bandFlowAngle);
    float s = sin(bandFlowAngle);
    float flowPos = coord.x * c + coord.y * s;

    float noise = noiseLM(coord * 3.0 + bandTime * 0.05);
    flowPos += noise * noiseInfluence;
    flowPos += edgeFactor * noise * 0.2;
    flowPos -= bandTime * 0.08;

    float band = sin(flowPos * frequency * TWO_PI);
    band = sign(band) * pow(abs(band), sharpnessExp);

    return band * 0.5 + 0.5;
}

vec3 flowingReflections(vec2 uv, float reflTime, float borderDepth, float frequency, float reflDistortion, float chromatic, float reflFlowAngle, float roughness, float aspectRatio) {

    float sharpnessExp = mix(BAND_SHARP_MIN, BAND_SHARP_MAX, roughness);
    float effectiveChromatic = chromatic * (1.0 - roughness * 0.8);

    vec2 correctedUV = vec2(uv.x * aspectRatio, uv.y);

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

    float rBand = flowingBand(correctedUV + vec2(redOffset, redOffset * 0.5), reflFlowAngle, reflTime, frequency, edgeFactor, reflDistortion * 0.5, sharpnessExp);
    float gBand = combinedBand;
    float bBand = flowingBand(correctedUV + vec2(blueOffset, blueOffset * 0.5), reflFlowAngle, reflTime, frequency, edgeFactor, reflDistortion * 0.5, sharpnessExp);

    rBand = rBand * 0.6 + band2 * 0.4;
    bBand = bBand * 0.6 + band3 * 0.4;

    return vec3(rBand, gBand, bBand);
}

float roundedBoxSDF(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
    vec2 uv = vTexCoord;
    float localTime = time * flowSpeed * 0.3;
    float aspectRatio = viewSize.x / viewSize.y;

    vec2 pixelCoord = (uv - 0.5) * viewSize;
    vec2 halfSize = viewSize * 0.5;

    float radiusPx = min(cornerRadius, min(halfSize.x, halfSize.y) - borderWidth);
    radiusPx = max(radiusPx, 0.0);

    float outerDist = roundedBoxSDF(pixelCoord, halfSize, radiusPx);
    float innerRadiusPx = max(radiusPx - borderWidth, 0.0);
    vec2 innerHalfSize = halfSize - borderWidth;
    float innerDist = roundedBoxSDF(pixelCoord, innerHalfSize, innerRadiusPx);

    float outerMask = 1.0 - smoothstep(-1.0, 1.0, outerDist);
    float innerMask = smoothstep(-1.0, 1.0, innerDist);
    float borderMask = outerMask * innerMask;

    if (borderMask < 0.001) {
        fragColor = vec4(0.0);
        return;
    }

    float borderDepth = clamp(-outerDist / borderWidth, 0.0, 1.0);

    float pipeAngle = (borderDepth - 0.5) * M_PI_F;
    float pipeNormalY = cos(pipeAngle);

    float fresnelTerm = FRESNEL_F0 + (1.0 - FRESNEL_F0) * pow(1.0 - max(pipeNormalY, 0.0), 5.0);

    float baseReflect = mix(fresnelTerm, ROUGH_UNIFORM_REFLECT, roughness);

    vec3 darkBase = baseColor * BASE_DARKEN;
    vec3 peakWhite = highlightColor * HIGHLIGHT_BOOST;
    vec3 metalColor = darkBase;

    vec2 offsetUV = uv + flowOffset;
    vec3 flowBands = flowingReflections(offsetUV, localTime, borderDepth, repetition, distortion, chromaticAberration, flowAngle, roughness, aspectRatio);

    vec3 flowColor;
    flowColor.r = mix(FLOW_DARK.r, FLOW_BRIGHT.r, flowBands.r);
    flowColor.g = mix(FLOW_DARK.g, FLOW_BRIGHT.g, flowBands.g);
    flowColor.b = mix(FLOW_DARK.b, FLOW_BRIGHT.b, flowBands.b);

    float contrastMult = mix(CONTRAST_POLISHED, CONTRAST_ROUGH, roughness);
    float contrastCenter = mix(CONTRAST_CENTER_POLISHED, CONTRAST_CENTER_ROUGH, roughness);
    flowColor = clamp((flowColor - contrastCenter) * contrastMult + contrastCenter, 0.0, 1.0);

    flowColor *= (0.3 + 0.7 * baseReflect);

    float noiseVal = noiseLM(uv * 15.0 + localTime * 0.02);
    flowColor *= (0.9 + noiseVal * 0.2);

    metalColor = mix(darkBase, flowColor * baseColor, 0.9);

    float flowHighlight = max(max(flowBands.r, flowBands.g), flowBands.b);
    float flowPeak = smoothstep(0.8, 0.95, flowHighlight) * baseReflect;
    metalColor = mix(metalColor, peakWhite, flowPeak * chromaticAberration * 0.7);

    float colorBalance = (flowBands.r - flowBands.b) * 0.5 + 0.5;
    vec3 tint = mix(COOL_TINT, WARM_TINT, colorBalance);
    metalColor *= mix(vec3(1.0), tint, flowHighlight * 0.3 * chromaticAberration);

    float edgeChroma = smoothstep(0.3, 0.7, flowHighlight) * (1.0 - smoothstep(0.7, 0.95, flowHighlight));
    vec3 chromaColor = mix(CHROMA_BLUE, CHROMA_ORANGE, flowBands.r);
    metalColor += chromaColor * edgeChroma * baseReflect * chromaticAberration * 0.15;

    float edgeDark = smoothstep(0.0, 0.15, borderDepth) * smoothstep(1.0, 0.85, borderDepth);
    metalColor *= (0.85 + 0.15 * edgeDark);

    float outerRim = exp(-borderDepth * RIM_FALLOFF) * 0.1;
    metalColor += highlightColor * outerRim * baseReflect;

    if (specularIntensity > 0.001) {
        float effectiveSpecSize = specularSize * (1.0 + roughness * 3.0);
        float effectiveSpecIntensity = specularIntensity * (1.0 - roughness * 0.6);

        vec2 specUV = specularPosition * 0.5 + 0.5;
        vec2 toSpec = uv - specUV;
        toSpec.x *= aspectRatio;

        float specDist = length(toSpec);
        float specFalloff = 1.0 - smoothstep(0.0, effectiveSpecSize, specDist);
        float specSharpness = mix(2.0, 0.8, roughness);
        specFalloff = pow(specFalloff, specSharpness);

        float specStrength = specFalloff * effectiveSpecIntensity * borderMask;
        specStrength *= (0.3 + 0.7 * baseReflect);

        float shimmer = noiseLM(uv * 8.0 + localTime * 0.1) * 0.3 + 0.7;
        specStrength *= shimmer;

        vec3 specColor = highlightColor * SPEC_COLOR_BOOST;
        specColor = mix(specColor, SPEC_WARM_WHITE, 0.3);

        metalColor = mix(metalColor, specColor, clamp(specStrength, 0.0, 1.0));
    }

    vec3 sCurve = metalColor * metalColor * (3.0 - 2.0 * metalColor);
    float sCurveBlend = mix(S_CURVE_POLISHED, 0.0, roughness);
    metalColor = mix(metalColor, sCurve, sCurveBlend);

    metalColor = clamp(max(metalColor, darkBase * 0.3), 0.0, 1.0);

    float alpha = borderMask * intensity;
    fragColor = vec4(metalColor * alpha, alpha);
}
