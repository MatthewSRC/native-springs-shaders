#version 300 es

/**
 * LiquidDistortion Shader Effect
 *
 * Created by Matthias Brandolin - 2025
 *
 * License: MIT
 */
precision highp float;

in vec2 v_TexCoord;
out vec4 FragColor;

uniform sampler2D u_InputTexture;
uniform float u_Intensity;
uniform float u_Speed;
uniform float u_WaveScale;
uniform float u_Time;
uniform float u_Turbulence;
uniform float u_ChromaticAberration;
uniform float u_LiquidVariant;
uniform vec2 u_FlowDirection;
uniform vec3 u_LiquidColor;
uniform float u_ShineStrength;
uniform float u_ColorTintStrength;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
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

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 liquidDisplacement(vec2 uv, float time, float waveScale, float turbulence, vec2 flowDir) {
    vec2 normalizedFlow = normalize(flowDir);

    vec2 p1 = uv * waveScale + normalizedFlow * time * 0.3;
    float n1 = fbm(p1);

    vec2 p2 = uv * waveScale * 1.3 + normalizedFlow * time * 0.25;
    float n2 = fbm(p2);

    vec2 p3 = uv * waveScale * 0.7 - normalizedFlow * time * 0.2;
    float n3 = fbm(p3);

    vec2 displacement = vec2(
        (n1 - 0.5) * 2.0 + (n2 - 0.5) * 1.5,
        (n2 - 0.5) * 2.0 + (n3 - 0.5) * 1.5
    );

    displacement *= turbulence;

    vec2 center = vec2(0.5, 0.5);
    vec2 toCenter = uv - center;
    float dist = length(toCenter);
    float angle = atan(toCenter.y, toCenter.x);

    float radialWave = sin(dist * 10.0 - time * 2.0) * 0.2;
    displacement += vec2(cos(angle), sin(angle)) * radialWave * turbulence;

    return displacement;
}

void main() {
    vec2 uv = v_TexCoord;
    float adjustedTime = u_Time * u_Speed;

    vec2 displacement = liquidDisplacement(uv, adjustedTime, u_WaveScale, u_Turbulence, u_FlowDirection);

    vec2 distortedUV = uv + displacement * u_Intensity * 0.05;

    vec4 color = texture(u_InputTexture, clamp(distortedUV, 0.0, 1.0));

    float aberration = u_Intensity * u_ChromaticAberration * 0.01;
    vec2 uvR = clamp(distortedUV + vec2(aberration, 0.0), 0.0, 1.0);
    vec2 uvB = clamp(distortedUV - vec2(aberration, 0.0), 0.0, 1.0);

    color.r = texture(u_InputTexture, uvR).r;
    color.b = texture(u_InputTexture, uvB).b;

    int variant = int(u_LiquidVariant);

    if (variant == 0) {
        float displacementMag = length(displacement);
        float shine = smoothstep(0.8, 1.2, displacementMag) * u_Intensity * u_ShineStrength;
        color.rgb += vec3(shine);

        color.rgb = mix(color.rgb, color.rgb * u_LiquidColor, u_Intensity * u_ColorTintStrength);

    } else if (variant == 1) {
        float displacementMag = length(displacement);
        float shine = smoothstep(0.9, 1.1, displacementMag) * u_Intensity * u_ShineStrength;
        color.rgb += vec3(shine);

        color.rgb = mix(color.rgb, color.rgb * u_LiquidColor, u_Intensity * u_ColorTintStrength);

    } else if (variant == 2) {
        float displacementMag = length(displacement);
        vec2 displacementDir = normalize(displacement + vec2(0.001));

        float hue = atan(displacementDir.y, displacementDir.x) / (2.0 * 3.14159) + 0.5;
        hue += adjustedTime * 0.1;
        hue = fract(hue);

        vec3 iridescence = hsv2rgb(vec3(hue, 0.8, 1.0));

        float iridescenceStrength = smoothstep(0.3, 0.8, displacementMag) * u_Intensity * 0.3;
        color.rgb = mix(color.rgb, color.rgb * iridescence, iridescenceStrength);
    }

    FragColor = color;
}
