#version 300 es

/**
 * Glitch Shader Effect
 *
 * Created by Matthias Brandolin - 2025
 *
 * License: MIT
 */
precision highp float;

uniform sampler2D u_Texture;
uniform float u_Intensity;
uniform float u_Time;
uniform float u_ChromaticAberration;
uniform float u_ScanlineIntensity;
uniform float u_GlitchFrequency;
uniform float u_BlockSize;
uniform float u_GrainIntensity;
uniform float u_VignetteStrength;
uniform float u_ChromaticSpread;
uniform vec2 u_Resolution;

in vec2 v_TexCoord;
out vec4 FragColor;

float hash(vec2 p) {
    float h = dot(p, vec2(127.1, 311.7));
    return fract(sin(h) * 43758.5453123);
}

vec2 hash2(vec2 p) {
    float h1 = fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
    float h2 = fract(sin(dot(p, vec2(269.5, 183.3))) * 43758.5453123);
    return vec2(h1, h2);
}

void main() {
    vec2 uv = v_TexCoord;

    vec2 V = 1.0 - 2.0 * uv;

    float cellSize = u_BlockSize;
    float glitchRow = floor((uv.y * u_Resolution.y) / cellSize);

    float updateRate = 2.0 + u_GlitchFrequency * 2.0;
    float timeBlock = floor(u_Time * updateRate);
    float rowHash = hash(vec2(glitchRow, timeBlock));

    float glitchThreshold = 1.0 - (0.15 + u_GlitchFrequency * 0.55);
    float glitchTrigger = step(glitchThreshold, rowHash);

    float offsetHash = hash(vec2(glitchRow * 13.7, timeBlock * 7.3));
    float offsetDirection = (offsetHash > 0.5) ? 1.0 : -1.0;

    float offsetAmount = glitchTrigger * offsetDirection * u_Intensity * u_ChromaticAberration * 0.03;
    vec2 offset = vec2(offsetAmount, 0.0);

    vec2 uvR = clamp(uv + offset * 2.0 * u_ChromaticSpread, vec2(0.0), vec2(1.0));
    vec2 uvG = clamp(uv + offset * 2.5 * u_ChromaticSpread, vec2(0.0), vec2(1.0));
    vec2 uvB = clamp(uv + offset * 3.0 * u_ChromaticSpread, vec2(0.0), vec2(1.0));

    float r = texture(u_Texture, uvR).r;
    float g = texture(u_Texture, uvG).g;
    float b = texture(u_Texture, uvB).b;
    float a = texture(u_Texture, uv).a;

    vec4 color = vec4(r, g, b, a);

    vec2 grainCoord = floor(u_Time * 30.0) + V * vec2(1462.439, 297.185);
    vec2 grain = hash2(grainCoord);
    color.rgb += u_GrainIntensity * grain.x * u_Intensity;

    if (glitchTrigger > 0.5) {
        float colorCorrupt = hash(vec2(glitchRow, timeBlock * 2.0));
        if (colorCorrupt > 0.8) {
            color.rg = color.gr;
        }
    }

    float vignetteStrength = 1.0 - u_VignetteStrength * u_Intensity * smoothstep(0.1, 1.8, length(V * V));
    color.rgb *= vignetteStrength;

    float scanlinePos = mod(uv.y * u_Resolution.y, cellSize);
    float scanline = 0.3 + 0.7 * step(0.98, scanlinePos / cellSize);
    color.rgb *= mix(1.0, scanline, u_ScanlineIntensity * u_Intensity);

    float frameGlitch = hash(vec2(timeBlock, 0.0));
    if (frameGlitch > 0.95 && u_GlitchFrequency > 0.5) {
        color.r += 0.08 * sin(u_Time * 50.0) * u_Intensity;
        color.b += 0.08 * cos(u_Time * 50.0) * u_Intensity;
    }

    FragColor = color;
}
