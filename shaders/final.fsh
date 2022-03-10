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
#version 410 compatibility

#define COMPOSITE
#define FRAGMENT

// ===============================================================================================
// Global variables
// ===============================================================================================

// Inputs and outputs ----------------------------------------------------------------------------

in  vec2 texcoord;

// Uniforms --------------------------------------------------------------------------------------

uniform sampler2D colortex9;

// Other global variables ------------------------------------------------------------------------

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/lib/common.glsl"
#include "/lib/resampling.glsl"

// ===============================================================================================
// Helper declarations
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

/* 
const int colortex0Format = RGB8;
const int colortex3Format = RGB16F;
const int colortex8Format = R32F;
const bool colortex8Clear = false;
const int colortex9Format = RGB16;
const bool colortex9Clear = false;
*/

// Make the preprocessor warning go away
#if !defined MC_RENDER_QUALITY
#define MC_RENDER_QUALITY 1.0
#endif

void main() {
    if (MC_RENDER_QUALITY == 1.0) {
        ivec2 texel = ivec2(texcoord * vec2(viewWidth, viewHeight));
        gl_FragData[0] = texelFetch(colortex9, texel, 0);
    } else {
#if RESAMPLING_QUALITY == 0
        gl_FragData[0] = texture2D(colortex9, texcoord);
#else
        gl_FragData[0] = vec4(resample_bspline(colortex9, texcoord), 1.0);
#endif
    }
}

// ===============================================================================================
// Helper implementations
// ===============================================================================================
