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

#if !defined LIB_TAA_JITTER
#define LIB_TAA_JITTER

// ===============================================================================================
// Jittering
// ===============================================================================================

vec2 getJitter() {
    return (r2(frameCounter) * 2 - 1) / vec2(viewWidth, viewHeight);
}

vec4 jitter(vec4 clipPos) {
    return vec4(clipPos.xy + clipPos.w * getJitter(), clipPos.zw);
}

// Small separator -------------------------------------------------------------------------------

#endif
