#if !defined LIB_SPACE
#define LIB_SPACE

// ===============================================================================================
// Vertex-space definitions
// ===============================================================================================

#if defined VERTEX

vec3 model2view() {
  return (gl_ModelViewMatrix * gl_Vertex).xyz;
}

vec4 model2clip() {
  return gl_ModelViewProjectionMatrix * gl_Vertex;
}

vec2 getTexCoord() {
  return (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

vec2 getLmCoord() {
  return (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
}

vec3 getNormal() {
  return normalize(gl_NormalMatrix * gl_Normal);
}

vec4 view2clip(vec3 viewPos) {
  return gl_ProjectionMatrix * vec4(viewPos, 1.0);
}

#endif

// ===============================================================================================
// Base definitions
// ===============================================================================================

vec3 screen2ndc(vec3 screenPos) {
  return screenPos * 2.0 - 1.0;
}
vec3 ndc2screen(vec3 ndcPos) {
  return ndcPos * 0.5 + 0.5;
}

vec3 ndc2view(vec3 ndcPos, mat4 projectionInverse) {
  vec4 tmp = projectionInverse * vec4(ndcPos, 1.0);
  return tmp.xyz / tmp.w;
}
vec3 view2ndc(vec3 viewPos, mat4 projection) {
  vec4 ndc = projection * vec4(viewPos, 1.0);
  return ndc.xyz / ndc.w;
}

vec3 view2eye(vec3 viewPos, mat4 modelViewInverse) {
  return mat3(modelViewInverse) * viewPos;
}
vec3 eye2view(vec3 eyePos, mat4 modelView) {
  return mat3(modelView) * eyePos;
}

vec3 eye2feet(vec3 eyePos, mat4 modelViewInverse) {
  return eyePos + modelViewInverse[3].xyz;
}
vec3 feet2eye(vec3 feetPos, mat4 modelView) {
  return feetPos + modelView[3].xyz;
}

vec3 view2feet(vec3 viewPos, mat4 modelViewInverse) {
  return (modelViewInverse * vec4(viewPos, 1.0)).xyz;
}
vec3 feet2view(vec3 feetPos, mat4 modelView) {
  return (modelView * vec4(feetPos, 1.0)).xyz;
}

vec3 feet2world(vec3 feetPos, vec3 playerPos) {
  return feetPos + playerPos;
}

// ===============================================================================================
// Specific definitions
// ===============================================================================================

// Player-space shorthand

#define ndc2view_p(_ndcPos) ndc2view(_ndcPos, gbufferProjectionInverse)
#define view2ndc_p(_viewPos) view2ndc(_viewPos, gbufferProjection)

#define view2eye_p(_viewPos) view2eye(_viewPos, gbufferModelViewInverse)
#define eye2view_p(_eyePos) eye2view(_eyePos, gbufferModelView)

#define eye2feet_p(_eyePos) eye2feet(_eyePos, gbufferModelViewInverse)
#define feet2eye_p(_feetPos) feet2eye(_feetPos, gbufferModelView)

#define view2feet_p(_viewPos) view2feet(_viewPos, gbufferModelViewInverse)
#define feet2view_p(_feetPos) feet2view(_feetPos, gbufferModelView)

// Shadow-space shorthand

#define view2eye_s(_viewPos) view2eye(_viewPos, shadowModelViewInverse)
#define eye2view_s(_eyePos) eye2view(_eyePos, shadowModelView)

#define view2feet_s(_viewPos) view2feet(_viewPos, shadowModelViewInverse)
#define feet2view_s(_feetPos) feet2view(_feetPos, shadowModelView)

#endif // End of document
