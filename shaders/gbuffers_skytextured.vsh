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

#include "/surfaces/emissive.vsh"

// ===============================================================================================
// Helper implementations
// ===============================================================================================

vec3 getViewPos() {
	return model2view();
}

vec3 getPrevViewPos(vec3 viewPos) {
	vec3 feetPos = view2feet_p(viewPos);
	return feet2view(feetPos, gbufferPreviousModelView);
}
vec4 getGlColor() {
	return gl_Color;
}

float getAo() {
	return 1.0;
}