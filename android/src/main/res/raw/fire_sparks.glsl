#version 300 es

/**
 * FireSparks Overlay Shader Effect
 *
 * Adapted from shader by Jan Mróz (jaszunio15): https://www.shadertoy.com/view/wl2Gzc
 * Adapted by Matthias Brandolin - 2025
 *
 * License: MIT
 */
precision highp float;

in vec2 vTexCoord;

out vec4 fragColor;

uniform float time;
uniform float intensity;
uniform vec2 viewSize;
uniform vec2 movementDirection;
uniform float travelDistance;
uniform vec3 sparkColor;
uniform float particleSize;
uniform float animationSpeed;
uniform float u_SmokeIntensity;
uniform float u_ParticleBloom;
uniform float u_MovementSpeed;

#define PARTICLE_SCALE (vec2(0.5, 1.6))
#define PARTICLE_SCALE_VAR (vec2(0.25, 0.2))

#define PARTICLE_BLOOM_SCALE (vec2(0.5, 0.8))
#define PARTICLE_BLOOM_SCALE_VAR (vec2(0.3, 0.1))

#define SIZE_MOD 1.05
#define ALPHA_MOD 0.9
#define LAYERS_COUNT 15
float hash1_2(vec2 x) {
    return fract(sin(dot(x, vec2(52.127, 61.2871))) * 521.582);
}

vec2 hash2_2(vec2 x) {
    return fract(sin(x * mat2(20.52, 24.1994, 70.291, 80.171)) * 492.194);
}

float noise1_2(vec2 uv) {
    vec2 f = fract(uv);

    vec2 uv00 = floor(uv);
    vec2 uv01 = uv00 + vec2(0, 1);
    vec2 uv10 = uv00 + vec2(1, 0);
    vec2 uv11 = uv00 + 1.0;

    float v00 = hash1_2(uv00);
    float v01 = hash1_2(uv01);
    float v10 = hash1_2(uv10);
    float v11 = hash1_2(uv11);

    float v0 = mix(v00, v01, f.y);
    float v1 = mix(v10, v11, f.y);
    float v = mix(v0, v1, f.x);

    return v;
}

vec2 noise2_2(vec2 uv) {
    vec2 f = smoothstep(0.0, 1.0, fract(uv));

    vec2 uv00 = floor(uv);
    vec2 uv01 = uv00 + vec2(0, 1);
    vec2 uv10 = uv00 + vec2(1, 0);
    vec2 uv11 = uv00 + 1.0;
    vec2 v00 = hash2_2(uv00);
    vec2 v01 = hash2_2(uv01);
    vec2 v10 = hash2_2(uv10);
    vec2 v11 = hash2_2(uv11);

    vec2 v0 = mix(v00, v01, f.y);
    vec2 v1 = mix(v10, v11, f.y);
    vec2 v = mix(v0, v1, f.x);

    return v;
}

float layeredNoise1_2(vec2 uv, float sizeMod, float alphaMod, int layers, float animation, float time, vec2 movementDirection, float movementSpeed) {
    float noise = 0.0;
    float alpha = 1.0;
    float size = 1.0;
    vec2 offset = vec2(0.0);

    for (int i = 0; i < layers; i++) {
        offset += hash2_2(vec2(alpha, size)) * 10.0;

        noise += noise1_2(uv * size - time * animation * 8.0 * movementDirection * movementSpeed + offset) * alpha;
        alpha *= alphaMod;
        size *= sizeMod;
    }

    noise *= (1.0 - alphaMod) / (1.0 - pow(alphaMod, float(layers)));
    return noise;
}

vec2 rotate(vec2 point, float deg) {
    float s = sin(deg);
    float c = cos(deg);
    return mat2(s, c, -c, s) * point;
}

vec2 voronoiPointFromRoot(vec2 root, float deg) {
    vec2 point = hash2_2(root) - 0.5;
    float s = sin(deg);
    float c = cos(deg);
    point = mat2(s, c, -c, s) * point * 0.66;
    point += root + 0.5;
    return point;
}

float degFromRootUV(vec2 uv, float time, float animSpeed) {
    return time * animSpeed * (hash1_2(uv) - 0.5) * 2.0;
}

vec2 randomAround2_2(vec2 point, vec2 range, vec2 uv) {
    return point + (hash2_2(uv) - 0.5) * range;
}

