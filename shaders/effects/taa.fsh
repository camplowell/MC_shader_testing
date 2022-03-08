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

// Uniforms --------------------------------------------------------------------------------------

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D colortex8;
uniform sampler2D colortex9;

uniform sampler2D depthtex0;

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

void sampleCurrent(out vec3 velocity, out float depthMin, out float depth, out float depthMax);

vec3 clipAndMix(sampler2D tex, ivec2 texel, vec3 col_p, float alpha);

// ===============================================================================================
// Main
// ===============================================================================================

/* RENDERTARGETS: 8,9 */

void main() {
    vec3 color_c = texture2D(colortex0, texcoord + counterJitter).rgb;
    vec2 frameSize = vec2(viewWidth, viewHeight);

    vec3 velocity;
    float depthMin;
    float depth;
    float depthMax;
    sampleCurrent(velocity, depthMin, depth, depthMax);

    float depth_l = linearizeDepth(depth);
    float depthErr_n = linearizeDepth(depthMin) - depth_l;
    float depthErr_p = linearizeDepth(depthMax) - depth_l;

    vec3 screenPos_p = vec3(texcoord, depth) + velocity;

    float depth_plx = linearizeDepth(screenPos_p.z);
    float depth_pl = texture2D(colortex8, screenPos_p.xy, 0).x;
    float depthErr = depth_pl - depth_plx;

    float alpha_d = 1 - 16 * max(depthErr_n - depthErr, depthErr - depthErr_p);

    float alpha = depthMin < 1.0 ? clamp(alpha_d, 0.0, 0.9) : 0.0;
    if (any(bvec4(
        lessThan(screenPos_p.xy, vec2(0)), 
        greaterThan(screenPos_p.xy, vec2(1))
    ))) {
        alpha = 0.0;
    }
    //alpha /= 0.1 * max(0, depth_plx - depth_l) + 1;
    
    vec3 color_p = resample_bspline(colortex9, screenPos_p.xy);

    color_p = clipAndMix(colortex0, ivec2(texcoord * frameSize), color_p, alpha);

    gl_FragData[0] = vec4(vec3(depth_l), 1.0);
    gl_FragData[1] = vec4(color_p, 1.0);
    //gl_FragData[1] = vec4(vec3(alpha), 1.0);
}

// ===============================================================================================
// Helper implementations
// ===============================================================================================

void sampleCurrent(out vec3 velocity, out float depthMin, out float depth, out float depthMax) {
    ivec2 pos = ivec2(texcoord * vec2(viewWidth, viewHeight));
    
    depth = texelFetch(depthtex0, pos + offsets[0], 0).x;
    float d1 = texelFetch(depthtex0, pos + offsets[1], 0).x;
    float d2 = texelFetch(depthtex0, pos + offsets[2], 0).x;
    float d3 = texelFetch(depthtex0, pos + offsets[3], 0).x;
    float d4 = texelFetch(depthtex0, pos + offsets[4], 0).x;
    float d5 = texelFetch(depthtex0, pos + offsets[5], 0).x;
    float d6 = texelFetch(depthtex0, pos + offsets[6], 0).x;
    float d7 = texelFetch(depthtex0, pos + offsets[7], 0).x;
    float d8 = texelFetch(depthtex0, pos + offsets[8], 0).x;

    depthMin = min(min(min(min(d1, d2), min(d3, d4)), min(min(d5, d6), min(d7, d8))), depth);
    depthMax = max(max(max(max(d1, d2), max(d3, d4)), max(max(d5, d6), max(d7, d8))), depth);

    ivec2 offset = depthMin == depth ? offsets[0]
        : depthMin == d1 ? offsets[1]
        : depthMin == d2 ? offsets[2]
        : depthMin == d3 ? offsets[3]
        : depthMin == d4 ? offsets[4]
        : depthMin == d5 ? offsets[5]
        : depthMin == d6 ? offsets[6]
        : depthMin == d7 ? offsets[7]
        : offsets[8];
    
    velocity = texelFetch(colortex3, pos + offset, 0).xyz;
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

vec3 clipAndMix(sampler2D tex, ivec2 texel, vec3 col_p, float alpha) {
    vec3 col = texelFetch(tex, texel, 0).rgb;
    vec2 tex_s = textureSize(tex, 0);
    vec3 c0 = texture2D(tex, (texel + vec2( 1, 1)) / tex_s).rgb;
    vec3 c1 = texture2D(tex, (texel + vec2(-1, 1)) / tex_s).rgb;
    vec3 c2 = texture2D(tex, (texel + vec2( 1,-1)) / tex_s).rgb;
    vec3 c3 = texture2D(tex, (texel + vec2(-1,-1)) / tex_s).rgb;
    vec3 c_min = min(min(c0, c1), min(c2, c3));
    vec3 c_max = max(max(c0, c1), max(c2, c3));
    col_p = clip_aabb(c_min, c_max, col_p);
    col_p = mix(col, col_p, alpha);
    return col_p;
}
