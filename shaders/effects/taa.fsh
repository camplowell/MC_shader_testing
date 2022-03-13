/*
MIT License

Copyright (c) 2022 Lowell Camp

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
*/

#define GBUFFER
#define FRAGMENT

// ===============================================================================================
// Global variables
// ===============================================================================================

// Inputs and outputs ----------------------------------------------------------------------------

in  vec2 texcoord;
in  vec2 counterJitter;

in  mat2 cornerDepths;

// Uniforms --------------------------------------------------------------------------------------

uniform sampler2D colortex0; // Color

uniform sampler2D colortex3; // Velocity
uniform sampler2D depthtex0; // Depth

uniform sampler2D colortex8; // Depth history
uniform sampler2D colortex9; // Color history

// Other global variables ------------------------------------------------------------------------

const ivec2 offsets[9] = ivec2[9](ivec2( 0, 0),
    ivec2( 1, 0), ivec2(-1, 0), ivec2( 0, 1), ivec2( 0,-1),
    ivec2( 1, 1), ivec2(-1, 1), ivec2( 1,-1), ivec2(-1,-1));

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/lib/common.glsl"
#include "/lib/resampling.glsl"

// ===============================================================================================
// Helper declarations
// ===============================================================================================
#if TAA_QUALITY != 0
void sampleCurrent(vec2 pos, out vec3 velocity, out float depthMin, out float depth, out float depthMax);

float getWeight(vec2 pos, vec2 prevPos, float depthMin, float depth, float depth_l, float depthMax, float depth_expected);

vec3 getTAA(sampler2D src, sampler2D hist, vec2 pos, vec2 historyPos, float weight);
#endif
// ===============================================================================================
// Main
// ===============================================================================================

/* RENDERTARGETS: 8,9 */

#if TAA_QUALITY == 0

void main() {
    gl_FragData[1] = texture2D(colortex0, texcoord);
}

#else

void main() {
    vec2 pos = texcoord + counterJitter;
    //vec2 pos_col = ;
    vec3 velocity;
    float depthMin;
    float depth;
    float depthMax;
    sampleCurrent(pos, velocity, depthMin, depth, depthMax);

    float depth_l = linearizeDepth(depth);
    vec2 prevPos = texcoord + velocity.xy;
    float depth_expected = depth + velocity.z;
    float weight = getWeight(pos, prevPos, depthMin, depth, depth_l, depthMax, depth_expected);

    vec3 color_p = getTAA(colortex0, colortex9, pos, prevPos, weight);
    
    gl_FragData[0] = vec4(vec3(depth_l), 1.0);
    gl_FragData[1] = vec4(color_p, 1.0);
    //gl_FragData[1] = vec4(vec3(weight), 1.0);
    //gl_FragData[1] = texture2D(colortex3, pos) + 0.5;
    //gl_FragData[1] = vec4(velocity, 1.0);
}

// ===============================================================================================
// Helper implementations
// ===============================================================================================

