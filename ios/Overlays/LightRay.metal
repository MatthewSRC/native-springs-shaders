/**
 * LightRay Overlay Shader Effect
 * 
 * Adapted from shader by ElusivePete: https://www.shadertoy.com/view/lljGDt
 * 
 * License: Not specified by original author
 * Commercial use may require permission from original author.
 */

#include <metal_stdlib>
#include "../Common.metal"
using namespace metal;

float rayStrength(
    float2 raySource,
    float2 rayRefDirection,
    float2 coord,
    float seedA,
    float seedB,
    float speed,
    float time,
    float maxDistance,
    float rayLength,
    float rayWidth
) {
    float2 sourceToCoord = coord - raySource;
    float distance = length(sourceToCoord);

    float lengthFalloff = smoothstep(maxDistance * rayLength, maxDistance * rayLength * 0.7, distance);

    float cosAngle = dot(normalize(sourceToCoord), rayRefDirection);

    float strength = clamp(
        (0.45 + 0.15 * rayWidth * sin(cosAngle * seedA + time * speed)) +
        (0.3 + 0.2 * cos(-cosAngle * seedB + time * speed)),
        0.0, 1.0);

    float distanceFactor = clamp(
        (maxDistance - distance) / maxDistance,
        0.5, 1.0
    );

    return strength * distanceFactor * lengthFalloff;
}

struct LightRayParameters {
    float time;
    float intensity;
    float2 viewSize;
    float2 rayPosition;
    float speed;
    float numRays;
    float depthAttenuation;
    float rayLength;
    float2 rayDirection;
    float rayWidth;
    float3 rayColor;
};

fragment float4 lightRayFragment(
    VertexOut in [[stage_in]],
    constant LightRayParameters &params [[buffer(0)]]
) {
    float time = params.time;
    float intensity = params.intensity;
    float2 viewSize = params.viewSize;
    float2 rayPosition = params.rayPosition;
    float3 rayColor = params.rayColor;
    float speed = params.speed;
    float numRays = params.numRays;
    float depthAttenuation = params.depthAttenuation;
    float rayLength = params.rayLength;
    float2 rayDirection = params.rayDirection;
    float rayWidth = params.rayWidth;
    float2 uv = in.texCoord;
    uv.y = 1.0 - uv.y;
    float2 coord = float2(uv.x * viewSize.x, (1.0 - uv.y) * viewSize.y);

    float maxDistance = sqrt(viewSize.x * viewSize.x + viewSize.y * viewSize.y);
    float2 baseRayDir = normalize(rayDirection);

    // Base ray position
    float2 baseRayPos = float2(viewSize.x * rayPosition.x, viewSize.y * rayPosition.y);

    // Accumulate all rays
    float totalStrength = 0.0;
    int numRaysInt = int(numRays);

    for (int i = 0; i < numRaysInt; i++) {
        // Vary position slightly for each ray
        float posOffset = float(i) * 0.05;
        float2 rayPos = baseRayPos + float2(viewSize.x * posOffset, -viewSize.y * posOffset * 0.5);

        // Rotate direction slightly for each ray to create spread
        float angleVariation = (float(i) / float(numRaysInt)) * 0.3 - 0.15;
        float cosAngle = cos(angleVariation);
        float sinAngle = sin(angleVariation);
        float2 rayDir = float2(
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
            rayWidth
        );

        // Weight rays - first ray is strongest, others fade
        float weight = (i == 0) ? 0.5 : (0.4 / float(numRaysInt - 1));
        totalStrength += rayContribution * weight;
    }

    float4 rays = float4(1.0, 1.0, 1.0, 1.0) * totalStrength;

    rays.rgb *= rayColor;

    if (depthAttenuation > 0.0) {
        float brightness = 1.0 - (coord.y / viewSize.y);
        rays.r *= 0.1 + (brightness * 0.8);
        rays.g *= 0.3 + (brightness * 0.6);
        rays.b *= 0.5 + (brightness * 0.5);
    }

    rays.rgb *= intensity;

    float alpha = clamp(length(rays.rgb), 0.0, 1.0);

    return float4(rays.rgb, alpha);
}
