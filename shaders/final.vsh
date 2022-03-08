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
#define VERTEX

// ===============================================================================================
// Global variables
// ===============================================================================================

// Inputs and outputs ----------------------------------------------------------------------------

out vec2 texcoord;

// Uniforms --------------------------------------------------------------------------------------

// Other global variables ------------------------------------------------------------------------

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/lib/common.glsl"

// ===============================================================================================
// Helper declarations
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

void main() {
    gl_Position = model2clip();

    texcoord = getTexCoord();
}

// ===============================================================================================
// Helper implementations
// ===============================================================================================
