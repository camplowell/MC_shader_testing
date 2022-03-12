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

#include "/lib/common.glsl"

// ===============================================================================================
// Global variables
// ===============================================================================================

// Inputs and outputs ----------------------------------------------------------------------------

out vec2 texcoord;
out vec2 counterJitter;

#ifdef PANINI_ENABLE
out vec2 bl;
out vec2 br;
out vec2 tl;
out vec2 tr;
out mat2 cornerDepths;
#endif

// Uniforms --------------------------------------------------------------------------------------

// Other global variables ------------------------------------------------------------------------

// ===============================================================================================
// Imports
// ===============================================================================================


#include "/lib/taa_jitter.glsl"
#include "/lib/panini_projection.glsl"

// ===============================================================================================
// Helper declarations
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

void main() {
    gl_Position = model2clip();

    texcoord = getTexCoord();
	counterJitter = getJitter();

#ifdef PANINI_ENABLE

	getProjectionPlaneCorners(bl, br, tl, tr, cornerDepths);

#endif
}

// ===============================================================================================
// Helper implementations
// ===============================================================================================
