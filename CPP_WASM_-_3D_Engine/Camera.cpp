#pragma once

#include "pch.h"
#include "Geo.h"

#include "Camera.h"

inline Kore::mat4 camera_getProjectionMatrix(struct Camera* camera_) {
	camera_->projection = Kore::mat4::Perspective(camera_->FoV, sys->screenDivByWnH, camera_->camNearPlane, camera_->camFarPlane);
	camera_->projection.Set(0, 0, -camera_->projection.get(0, 0));
	return camera_->projection;
}

inline Kore::mat4 camera_getViewMatrix(struct Camera* camera_) {
	camera_->viewMatrix = Kore::mat4::lookAlong(camera_->camForward.xyz(), camera_->cameraPos, camera_->viewMatrix_vec3);
	return camera_->viewMatrix;
}


inline Kore::vec3 camera_screenToWorldSpace(struct Camera* camera_, float posX, float posY) {
	camera_->xClip = (2.0f * posX / sys->screenWidth_f) - 1.0f;
	camera_->yClip = -(2.0f * posY / sys->screenHeight_f) - 1.0f;

	camera_->inverseProView = camera_getViewMatrix(camera_).Invert() * camera_getProjectionMatrix(camera_).Invert();

	camera_->positionClip = Kore::vec4(camera_->xClip, camera_->yClip, 0, 1.0f);
	camera_->positionWorld = camera_->inverseProView * camera_->positionClip;
	camera_->positionWorld /= camera_->positionWorld.w();

	return camera_->positionWorld.xyz();
}

inline void camera_limitMovement(struct Camera* camera_, float limit_ = 30.0f) {
	if (!((camera_->cameraPos.x() > -limit_ + 1.0f)
		&& (camera_->cameraPos.z() > -limit_ + 1.0f)
		&& (camera_->cameraPos.z() < limit_ - 1.0f)
		&& (camera_->cameraPos.x() < limit_ - 1.0f)
		&& (camera_->cameraPos.y() < limit_)))
	{
		camera_->cameraPos = camera_->lastPos;
	}

	if (camera_->cameraPos.y() < camera_->ceiling) {
		camera_->cameraPos.y() = camera_->ceiling;
	}
}


inline void camera_update(struct Camera* camera_, struct Input* input_, float limit_, float deltaT_) {
	//kinc_log(KINC_LOG_LEVEL_ERROR, "camera.h :: sys->screenWidth: %i", sys->screenWidth);

	if (input_->key->W && input_->key->A) {
		camera_->cameraPos += camera_->camForward * deltaT_ * (camera_->camSpeed_divBy2);
		camera_->cameraPos += camera_->camRight * deltaT_ * (camera_->camSpeed_divBy2);
	}
	else if (input_->key->W && input_->key->D) {
		camera_->cameraPos += camera_->camForward * deltaT_ * (camera_->camSpeed_divBy2);
		camera_->cameraPos -= camera_->camRight * deltaT_ * (camera_->camSpeed_divBy2);
	}
	else if (input_->key->S && input_->key->A) {
		camera_->cameraPos -= camera_->camForward * deltaT_ * (camera_->camSpeed_divBy2);
		camera_->cameraPos += camera_->camRight * deltaT_ * (camera_->camSpeed_divBy2);
	}
	else if (input_->key->S && input_->key->D) {
		camera_->cameraPos -= camera_->camForward * deltaT_ * (camera_->camSpeed_divBy2);
		camera_->cameraPos -= camera_->camRight * deltaT_ * (camera_->camSpeed_divBy2);
	}
	else
	{
		if (input_->key->W) { camera_->cameraPos += camera_->camForward * deltaT_ * camera_->camSpeed; }
		else if (input_->key->A) { camera_->cameraPos += camera_->camRight * deltaT_ * camera_->camSpeed; }
		else if (input_->key->D) { camera_->cameraPos -= camera_->camRight * deltaT_ * camera_->camSpeed; }
		else if (input_->key->S) { camera_->cameraPos -= camera_->camForward * deltaT_ * camera_->camSpeed; }

		camera_limitMovement(camera_, limit_);
	}
}

inline void camera_mouseLook(struct Sys* sys_, float movementX, float movementY) {
	if(!sys->camera->mouseLook) { return; }

	sys_->camera->time->now = sys_getTimeRaw(sys);
	sys_->camera->time->shift = sys_->camera->time->now - sys_->camera->time->past;
	sys_->camera->time->past = sys_->camera->time->now;

	sys_->camera->quat00 = Kore::Quaternion(sys_->camera->_0p0f_1p0f_0p0f, 0.01f * movementX);
	sys_->camera->quat01 = Kore::Quaternion(sys_->camera->camRight, 0.01f * -movementY);

	sys_->camera->camRight = sys_->camera->quat00.matrix() * sys_->camera->camRight;
	sys_->camera->camUp = sys_->camera->quat01.matrix() * sys_->camera->camUp;

	sys_->camera->quat00.rotate(sys_->camera->quat01);
	sys_->camera->mat = sys_->camera->quat00.matrix();
	sys_->camera->camForward = sys_->camera->mat * sys_->camera->camForward;
}


void camera_rotate(struct Camera* camera_) {
}

struct Camera* camera_init(struct Camera* camera_) {
	struct Time structTime;
	camera_->time = &structTime;
	return camera_;
}