vec3 fireParticles(vec2 uv, vec2 originalUV, float time, vec2 movementDirection, float travelDistance, vec3 sparkColor, float pSize, float animSpeed) {
    vec3 particles = vec3(0.0);
    vec2 rootUV = floor(uv);
    float deg = degFromRootUV(rootUV, time, animSpeed);
    vec2 pointUV = voronoiPointFromRoot(rootUV, deg);
    float dist = 2.0;
    float distBloom = 0.0;

    vec2 tempUV = uv + (noise2_2(uv * 2.0) - 0.5) * 0.1;
    tempUV += -(noise2_2(uv * 3.0 + time) - 0.5) * 0.07;

    dist = length(rotate(tempUV - pointUV, 0.7) * randomAround2_2(PARTICLE_SCALE, PARTICLE_SCALE_VAR, rootUV));

    distBloom = length(rotate(tempUV - pointUV, 0.7) * randomAround2_2(PARTICLE_BLOOM_SCALE, PARTICLE_BLOOM_SCALE_VAR, rootUV));

    particles += (1.0 - smoothstep(pSize * 0.6, pSize * 3.0, dist)) * (sparkColor * 1.5);

    particles += pow((1.0 - smoothstep(0.0, pSize * 6.0, distBloom)) * u_ParticleBloom, 3.0) * (sparkColor * 0.8);

    vec2 normDir = normalize(movementDirection);
    float posAlongDirection = dot(originalUV, normDir);

    float maxRange = 1.8;
    float fadeStart = -maxRange * travelDistance;
    float fadeEnd = maxRange * travelDistance;

    float border = (hash1_2(rootUV) - 0.5) * 2.0;
    float fadeOut = smoothstep(fadeStart + border, fadeEnd + border, posAlongDirection);

    return particles * (1.0 - fadeOut);
}

vec3 layeredParticles(vec2 uv, float sizeMod, float alphaMod, int layers, float smoke, float time, vec2 movementDirection, float travelDistance, vec3 sparkColor, float pSize, float animSpeed, float movementSpeed) {
    vec3 particles = vec3(0);
    float size = 1.0;
    float alpha = 1.0;
    vec2 offset = vec2(0.0);
    vec2 noiseOffset;
    vec2 bokehUV;

    for (int i = 0; i < layers; i++) {
        noiseOffset = (noise2_2(uv * size * 2.0 + 0.5) - 0.5) * 0.15;

        bokehUV = (uv * size - time * movementDirection * movementSpeed) + offset + noiseOffset;

        particles += fireParticles(bokehUV, uv, time, movementDirection, travelDistance, sparkColor, pSize, animSpeed) * alpha * (1.0 - smoothstep(0.0, 1.0, smoke) * (float(i) / float(layers)));

        offset += hash2_2(vec2(alpha, alpha)) * 10.0;

        alpha *= alphaMod;
        size *= sizeMod;
    }

    return particles;
}

void main() {
    vec2 texCoord = vec2(vTexCoord.x, 1.0 - vTexCoord.y);

    vec2 fragCoord = texCoord * viewSize;
    float minDim = min(viewSize.x, viewSize.y);
    vec2 uv = (2.0 * fragCoord - viewSize) / minDim;

    uv *= 1.8;

    vec2 normDir = normalize(movementDirection);

    float smokeIntensity = layeredNoise1_2(uv * 10.0 - time * 4.0 * movementDirection * u_MovementSpeed, 1.7, 0.7, 6, 0.2, time, movementDirection, u_MovementSpeed);

    float posAlongDirection = dot(uv, normDir);
    smokeIntensity *= pow(1.0 - smoothstep(-1.8, 1.8, posAlongDirection), 2.0);

    vec3 smokeBaseColor = sparkColor * vec3(1.0, 1.075, 1.25);
    vec3 smoke = smokeIntensity * smokeBaseColor * u_SmokeIntensity;

    smoke *= pow(layeredNoise1_2(uv * 4.0 - time * 0.5 * movementDirection * u_MovementSpeed, 1.8, 0.5, 3, 0.2, time, movementDirection, u_MovementSpeed), 2.0) * 1.5;

    vec3 particles = layeredParticles(uv, SIZE_MOD, ALPHA_MOD, LAYERS_COUNT, smokeIntensity, time, movementDirection, travelDistance, sparkColor, particleSize, animationSpeed, u_MovementSpeed);

    vec3 col = particles + smoke + smokeBaseColor * 0.02;

    col = smoothstep(-0.08, 1.0, col);

    float alpha = clamp(length(col) * intensity, 0.0, 1.0);

    fragColor = vec4(col * intensity, alpha);
}
