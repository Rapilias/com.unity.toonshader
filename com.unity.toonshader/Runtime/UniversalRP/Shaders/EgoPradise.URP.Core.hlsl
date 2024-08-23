#ifndef EGOPARADISE_URP_CORE_INCLUDED
#define EGOPARADISE_URP_CORE_INCLUDED

// 4x4ディザリング
float Dither4x4float(float4 positionCS)
{
    float2 pixel = positionCS.xy / _DitherScale;
    float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    uint index = (uint(pixel.x) % 4) * 4 + uint(pixel.y) % 4;
    return DITHER_THRESHOLDS[index];
}

float CreateDitherInputByCameraDistance(float4 positionWS)
{
    float cameraDistance = distance(positionWS.xyz, _WorldSpaceCameraPos.xyz);
    // 0 < _DitherNearCutoutDistance < この間でディザリング < _DitherNearFadeStartDistance
    float min = _DitherNearCutoutDistance;
    float minToMaxDistance = _DitherNearFadeStartDistance - _DitherNearCutoutDistance;
    float ditherInput = saturate((cameraDistance - min) / minToMaxDistance * _DitherPower);
    return ditherInput;
}

float TryDitherClip(float4 positionWS, float4 positionCS)
{
    float alpha = CreateDitherInputByCameraDistance(positionWS);
    float ditherOutput = Dither4x4float(positionCS);
    float dither = alpha - (1.0f - ditherOutput);
    if(dither <= 0)
    {
        discard;
    }
    return dither;
}

#endif
