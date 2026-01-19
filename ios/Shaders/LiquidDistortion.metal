/**
 * LiquidDistortion Shader Effect
 *
 * Created by Matthias Brandolin - 2025
 *
 * License: MIT
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

struct LiquidDistortionParameters {
    float intensity;
    float speed;
    float waveScale;
    float time;
    float turbulence;
    float chromaticAberration;
    float liquidVariant;
    float shineStrength;
    float colorTintStrength;
    float padding;
    float2 flowDirection;
    float3 liquidColor;
};

float hash(float2 p) {
    float h = dot(p, float2(127.1, 311.7));
    return fract(sin(h) * 43758.5453123);
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);

    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(float2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

float2 liquidDisplacement(float2 uv, float time, float waveScale, float turbulence, float2 flowDir) {
    float2 normalizedFlow = normalize(flowDir);

    float2 p1 = uv * waveScale + normalizedFlow * time * 0.3;
    float2 p2 = uv * waveScale * 1.3 + normalizedFlow * time * 0.25;
    float2 p3 = uv * waveScale * 0.7 - normalizedFlow * time * 0.2;

    float n1 = fbm(p1);
    float n2 = fbm(p2);
    float n3 = fbm(p3);

    float2 displacement;
    displacement.x = (n1 - 0.5) * 2.0 + (n2 - 0.5) * 1.5;
    displacement.y = (n2 - 0.5) * 2.0 + (n3 - 0.5) * 1.5;

    displacement *= turbulence;

    float2 center = float2(0.5, 0.5);
    float2 toCenter = uv - center;
    float dist = length(toCenter);
    float angle = atan2(toCenter.y, toCenter.x);

    float radialWave = sin(dist * 10.0 - time * 2.0) * 0.2;
    displacement += float2(cos(angle), sin(angle)) * radialWave * turbulence;

    return displacement;
}

float3 hsv2rgb(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float4 renderLiquid(float2 fragCoord, float2 resolution,
                    texture2d<float> inputTexture,
                    constant LiquidDistortionParameters &params) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear, address::clamp_to_edge);

    float2 uv = fragCoord / resolution;

    float2 displacement = liquidDisplacement(uv, params.time * params.speed, params.waveScale, params.turbulence, params.flowDirection);

    float2 distortedUV = uv + displacement * params.intensity * 0.05;

    float4 color = inputTexture.sample(textureSampler, distortedUV);

    float aberrationStrength = params.intensity * params.chromaticAberration * 0.01;
    float4 colorR = inputTexture.sample(textureSampler, distortedUV + float2(aberrationStrength, 0.0));
    float4 colorB = inputTexture.sample(textureSampler, distortedUV - float2(aberrationStrength, 0.0));

    color.r = colorR.r;
    color.b = colorB.b;

    int variant = int(params.liquidVariant);

    if (variant == 0) {
        float displacementMag = length(displacement);
        float shine = smoothstep(0.8, 1.2, displacementMag) * params.intensity * params.shineStrength;
        color.rgb += float3(shine);

        color.rgb = mix(color.rgb, color.rgb * params.liquidColor, params.intensity * params.colorTintStrength);

    } else if (variant == 1) {
        float displacementMag = length(displacement);
        float shine = smoothstep(0.9, 1.1, displacementMag) * params.intensity * params.shineStrength;
        color.rgb += float3(shine);

        color.rgb = mix(color.rgb, color.rgb * params.liquidColor, params.intensity * params.colorTintStrength);

    } else if (variant == 2) {
        float displacementMag = length(displacement);
        float2 displacementDir = normalize(displacement);

        float hue = atan2(displacementDir.y, displacementDir.x) / (2.0 * 3.14159) + 0.5;
        hue += params.time * 0.1;
        hue = fract(hue);

        float3 iridescence = hsv2rgb(float3(hue, 0.8, 1.0));

        float iridescenceStrength = smoothstep(0.3, 0.8, displacementMag) * params.intensity * 0.3;
        color.rgb = mix(color.rgb, color.rgb * iridescence, iridescenceStrength);
    }

    return color;
}

fragment float4 liquidDistortionFragment(
    VertexOut in [[stage_in]],
    texture2d<float> inputTexture [[texture(0)]],
    constant LiquidDistortionParameters &params [[buffer(0)]]
) {
    float2 resolution = float2(inputTexture.get_width(), inputTexture.get_height());
    float2 fragCoord = in.texCoord * resolution;

    const int AA = 2;
    float4 sum = float4(0.0);

    for (int i = 0; i < AA; i++) {
        for (int j = 0; j < AA; j++) {
            float2 offset = float2(float(i), float(j)) / float(AA);
            sum += renderLiquid(fragCoord + offset, resolution, inputTexture, params);
        }
    }

    float4 finalColor = sum / float(AA * AA);

    float4 originalColor = inputTexture.sample(sampler(mag_filter::linear, min_filter::linear), in.texCoord);
    finalColor.a = originalColor.a;

    return finalColor;
}
