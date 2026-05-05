/**
 * Clouds Overlay Shader Effect
 *
 * Creates soft, blurry gradient blobs for ambient backgrounds.
 * Designed for use behind blurred cards and frosted glass UI elements.
 *
 * Created by Matthias Brandolin - 2026
 *
 * License: MIT
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

struct CloudsParameters {
    float time;
    float intensity;
    float2 viewSize;
    float3 color;
    float3 secondaryColor;
    float3 tertiaryColor;
    float scale;
    float speed;
    float softness;
    float blobCount;
};


float blob(float2 uv, float2 center, float radius, float soft) {
    float2 diff = uv - center;
    float d2 = dot(diff, diff);
    float falloff = radius * (0.3 + soft * 0.7);
    return exp(-d2 / (2.0 * falloff * falloff));
}

fragment float4 cloudsFragment(
    VertexOut in [[stage_in]],
    constant CloudsParameters &params [[buffer(0)]]
) {
    float2 uv = in.texCoord;
    float time = params.time * params.speed;

    float aspect = params.viewSize.x / params.viewSize.y;
    float2 p = float2((uv.x - 0.5) * aspect, uv.y - 0.5);

    float baseRadius = params.scale * 0.3;
    float soft = params.softness;
    int count = clamp(int(params.blobCount), 1, 5);

    float3 colorSum = float3(0.0);
    float weightSum = 0.0;

    if (count >= 1) {
        float2 c1 = float2(
            sin(time * 0.23 + 1.0) * 0.25 - 0.15,
            cos(time * 0.19 + 2.0) * 0.2 + 0.05
        );
        float b1 = blob(p, c1, baseRadius * 1.2, soft);
        colorSum += params.color * b1;
        weightSum += b1;
    }

    if (count >= 2) {
        float2 c2 = float2(
            cos(time * 0.17 + 4.0) * 0.3 + 0.2,
            sin(time * 0.21 + 0.5) * 0.25 - 0.1
        );
        float b2 = blob(p, c2, baseRadius * 1.0, soft);
        colorSum += params.secondaryColor * b2;
        weightSum += b2;
    }

    if (count >= 3) {
        float2 c3 = float2(
            sin(time * 0.15 + 3.5) * 0.2 + 0.0,
            cos(time * 0.25 + 5.0) * 0.3 - 0.15
        );
        float b3 = blob(p, c3, baseRadius * 0.9, soft);
        colorSum += params.tertiaryColor * b3;
        weightSum += b3;
    }

    if (count >= 4) {
        float2 c4 = float2(
            cos(time * 0.13 + 6.0) * 0.35 - 0.1,
            sin(time * 0.18 + 1.5) * 0.2 + 0.2
        );
        float b4 = blob(p, c4, baseRadius * 0.8, soft);
        float3 mixColor = mix(params.color, params.secondaryColor, 0.5);
        colorSum += mixColor * b4;
        weightSum += b4;
    }

    if (count >= 5) {
        float2 c5 = float2(
            sin(time * 0.2 + 8.0) * 0.25 + 0.15,
            cos(time * 0.14 + 3.0) * 0.25 + 0.1
        );
        float b5 = blob(p, c5, baseRadius * 0.7, soft);
        float3 mixColor = mix(params.secondaryColor, params.tertiaryColor, 0.5);
        colorSum += mixColor * b5;
        weightSum += b5;
    }

    float alpha = saturate(weightSum * params.intensity);

    if (alpha < 0.001) {
        return float4(0.0);
    }

    float3 col = colorSum / max(weightSum, 0.001);

    return float4(col * alpha, alpha);
}
