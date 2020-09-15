#pragma once

#include "pch.h"
#include "Geo.h"

#include "Camera.h"

inline Kore::mat4 camera_getProjectionMatrix(struct Camera* camera_) {
	camera_->projection = Kore::mat4::Perspective(camera_->FoV, sys->screenDivByWnH, camera_->nearPlane, camera_->farPlane);
	camera_->projection.Set(0, 0, -camera_->projection.get(0, 0));
	return camera_->projection;
}

inline Kore::mat4 camera_getViewMatrix(struct Camera* camera_) {
	camera_->viewMatrix = Kore::mat4::lookAlong(camera_->forward.xyz(), camera_->post, camera_->viewMatrix_vec3);
	return camera_->viewMatrix;
}

inline Kore::vec3 camera_screenToWorldSpace(struct Camera* camera_, float x_, float y_) {
	camera_->xClip = (2.0f * x_ / sys->screenWidth_f) - 1.0f;
	camera_->yClip = -(2.0f * y_ / sys->screenHeight_f) - 1.0f;

	camera_->inverseProView = camera_getViewMatrix(camera_).Invert() * camera_getProjectionMatrix(camera_).Invert();

	camera_->postClip = Kore::vec4(camera_->xClip, camera_->yClip, 0, 1.0f);
	camera_->postWorld = camera_->inverseProView * camera_->postClip;
	camera_->postWorld /= camera_->postWorld.w();

	return camera_->postWorld.xyz();
}

inline void camera_limitMovement(struct Camera* camera_, float limit_ = 30.0f) {
	if (!((camera_->post.x() > -limit_ + 1.0f)
		&& (camera_->post.z() > -limit_ + 1.0f)
		&& (camera_->post.z() < limit_ - 1.0f)
		&& (camera_->post.x() < limit_ - 1.0f)
		&& (camera_->post.y() < limit_)))
	{
		camera_->post = camera_->oldPost;
	}

	if (camera_->post.y() < camera_->ceiling) {
		camera_->post.y() = camera_->ceiling;
	}
}

inline void camera_update(struct Camera* camera_, struct Input* input_, float limit_, float timeShift_) {
	//kinc_log(KINC_LOG_LEVEL_ERROR, "camera.h :: sys.screenWidth: %i", sys->screenWidth);

		if (input_->key->W && input_->key->A) {
			camera_->post += camera_->forward * timeShift_ * camera_->speed_divBy2;
			camera_->post += camera_->right * timeShift_ * camera_->speed_divBy2;
		}
		else if (input_->key->W && input_->key->D) {
			camera_->post += camera_->forward * timeShift_ * camera_->speed_divBy2;
			camera_->post -= camera_->right * timeShift_ * camera_->speed_divBy2;
		}
		else if (input_->key->S && input_->key->A) {
			camera_->post -= camera_->forward * timeShift_ * camera_->speed_divBy2;
			camera_->post += camera_->right * timeShift_ * camera_->speed_divBy2;
		}
		else if (input_->key->S && input_->key->D) {
			camera_->post -= camera_->forward * timeShift_ * camera_->speed_divBy2;
			camera_->post -= camera_->right * timeShift_ * camera_->speed_divBy2;
		}
		else
		{
			if (input_->key->W) { camera_->post += camera_->forward * timeShift_ * camera_->speed; }
			else if (input_->key->A) { camera_->post += camera_->right * timeShift_ * camera_->speed; }
			else if (input_->key->D) { camera_->post -= camera_->right * timeShift_ * camera_->speed; }
			else if (input_->key->S) { camera_->post -= camera_->forward * timeShift_ * camera_->speed; }

			camera_limitMovement(camera_, limit_);
		}
}

inline void camera_mouseLook(struct Sys* sys_, float goX_, float goY_) {
	if(!sys->camera->mouseLook) { return; }

	sys_->camera->time->now = sys_getTime(sys);
	sys_->camera->time->shift = sys_->camera->time->now - sys_->camera->time->past;
	sys_->camera->time->past = sys_->camera->time->now;

	sys_->camera->quat00 = Kore::Quaternion(sys_->camera->_0p0f_1p0f_0p0f, 0.01f * goX_);
	sys_->camera->quat01 = Kore::Quaternion(sys_->camera->right, 0.01f * -goY_);

	sys_->camera->right = sys_->camera->quat00.matrix() * sys_->camera->right;
	sys_->camera->up = sys_->camera->quat01.matrix() * sys_->camera->up;

	sys_->camera->quat00.rotate(sys_->camera->quat01);
	sys_->camera->mat = sys_->camera->quat00.matrix();
	sys_->camera->forward = sys_->camera->mat * sys_->camera->forward;
}

void camera_rotate(struct Camera* camera_) {
}

struct Camera* camera_init(struct Camera* camera_) {
	struct Time structTime;
	camera_->time = &structTime;
	return camera_;
}
