/**
 * Glitch Shader Effect
 *
 * Created by Matthias Brandolin - 2025
 *
 * License: MIT
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

struct GlitchParameters {
    float intensity;
    float time;
    float chromaticAberration;
    float scanlineIntensity;
    float glitchFrequency;
    float blockSize;
    float grainIntensity;
    float vignetteStrength;
    float chromaticSpread;
};

float hash(float2 p) {
    float h = dot(p, float2(127.1, 311.7));
    return fract(sin(h) * 43758.5453123);
}

float2 hash2(float2 p) {
    float h1 = fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
    float h2 = fract(sin(dot(p, float2(269.5, 183.3))) * 43758.5453123);
    return float2(h1, h2);
}

float S(float a, float b, float t) {
    return smoothstep(a, b, t);
}

fragment float4 glitchFragment(VertexOut in [[stage_in]],
                               texture2d<float> inputTexture [[texture(0)]],
                               constant GlitchParameters &params [[buffer(0)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

    float2 resolution = float2(inputTexture.get_width(), inputTexture.get_height());
    float2 uv = in.texCoord;

    float2 V = 1.0 - 2.0 * uv;

    float cellSize = params.blockSize;
    float glitchRow = floor((uv.y * resolution.y) / cellSize);

    float updateRate = 2.0 + params.glitchFrequency * 2.0;
    float timeBlock = floor(params.time * updateRate);
    float rowHash = hash(float2(glitchRow, timeBlock));

    float glitchThreshold = 1.0 - (0.15 + params.glitchFrequency * 0.55);
    float glitchTrigger = step(glitchThreshold, rowHash);

    float offsetHash = hash(float2(glitchRow * 13.7, timeBlock * 7.3));
    float offsetDirection = (offsetHash > 0.5) ? 1.0 : -1.0;

    float offsetAmount = glitchTrigger * offsetDirection * params.intensity * params.chromaticAberration * 0.03;
    float2 offset = float2(offsetAmount, 0.0);

    float2 uvR = clamp(uv + offset * 2.0 * params.chromaticSpread, float2(0.0), float2(1.0));
    float2 uvG = clamp(uv + offset * 2.5 * params.chromaticSpread, float2(0.0), float2(1.0));
    float2 uvB = clamp(uv + offset * 3.0 * params.chromaticSpread, float2(0.0), float2(1.0));

    float r = inputTexture.sample(textureSampler, uvR).r;
    float g = inputTexture.sample(textureSampler, uvG).g;
    float b = inputTexture.sample(textureSampler, uvB).b;
    float a = inputTexture.sample(textureSampler, uv).a;

    float4 color = float4(r, g, b, a);

    float2 grainCoord = floor(params.time * 30.0) + V * float2(1462.439, 297.185);
    float2 grain = hash2(grainCoord);
    color.rgb += params.grainIntensity * grain.x * params.intensity;

    if (glitchTrigger > 0.5) {
        float colorCorrupt = hash(float2(glitchRow, timeBlock * 2.0));
        if (colorCorrupt > 0.8) {
            color.rg = color.gr;
        }
    }

    float vignetteStrength = 1.0 - params.vignetteStrength * params.intensity * S(0.1, 1.8, length(V * V));
    color.rgb *= vignetteStrength;

    float scanlinePos = fmod(uv.y * resolution.y, cellSize);
    float scanline = 0.3 + 0.7 * step(0.98, scanlinePos / cellSize);
    color.rgb *= mix(1.0, scanline, params.scanlineIntensity * params.intensity);

    float frameGlitch = hash(float2(timeBlock, 0.0));
    if (frameGlitch > 0.95 && params.glitchFrequency > 0.5) {
        color.r += 0.08 * sin(params.time * 50.0) * params.intensity;
        color.b += 0.08 * cos(params.time * 50.0) * params.intensity;
    }
    
    return color;
}
