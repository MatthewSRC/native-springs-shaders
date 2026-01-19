/**
 * Aurora Overlay Shader Effect
 * 
 * Adapted from shader by mr_vero: https://www.shadertoy.com/view/433GD7
 * Which is based on code by Ian McEwan, Ashima Arts.
 * 
 * License: Not specified by original author
 * Commercial use may require permission from original author.
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

float3 mod289_3(float3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 mod289_4(float4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permute(float4 x) {
    return mod289_4(((x * 34.0) + 1.0) * x);
}

float4 taylorInvSqrt(float4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(float3 v) {
    const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);
    const float4 D = float4(0.0, 0.5, 1.0, 2.0);

    float3 i = floor(v + dot(v, C.yyy));
    float3 x0 = v - i + dot(i, C.xxx);

    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 i1 = min(g.xyz, l.zxy);
    float3 i2 = max(g.xyz, l.zxy);

    float3 x1 = x0 - i1 + 1.0 * C.xxx;
    float3 x2 = x0 - i2 + 2.0 * C.xxx;
    float3 x3 = x0 - 1.0 + 3.0 * C.xxx;

    i = mod289_3(i);
    float4 p = permute(permute(permute(
                   i.z + float4(0.0, i1.z, i2.z, 1.0))
               + i.y + float4(0.0, i1.y, i2.y, 1.0))
               + i.x + float4(0.0, i1.x, i2.x, 1.0));

    float n_ = 1.0 / 7.0;
    float3 ns = n_ * D.wyz - D.xzx;

    float4 j = p - 49.0 * floor(p * ns.z * ns.z);

    float4 x_ = floor(j * ns.z);
    float4 y_ = floor(j - 7.0 * x_);

    float4 x = x_ * ns.x + ns.yyyy;
    float4 y = y_ * ns.x + ns.yyyy;
    float4 h = 1.0 - abs(x) - abs(y);

    float4 b0 = float4(x.xy, y.xy);
    float4 b1 = float4(x.zw, y.zw);

    float4 s0 = floor(b0) * 2.0 + 1.0;
    float4 s1 = floor(b1) * 2.0 + 1.0;
    float4 sh = -step(h, float4(0.0));

    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    float3 p0 = float3(a0.xy, h.x);
    float3 p1 = float3(a0.zw, h.y);
    float3 p2 = float3(a1.xy, h.z);
    float3 p3 = float3(a1.zw, h.w);

    float4 norm = taylorInvSqrt(float4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    return 45.0 * dot(m * m, float4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

struct AuroraParameters {
    float time;
    float intensity;
    float2 viewSize;
    float2 movementDirection;
    float borderFade;
    float3 colorTint;
};

fragment float4 auroraFragment(
    VertexOut in [[stage_in]],
    constant AuroraParameters &params [[buffer(0)]]
) {
    float time = params.time;
    float intensity = params.intensity;
    float2 viewSize = params.viewSize;
    float2 movementDirection = params.movementDirection;
    float3 colorTint = params.colorTint;
    float borderFade = params.borderFade;
    float2 uv = in.texCoord;

    float2 aspectUV = uv;
    aspectUV.y *= viewSize.y / viewSize.x;

    float animTime = time * 0.5;

    float2 noiseUV = aspectUV - movementDirection * animTime * 0.1;

    float noise = snoise(float3(noiseUV * 3.0, animTime));

    float2 normDir = normalize(movementDirection);
    bool isVertical = abs(normDir.y) > abs(normDir.x);

    float edgeDistance;
    if (isVertical) {
        if (normDir.y < 0.0) {
            edgeDistance = uv.y;
        } else {
            edgeDistance = 1.0 - uv.y;
        }
    } else {
        if (normDir.x < 0.0) {
            edgeDistance = 1.0 - uv.x;
        } else {
            edgeDistance = uv.x;
        }
    }

    float auroraIntensity = pow(edgeDistance, 2.0) * 1.5 * (0.5 + 0.5 * noise);

    float3 baseGradient = mix(float3(0.4, 0.4, 0.4), float3(0.8, 0.8, 0.8), edgeDistance * 1.5 + noise * 0.3);

    float3 auroraColor = baseGradient * colorTint;

    auroraColor *= auroraIntensity;

    auroraColor *= intensity;

    float edgeFade = 1.0;
    if (borderFade > 0.0) {
        float edgeFadeWidth = 0.05;
        float fadeX = smoothstep(0.0, edgeFadeWidth, uv.x) * smoothstep(1.0, 1.0 - edgeFadeWidth, uv.x);
        float fadeY = smoothstep(0.0, edgeFadeWidth, uv.y) * smoothstep(1.0, 1.0 - edgeFadeWidth, uv.y);
        edgeFade = mix(1.0, fadeX * fadeY, borderFade);
    }
    float alpha = clamp(length(auroraColor), 0.0, 1.0) * edgeFade;

    return float4(auroraColor, alpha);
}
