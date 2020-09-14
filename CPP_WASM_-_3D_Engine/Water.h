#pragma once

#include <Kore/Math/Matrix.h>

extern inline void water_update(Kore::mat4 matrix, Kore::mat4 vmatrix, Kore::vec3 cam, float zposition);
extern inline void water_render(Kore::mat4 matrix, Kore::mat4 vmatrix, Kore::vec3 camera, float zposition);

extern inline void water_init();