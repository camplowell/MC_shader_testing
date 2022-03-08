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

#if !defined LIB_RESAMPLING
#define LIB_RESAMPLING

// ===============================================================================================
// Large separator
// ===============================================================================================

// B-Spline resampling from Tarnished Pixels
// https://vec3.ca/bicubic-filtering-in-fewer-taps
vec3 resample_bspline(sampler2D tex, vec2 texcoord) {
    vec2 texSize = textureSize(tex, 0);
    vec2 texSize_inv = 1.0 / texSize;
    // Calculate pos in texel space
    vec2 iTc = texcoord * texSize;
    vec2 tc = floor(iTc - 0.5) + 0.5;
    //compute the fractional offset from that texel center
    //to the actual coordinate we want to filter at
 
    vec2 f = iTc - tc;
 
    //we'll need the second and third powers
    //of f to compute our filter weights
 
    vec2 f2 = f * f;
    vec2 f3 = f2 * f;
 
    //compute the filter weights

    vec2 w0 = f2 - 0.5 * (f3 + f);
    vec2 w1 = 1.5 * f3 - 2.5 * f2 + 1.0;
    vec2 w3 = 0.5 * (f3 - f2);
    vec2 w2 = 1.0 - w0 - w1 - w3;

    //get our texture coordinates
 
    vec2 s0 = w0 + w1;
    vec2 s1 = w2 + w3;
 
    vec2 f0 = w1 / (w0 + w1);
    vec2 f1 = w3 / (w2 + w3);
 
    vec2 t0 = tc - 1 + f0;
    vec2 t1 = tc + 1 + f1;

    //convert them to normalized coordinates
 
    t0 *= texSize_inv;
    t1 *= texSize_inv;
 
    //and sample and blend

    return
        texture2D( tex, vec2( t0.x, t0.y ) ).rgb * s0.x * s0.y
      + texture2D( tex, vec2( t1.x, t0.y ) ).rgb * s1.x * s0.y
      + texture2D( tex, vec2( t0.x, t1.y ) ).rgb * s0.x * s1.y
      + texture2D( tex, vec2( t1.x, t1.y ) ).rgb * s1.x * s1.y;
}

// Small separator -------------------------------------------------------------------------------

#endif
