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

#if !defined LIB_RANDOM
#define LIB_RANDOM

const int ref_fixed_point = int(exp2(24));
const float fixed2float = 1.0 / exp2(24.0);

// ===============================================================================================
// 1D Hashes
// ===============================================================================================

const int phi_i = 10368890; // 0.61803399
const ivec2 phi2_i = ivec2(5447863, 12664746); // (0.32471796, 0.75487767)
const ivec3 phi3_i = ivec3(3703471, 8224462, 13743434); // (0.22074408, 0.49021612, 0.81917251)

float r1(int seed) {
    int basis = seed * phi_i;
    return mod(basis, ref_fixed_point) * fixed2float;
}

vec2 r2(int seed) {
    ivec2 basis = seed * phi2_i;
    ivec2 modulated = ivec2(
        basis.x & (ref_fixed_point - 1),
        basis.y & (ref_fixed_point - 1)
    );
    return modulated * fixed2float;
}

vec3 r3(int seed) {
    ivec3 basis = seed * phi3_i;
    ivec3 modulated = ivec3(
        basis.x & (ref_fixed_point - 1),
        basis.y & (ref_fixed_point - 1),
        basis.z & (ref_fixed_point - 1)
    );
    return modulated * fixed2float;
}

// ===============================================================================================
// 2D Hashes
// ===============================================================================================

const ivec2 interleave_vec = ivec2(1125928, 97931);
const float interleaved_z = 52.9829189;

const ivec2 phi2inv_i = ivec2(12664746, 9560334);

float interleaved_gradient(ivec2 seed) {
    ivec2 components = seed * interleave_vec;
    int internal_modulus = ((components.x + components.y) & (ref_fixed_point - 1));
    return fract(internal_modulus * (fixed2float * interleaved_z));
}

float r2_dither(ivec2 seed) {
    ivec2 components = seed * phi2inv_i;
    return ((components.x + components.y) & (ref_fixed_point - 1)) * fixed2float;
}

// ===============================================================================================
// 3D Hashes
// ===============================================================================================

float interleaved_gradient(ivec2 seed, int t) {
    return interleaved_gradient(ivec2(seed + 5.588238 * t));
}

float r2_dither(ivec2 seed, int t) {
    ivec3 components = ivec3(seed * phi2inv_i, t * phi_i);
    return ((components.x + components.y) & (ref_fixed_point - 1)) * fixed2float;
}

// Small separator -------------------------------------------------------------------------------


#endif
