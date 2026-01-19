#version 300 es

/**
 * Ripple Shader Effect
 *
 * Created by Matthias Brandolin - 2025
 *
 * License: MIT
 */
precision highp float;

uniform sampler2D u_Texture;
uniform float u_Intensity;
uniform float u_Time;
uniform vec2 u_TouchPoint;
uniform float u_TouchTime;
uniform float u_Frequency;
uniform float u_Damping;
uniform vec3 u_RippleColor;
uniform float u_RippleVariant;
uniform float u_Speed;
uniform float u_RingWidth;
uniform float u_SlowdownFactor;
uniform float u_DisplacementStrength;
uniform float u_HighlightStrength;
uniform vec2 u_Resolution;

in vec2 v_TexCoord;
out vec4 FragColor;

float calculateRealisticRipple(vec2 position, vec2 center, float time, float amplitude, float maxSpeed, float ringWidth, float damping, float slowdownFactor) {
    if (amplitude <= 0.0 || time <= 0.0) return 0.0;

    float distance = length(position - center);

    float currentRadius = maxSpeed * (1.0 - exp(-time * slowdownFactor)) / slowdownFactor;

    float distanceFromWave = abs(distance - currentRadius);
    if (distanceFromWave > ringWidth) return 0.0;

    float normalizedDistance = distanceFromWave / ringWidth;
    float wavePulse = exp(-normalizedDistance * normalizedDistance * 8.0);

    float timeFade = exp(-time * damping);
    float distanceFade = amplitude / (1.0 + distance / 150.0);

    return wavePulse * timeFade * distanceFade;
}

float calculateDefaultRipple(vec2 position, vec2 center, float time, float frequency, float damping, float speed) {
    if (time <= 0.0) return 0.0;

    float distance = length(position - center);

    float currentRadius = time * speed;

    float distanceFromWave = abs(distance - currentRadius);

    float wavePulse = exp(-distanceFromWave * frequency * 10.0);

    float timeFade = exp(-time * damping);
    float distanceFade = exp(-distance * damping * 2.0);

    return wavePulse * timeFade * distanceFade;
}

void main() {
    vec2 uv = v_TexCoord;

    float wave = 0.0;

    if (u_RippleVariant > 0.5) {
        vec2 pixelPos = uv * u_Resolution;
        vec2 centerPos = u_TouchPoint * u_Resolution;
        wave = calculateRealisticRipple(pixelPos, centerPos, u_TouchTime, u_Intensity, u_Speed, u_RingWidth, u_Damping, u_SlowdownFactor);
    } else {
        float aspect = u_Resolution.x / u_Resolution.y;
        vec2 aspectCorrection = vec2(aspect, 1.0);

        vec2 correctedUV = uv * aspectCorrection;
        vec2 correctedTouch = u_TouchPoint * aspectCorrection;
        wave = calculateDefaultRipple(correctedUV, correctedTouch, u_TouchTime, u_Frequency, u_Damping, u_Speed);
    }

    vec2 displacement = vec2(0.0);
    if (wave > 0.01) {
        vec2 direction = normalize(uv - u_TouchPoint);

        float displaceStrength = wave * u_Intensity * u_DisplacementStrength;
        displacement = direction * displaceStrength;
    }

    vec2 distortedUV = uv + displacement;

    distortedUV = clamp(distortedUV, vec2(0.0), vec2(1.0));

    vec4 color = texture(u_Texture, distortedUV);

    float highlight = wave * u_Intensity * u_HighlightStrength;
    color.rgb += u_RippleColor * highlight;

    FragColor = color;
}
