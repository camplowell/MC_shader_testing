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
in  vec2 lmcoord;
in  vec4 glcolor;
in  float ao;

in  vec3 viewPos;
in  vec3 prevViewPos;

// Uniforms --------------------------------------------------------------------------------------

uniform sampler2D tex;
uniform sampler2D lightmap;
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

/* RENDERTARGETS: 0,3 */

void main() {
    vec4 albedo = texture2D(tex, texcoord) * glcolor;

    vec3 color = albedo.rgb * ao;
    color *= texture2D(lightmap, lmcoord).rgb;

    gl_FragData[0] = vec4(color, albedo.a);

    vec3 ndc = ndc2screen(view2ndc(viewPos, gbufferProjection));
    vec3 prevNdc = ndc2screen(view2ndc(prevViewPos, gbufferPreviousProjection));

    gl_FragData[1] = vec4((prevNdc - ndc), 1.0);
}

// ===============================================================================================
// Helper implementations
// ===============================================================================================
