#version 300 es

/**
 * LightRay Overlay Shader Effect
 *
 * Adapted from shader by ElusivePete: https://www.shadertoy.com/view/lljGDt
 *
 * License: Not specified by original author
 * Commercial use may require permission from original author.
 */
precision highp float;

in vec2 vTexCoord;

out vec4 fragColor;

uniform float time;
uniform float intensity;
uniform vec2 viewSize;
uniform vec2 rayPosition;
uniform vec3 rayColor;
uniform float speed;
uniform float numRays;
uniform float depthAttenuation;
uniform float rayLength;
uniform vec2 u_RayDirection;
uniform float u_RayWidth;
float rayStrength(
    vec2 raySource,
    vec2 rayRefDirection,
    vec2 coord,
    float seedA,
    float seedB,
    float raySpeed,
    float currentTime,
    float maxDistance,
    float rayLen,
    float rayWidth
) {
    vec2 sourceToCoord = coord - raySource;
    float distance = length(sourceToCoord);

    float lengthFalloff = smoothstep(maxDistance * rayLen, maxDistance * rayLen * 0.7, distance);

    float cosAngle = dot(normalize(sourceToCoord), rayRefDirection);

    float strength = clamp(
        (0.45 + 0.15 * rayWidth * sin(cosAngle * seedA + currentTime * raySpeed)) +
        (0.3 + 0.2 * cos(-cosAngle * seedB + currentTime * raySpeed)),
        0.0, 1.0);

    float distanceFactor = clamp(
        (maxDistance - distance) / maxDistance,
        0.5, 1.0
    );

    return strength * distanceFactor * lengthFalloff;
}

void main() {
    vec2 uv = vTexCoord;
    uv.y = 1.0 - uv.y;
    vec2 coord = vec2(uv.x * viewSize.x, (1.0 - uv.y) * viewSize.y);

    float maxDistance = sqrt(viewSize.x * viewSize.x + viewSize.y * viewSize.y);
    vec2 baseRayDir = normalize(u_RayDirection);

    // Base ray position
    vec2 baseRayPos = vec2(viewSize.x * rayPosition.x, viewSize.y * rayPosition.y);

    // Accumulate all rays
    float totalStrength = 0.0;
    int numRaysInt = int(numRays);

    for (int i = 0; i < numRaysInt; i++) {
        // Vary position slightly for each ray
        float posOffset = float(i) * 0.05;
        vec2 rayPos = baseRayPos + vec2(viewSize.x * posOffset, -viewSize.y * posOffset * 0.5);

        // Rotate direction slightly for each ray to create spread
        float angleVariation = (float(i) / float(numRaysInt)) * 0.3 - 0.15;
        float cosAngle = cos(angleVariation);
        float sinAngle = sin(angleVariation);
        vec2 rayDir = vec2(
            baseRayDir.x * cosAngle - baseRayDir.y * sinAngle,
            baseRayDir.x * sinAngle + baseRayDir.y * cosAngle
        );

        // Vary seeds for each ray
        float raySeedA = 36.2214 + float(i) * 7.31;
        float raySeedB = 21.11349 + float(i) * 5.89;
        float raySpeed = speed * (0.8 + float(i) * 0.1);

        float rayContribution = rayStrength(
            rayPos,
            normalize(rayDir),
            coord,
            raySeedA,
            raySeedB,
            raySpeed,
            time,
            maxDistance,
            rayLength,
            u_RayWidth
        );

        // Weight rays - first ray is strongest, others fade
        float weight = (i == 0) ? 0.5 : (0.4 / float(numRaysInt - 1));
        totalStrength += rayContribution * weight;
    }

    vec4 rays = vec4(1.0, 1.0, 1.0, 1.0) * totalStrength;

    rays.rgb *= rayColor;

    if (depthAttenuation > 0.0) {
        float brightness = 1.0 - (coord.y / viewSize.y);
        rays.r *= 0.1 + (brightness * 0.8);
        rays.g *= 0.3 + (brightness * 0.6);
        rays.b *= 0.5 + (brightness * 0.5);
    }

    rays.rgb *= intensity;

    float alpha = clamp(length(rays.rgb), 0.0, 1.0);

    fragColor = vec4(rays.rgb, alpha);
}
