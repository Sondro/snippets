#pragma once

#include "pch.h"
#include "Geo.h"

#include <Kore/Graphics4/Graphics.h>
#include <Kore/Math/Vector.h>
#include <Kore/Math/Quaternion.h>

#include "Sys.h"

struct Camera {
	struct Time* time;

	float camNearPlane = 0.01f;
	float camFarPlane = 1000;

	float camRotateSpeed = 0.05f;
	float camSpeed = 5.0f;

	float camSpeed_divBy2 = camSpeed / 2.0f;

	float ceiling = 2.0f;
	const float offsetHeight = 1.0f;

	bool rotate = false;
	bool mouseLook = true;

	Kore::vec4 camUp = Kore::vec4(0.0f, 1.0f, 0.0f, 0.0f);
	Kore::vec4 camForward = Kore::vec4(0.0f, 0.0f, 1.0f, 0.0f);
	Kore::vec4 camRight = Kore::vec4(1.0f, 0.0f, 0.0f, 0.0f);

	//Kore::vec3 cameraPos = Kore::vec3(0, 0, 0);
	Kore::vec3 cameraPos = Kore::vec3(-1, 6, -5);
	Kore::vec3 lastPos = cameraPos;
	
	int FoV = 120; //45, 60, 90
	Kore::mat4 projection;// = Kore::mat4::Perspective(FoV, sys->screenDivByWnH, camNearPlane, camFarPlane);
	//Kore::mat4 projectionInvert = camera_getViewMatrix(camera_).Invert();
	Kore::mat4 viewMatrix;
	Kore::vec3 _0p0f_1p0f_0p0f = Kore::vec3(0.0f, 1.0f, 0.0f);
	Kore::vec3 viewMatrix_vec3 = _0p0f_1p0f_0p0f;

	float xClip;
	float yClip;

	Kore::mat4 inverseProView;
	Kore::vec4 positionClip;
	Kore::vec4 positionWorld;

	Kore::Quaternion quat00;
	Kore::Quaternion quat01;
	Kore::mat4 mat;
	                       
	float horizontalAngle = -3.895574891f; //-1.24f * sys->pi; (3.141592654f)

	float verticalAngle = -0.5f;

};

inline Kore::vec3 camera_screenToWorldSpace(struct Camera* camera_, float posX, float posY);
extern inline Kore::mat4 camera_getProjectionMatrix(struct Camera* camera_);
extern inline Kore::mat4 camera_getViewMatrix(struct Camera* camera_);

extern inline void camera_update(struct Camera* camera_, struct Input* input_, float limit, float deltaT);
extern inline void camera_mouseLook(struct Sys* sys_, float movementX, float movementY);
extern inline struct Camera* camera_init(struct Camera* camera_);