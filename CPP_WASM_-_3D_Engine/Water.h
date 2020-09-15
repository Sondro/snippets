#pragma once

#include <Kore/Math/Matrix.h>

extern inline void water_update(Kore::mat4 matrix_, Kore::mat4 viewMatrix_, Kore::vec3 post_, float z_);
extern inline void water_render(Kore::mat4 matrix_, Kore::mat4 viewMatrix_, Kore::vec3 post_, float z_);

extern inline void water_init();