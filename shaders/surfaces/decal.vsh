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
#define VERTEX

// ===============================================================================================
// Global variables
// ===============================================================================================

// Inputs and outputs ----------------------------------------------------------------------------

out vec2 texcoord;
out vec4 glcolor;
out float ao;

// Uniforms --------------------------------------------------------------------------------------

// Other global variables ------------------------------------------------------------------------

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/lib/common.glsl"
#include "/lib/taa_jitter.glsl"

// ===============================================================================================
// Helper declarations
// ===============================================================================================

vec3 getViewPos();
vec4 getGlColor();
float getAo();

// ===============================================================================================
// Main
// ===============================================================================================

void main() {
    vec3 viewPos = getViewPos();
    gl_Position = jitter(view2clip(viewPos));

    texcoord = getTexCoord();
    glcolor = getGlColor();
    ao = getAo();
}

// ===============================================================================================
// Helper implementations
// ===============================================================================================
