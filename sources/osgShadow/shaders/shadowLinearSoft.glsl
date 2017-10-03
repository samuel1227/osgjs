#pragma include "floatFromTex.glsl"

// simulation of texture2Dshadow glsl call on HW
// http://codeflow.org/entries/2013/feb/15/soft-shadow-mapping/
float texture2DCompare(const in sampler2D depths,
                       const in vec2 uv,
                       const in float compare,
                       const in vec4 clampDimension){
    float depth = getSingleFloatFromTex(depths, clamp(uv, clampDimension.xy, clampDimension.zw));
    return compare - depth;
}

#ifdef _JITTER_OFFSET

#define INT_SCALE3_JITTER vec3(.1031, .1030, .0973)
#define _randJitter(_p) _p += dot(_p, _p.yzx + 19.19); return fract((_p.xxy + _p.yzz) * _p.zyx);
vec3 randJitter(vec2 p2) { vec3 p3  = fract(vec3(p2.xyx) * INT_SCALE3_JITTER); _randJitter(p3) }

#endif //_JITTER_OFFSET

// simulates linear fetch like texture2d shadow
float texture2DShadowLerp(
    const in sampler2D depths,
    const in vec4 size,
    const in vec2 uv,
    const in float compare,
    const in vec4 clampDimension
    OPT_ARG_DECLARATION_outDistance
    OPT_ARG_DECLARATION_jitter){

    vec2 f = fract(uv * size.xy + 0.5);
    vec2 centroidCoord = uv * size.xy + 0.5;
    vec2 centroidUV = floor(uv * size.xy + 0.5) * size.zw;

#ifdef _JITTER_OFFSET
    centroidUV += jitter * (size.zw *((randJitter(centroidCoord.xy + gl_FragCoord.xy).xy) - 0.5) * 0.5);
#endif //_JITTER_OFFSET

    const vec2 shift  = vec2(1.0, 0.0);

    vec4 fetches;
    fetches.x = texture2DCompare(depths, centroidUV + size.zw * shift.yy, compare, clampDimension);
    fetches.y = texture2DCompare(depths, centroidUV + size.zw * shift.yx, compare, clampDimension);
    fetches.z = texture2DCompare(depths, centroidUV + size.zw * shift.xy, compare, clampDimension);
    fetches.w = texture2DCompare(depths, centroidUV + size.zw * shift.xx, compare, clampDimension);

#ifdef _OUT_DISTANCE
    float _a = mix(fetches.x, fetches.y, f.y);
    float _b = mix(fetches.z, fetches.w, f.y);
    outDistance = mix(_a, _b, f.x);
#endif

    vec4 st = step(fetches, vec4(0.0));

    float a = mix(st.x, st.y, f.y);
    float b = mix(st.z, st.w, f.y);
    return mix(a, b, f.x);
}
