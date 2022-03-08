#if !defined COMMON
#define COMMON

// ===============================================================================================
// Camera and transformation
// ===============================================================================================

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;

uniform vec3 cameraPosition;
uniform float near;
uniform float far;

// ===============================================================================================
// Settings
// ===============================================================================================



// ===============================================================================================
// Other uniforms
// ===============================================================================================

uniform float viewWidth;
uniform float viewHeight;
uniform int frameCounter;

// ===============================================================================================
// Universal utilities
// ===============================================================================================

#include "/lib/space.glsl"
#include "/lib/random.glsl"

#endif
