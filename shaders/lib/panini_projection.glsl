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

#if !defined LIB_PANINI
#define LIB_PANINI


#if defined VERTEX
// ===============================================================================================
// Vertex operations
// ===============================================================================================
void getProjectionPlaneCorners(out vec2 bl, out vec2 br, out vec2 tl, out vec2 tr, out mat2 cornerDepths) {
    
    vec3 bl_c = -ndc2view_p(screen2ndc(vec3( 0, 0, 1)));
    vec3 br_c = -ndc2view_p(screen2ndc(vec3( 1, 0, 1)));
    vec3 tl_c = -ndc2view_p(screen2ndc(vec3( 0, 1, 1)));
    vec3 tr_c = -ndc2view_p(screen2ndc(vec3( 1, 1, 1)));

    bl_c /= length(bl_c.xz);
    br_c /= length(br_c.xz);
    tl_c /= length(tl_c.xz);
    tr_c /= length(tr_c.xz);

    cornerDepths[0][0] = bl_c.z;
    cornerDepths[1][0] = br_c.z;
    cornerDepths[0][1] = tl_c.z;
    cornerDepths[1][1] = tr_c.z;

    bl = bl_c.xy / bl_c.z;
    br = br_c.xy / br_c.z;
    tl = tl_c.xy / tl_c.z;
    tr = tr_c.xy / tr_c.z;
}

#else
// ===============================================================================================
// Fragment operations
// ===============================================================================================

// Perform a panini reprojection
// bl, br, tl, and tr represent the screen corners on the unit plane.
vec2 panini(vec2 pos, vec2 bl, vec2 br, vec2 tl, vec2 tr, mat2 cornerDepths) {
    // Get our reference variables
    float depth_ref = mix(
        mix(cornerDepths[0][0], cornerDepths[1][0], pos.x),
        mix(cornerDepths[0][1], cornerDepths[1][1], pos.x),
        pos.y
    );
    float a = sqrt(depth_ref) * 0.25 * sqrt(PANINI_FAC);
    // Map to unit cylinder
    vec3 cylinder = vec3(mix(mix(bl, br, pos.x), mix(tl, tr, pos.x), pos.y), 1.0);
    //cylinder /= length(cylinder.xz);
    cylinder *= inversesqrt(cylinder.x * cylinder.x + 1.0);
    // Reproject from further back
    vec3 reprojected = cylinder - vec3(0, 0, a);
    reprojected *= (depth_ref - a) / reprojected.z;
    // Transform back into view space
    //return ndc2screen(view2ndc_p(cylinder)).xy;
    return ndc2screen(view2ndc_p(reprojected + vec3(0, 0, a))).xy;
}

#endif

#endif