void sampleCurrent(vec2 pos, out vec3 velocity, out float depthMin, out float depth, out float depthMax) {
    vec2 tex_s = vec2(viewWidth, viewHeight);
    ivec2 pos_i = ivec2(pos * tex_s);

    depth = texelFetch(depthtex0, pos_i + offsets[0], 0).x;
    
#if TAA_QUALITY == 3
    // Solid 3x3 neighborhood
    float d1 = texelFetch(depthtex0, pos_i + offsets[1], 0).x;
    float d2 = texelFetch(depthtex0, pos_i + offsets[2], 0).x;
    float d3 = texelFetch(depthtex0, pos_i + offsets[3], 0).x;
    float d4 = texelFetch(depthtex0, pos_i + offsets[4], 0).x;
    float d5 = texelFetch(depthtex0, pos_i + offsets[5], 0).x;
    float d6 = texelFetch(depthtex0, pos_i + offsets[6], 0).x;
    float d7 = texelFetch(depthtex0, pos_i + offsets[7], 0).x;
    float d8 = texelFetch(depthtex0, pos_i + offsets[8], 0).x;

    depthMin = min(min(min(min(d1, d2), min(d3, d4)), min(min(d5, d6), min(d7, d8))), depth);
    depthMax = max(max(max(max(d1, d2), max(d3, d4)), max(max(d5, d6), max(d7, d8))), depth);
#else
    // X-shaped depth neighborhood
    float d5 = texelFetch(depthtex0, pos_i + offsets[5], 0).x;
    float d6 = texelFetch(depthtex0, pos_i + offsets[6], 0).x;
    float d7 = texelFetch(depthtex0, pos_i + offsets[7], 0).x;
    float d8 = texelFetch(depthtex0, pos_i + offsets[8], 0).x;

    depthMin = min(min(d5, d6), min(d7, d8));
    depthMax = max(max(d5, d6), max(d7, d8));
#endif

#if TAA_QUALITY == 1
    // Avoid interdependent texture samples
    ivec2 offset = ivec2(0.0);
#elif TAA_QUALITY == 2
    // Use the velocity of closest neighbor
    ivec2 offset = depthMin == depth ? offsets[0]
        : depthMin == d5 ? offsets[5]
        : depthMin == d6 ? offsets[6]
        : depthMin == d7 ? offsets[7]
        : offsets[8];
#elif TAA_QUALITY == 3
    // Use the velocity of closest neighbor
    ivec2 offset = depthMin == depth ? offsets[0]
        : depthMin == d1 ? offsets[1]
        : depthMin == d2 ? offsets[2]
        : depthMin == d3 ? offsets[3]
        : depthMin == d4 ? offsets[4]
        : depthMin == d5 ? offsets[5]
        : depthMin == d6 ? offsets[6]
        : depthMin == d7 ? offsets[7]
        : offsets[8];
#endif
        
    velocity = texelFetch(colortex3, pos_i + offset, 0).xyz;
}

float getWeight(vec2 pos, vec2 prevPos, float depthMin, float depth, float depth_l, float depthMax, float depth_expected) {
    
    // Bounds based rejection
    
    if (prevPos.x < 0 || prevPos.y < 0 || prevPos.x > 1 || prevPos.y > 1) {
        return 0.0;
    }
    float weight = 0.9;

    // Depth-based rejection
    float depthErr_min = linearizeDepth(depthMin) - depth_l;
    float depthErr_max = linearizeDepth(depthMax) - depth_l;
    float depth_pl = texture2D(colortex8, prevPos).x;
    float depthErr = depth_pl - linearizeDepth(depth_expected);
    weight *= clamp(1 - max(depthErr_min - depthErr, depthErr - depthErr_max), 0, 1);
    
    // Reprojection confidence
    vec2 pixelErr2 = abs(fract(prevPos * vec2(viewWidth, viewHeight)) - 0.5);
    float pixelErr = max(pixelErr2.x, pixelErr2.y);
    weight *= 2.0 / (2.0 + pixelErr);
    
    return weight;
}

vec3 clip_aabb(vec3 aabb_min, vec3 aabb_max, vec3 q) {
    vec3 p_clip = 0.5 * (aabb_max + aabb_min);
    vec3 e_clip = 0.5 * (aabb_max - aabb_min);
    vec3 v_clip = q - p_clip;
    vec3 v_unit = v_clip.xyz / e_clip;
    vec3 a_unit = abs(v_unit);
    float ma_unit = max(a_unit.x, max(a_unit.y, a_unit.z));
    
    if (ma_unit > 1.0) {
        return p_clip + v_clip / ma_unit;
    } else {
        return q;
    }
}

vec3 getTAA(sampler2D src, sampler2D hist, vec2 pos, vec2 historyPos, float weight) {
    vec2 texel = pos * vec2(viewWidth, viewHeight);
    vec3 col = texture2D(src, pos).rgb;
    vec2 src_s = textureSize(src, 0);
    vec3 c0 = texture2D(src, (texel + vec2( 1, 1)) / src_s).rgb;
    vec3 c1 = texture2D(src, (texel + vec2(-1, 1)) / src_s).rgb;
    vec3 c2 = texture2D(src, (texel + vec2( 1,-1)) / src_s).rgb;
    vec3 c3 = texture2D(src, (texel + vec2(-1,-1)) / src_s).rgb;
    vec3 c_min = min(min(c0, c1), min(c2, c3));
    vec3 c_max = max(max(c0, c1), max(c2, c3));
#if TAA_QUALITY == 1
    vec3 col_p = texture2D(hist, historyPos).rgb;
#else
    vec3 col_p = resample_bspline(hist, historyPos);
#endif
    col_p = clip_aabb(c_min, c_max, col_p);
    col_p = mix(col, col_p, weight);
    return col_p;
}

#endif
