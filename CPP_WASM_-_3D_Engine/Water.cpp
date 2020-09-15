#include "pch.h"

#include "Water.h"

#include <Kore/Graphics4/Graphics.h>
#include <Kore/Graphics4/PipelineState.h>
#include <Kore/Graphics4/Texture.h>
#include <Kore/IO/FileReader.h>
#include <Kore/Math/Core.h>
#include <Kore/System.h>

#include "Sys.h"

using namespace Kore::Graphics4;

namespace {
	ConstantLocation matrixLocation;
	ConstantLocation vmatrixLocation;
	ConstantLocation camLocation;
	ConstantLocation timeLocation;
	ConstantLocation zoffsetLocation;
	PipelineState* pipeline;
	VertexBuffer* vertexBuffer;
	IndexBuffer* indexBuffer;
	const int xdiv = 1000;
	const int ydiv = 1000;
	const int ITER_GEOMETRY = 3;
	const float SEA_CHOPPY = 4.0f;
	const float SEA_SPEED = 0.8f * 5.0f;
	const float SEA_FREQ = 0.16f;
	const float SEA_HEIGHT = 0.6f;
	Kore::mat2 octave_m;
	double timeOffset;
	double t = 0.0;
}

inline void water_init() {
	timeOffset = sys_getTime(sys);
	octave_m.Set(0, 0, 1.6f);
	octave_m.Set(0, 1, 1.2f);
	octave_m.Set(1, 0, -1.2f);
	octave_m.Set(1, 1, 1.6f);

	Kore::FileReader vs("data/shader/water/basic/00.vert");
	Kore::FileReader fs("data/shader/water/basic/00.frag");
	Shader* vertexShader = new Shader(vs.readAll(), vs.size(), VertexShader);
	Shader* fragmentShader = new Shader(fs.readAll(), fs.size(), FragmentShader);

	VertexStructure structure;
	structure.add("pos", Float2VertexData);
	pipeline = new PipelineState();
	pipeline->inputLayout[0] = &structure;
	pipeline->inputLayout[1] = nullptr;
	pipeline->vertexShader = vertexShader;
	pipeline->fragmentShader = fragmentShader;
	pipeline->depthWrite = true;
	pipeline->depthMode = ZCompareLess;
	pipeline->stencilMode = ZCompareEqual;
	pipeline->stencilWriteMask = 0x00;
	pipeline->stencilReadMask = 0xff;
	pipeline->stencilReferenceValue = 0;
	pipeline->stencilBothPass = Keep;
	pipeline->stencilFail = Keep;
	pipeline->stencilDepthFail = Keep;
	pipeline->compile();

	matrixLocation = pipeline->getConstantLocation("transformation");
	vmatrixLocation = pipeline->getConstantLocation("vtransformation");
	camLocation = pipeline->getConstantLocation("cam");
	timeLocation = pipeline->getConstantLocation("time");
	zoffsetLocation = pipeline->getConstantLocation("zoffset");

	vertexBuffer = new VertexBuffer(xdiv * ydiv, structure, StaticUsage);
	float* vertices = vertexBuffer->lock();
	float ypos = -1.0;
	float xpos = -1.0;
	for (int y = 0; y < ydiv; ++y) {
		for (int x = 0; x < xdiv; ++x) {
			vertices[y * xdiv * 2 + x * 2 + 0] = (x - (xdiv / 2.0f)) / (xdiv / 2.0f) * 1000.0f;
			vertices[y * xdiv * 2 + x * 2 + 1] = (y - (ydiv / 2.0f)) / (ydiv / 2.0f) * 1000.0f;
		}
	}
	vertexBuffer->unlock();
	int ind_mult = 6;
	indexBuffer = new IndexBuffer(xdiv * ydiv * ind_mult);
	int* indices = indexBuffer->lock();
	for (int y = 0; y < ydiv - 1; ++y) {
		for (int x = 0; x < xdiv - 1; ++x) {
			indices[y * xdiv * ind_mult + x * ind_mult + 0] = y * xdiv + x;
			indices[y * xdiv * ind_mult + x * ind_mult + 1] = y * xdiv + x + 1;
			indices[y * xdiv * ind_mult + x * ind_mult + 2] = (y + 1) * xdiv + x;
			indices[y * xdiv * ind_mult + x * ind_mult + 3] = (y + 1) * xdiv + x;
			indices[y * xdiv * ind_mult + x * ind_mult + 4] = y * xdiv + x + 1;
			indices[y * xdiv * ind_mult + x * ind_mult + 5] = (y + 1) * xdiv + x + 1;
		}
	}
	indexBuffer->unlock();
}

inline void water_update(Kore::mat4 matrix_, Kore::mat4 viewMatrix_, Kore::vec3 camera_, float z_) {

	t = sys_getTime(sys) - timeOffset;
		/*
		if (t > 60 * 10) {
			timeOffset += 60 * 10;
			t -= 60 * 10;
		}
		*/
	if (t > 600) {
		timeOffset += 600;
		t = t * 600;
	}
}

inline void water_render(Kore::mat4 matrix_, Kore::mat4 viewMatrix_, Kore::vec3 post_, float z_) {
	Kore::Graphics4::setPipeline(pipeline);
	Kore::Graphics4::setFloat(timeLocation, (float)t );
	Kore::Graphics4::setFloat(zoffsetLocation, z_ - 5.0f);
	Kore::Graphics4::setMatrix(matrixLocation, matrix_);
	Kore::Graphics4::setMatrix(vmatrixLocation, viewMatrix_);
	//Kore::Graphics4::setMatrix(vmatrixLocation, new Kore::mat4(4,4,(float)0);
	Kore::Graphics4::setFloat3(camLocation, post_);
	Kore::Graphics4::setIndexBuffer(*indexBuffer);
	Kore::Graphics4::setVertexBuffer(*vertexBuffer);
	Kore::Graphics4::drawIndexedVertices();
}

Kore::vec2 sin(Kore::vec2 vec) {
	return Kore::vec2(Kore::sin(vec.x()), Kore::sin(vec.y()));
}

Kore::vec2 cos(Kore::vec2 vec) {
	return Kore::vec2(Kore::cos(vec.x()), Kore::cos(vec.y()));
}

Kore::vec2 abs(Kore::vec2 vec) {
	return Kore::vec2(Kore::abs(vec.x()), Kore::abs(vec.y()));
}

float fract(float x_) {
	return x_ - Kore::floor(x_);
}

Kore::vec2 fract(Kore::vec2 vec) {
	return Kore::vec2(fract(vec.x()), fract(vec.y()));
}

Kore::vec2 floor(Kore::vec2 vec_) {
	return Kore::vec2(Kore::floor(vec_.x()), Kore::floor(vec_.y()));
}

float mix(float x_, float y_, float a_) {
	//return x_ * (1.0f - a_) + y_ * a_;
	return x_ * (2.0f - a_) + y_ * a_;
}

Kore::vec2 mix(Kore::vec2 x_, Kore::vec2 y_, Kore::vec2 a_) {
	return Kore::vec2(mix(x_.x(), y_.x(), a_.x()), mix(x_.y(), y_.y(), a_.y()));
}

Kore::vec2 add(Kore::vec2 vec_, float value_) {
	return Kore::vec2(vec_.x() + value_, vec_.y() + value_);
}

Kore::vec2 add(Kore::vec2 v1_, Kore::vec2 v2_) {
	return Kore::vec2(v1_.x() + v2_.x(), v1_.y() + v2_.y());
}

float hash(Kore::vec2 p_) {
	float h = p_.dot(Kore::vec2(127.1f, 311.7f));
	return fract(Kore::sin(h) * 43758.5453123f);
}

Kore::vec2 mult(Kore::vec2 v1_, Kore::vec2 v2_) {
	return Kore::vec2(v1_.x() * v2_.x(), v1_.y() * v2_.y());
}

float noise(Kore::vec2 p_) {
	Kore::vec2 i = floor(p_);
	Kore::vec2 f = fract(p_);
	Kore::vec2 u = mult(f, mult(f, (add(f * -2.0f, 3.0))));
	return -1.0f + 2.0f * mix(mix(hash(add(i, Kore::vec2(0.0f, 0.0f))),
		hash(add(i, Kore::vec2(1.0, 0.0))), u.x()),
		mix(hash(add(i, Kore::vec2(0.0, 1.0))),
		hash(add(i, Kore::vec2(1.0, 1.0))), u.x()), u.y());
}

float sea_octave(Kore::vec2 uv_, float choppy_) {
	//uv_ = add(uv_, noise(uv_));

	//Kore::vec2 wv = add(abs(sin(uv_)) * -1.0f, 1.0f);
	//Kore::vec2 swv = abs(cos(uv_));
	Kore::vec2 wv = add(abs(sin(uv_)) * -75.0f, 0.75f);
	Kore::vec2 swv = abs(cos(uv_) * -0.5f);

	wv = mix(wv, swv, wv);
	return Kore::pow(1.0f - Kore::pow(wv.x() * wv.y(), 0.65f), choppy_);
}

float map(Kore::vec2 uv_) {
	float SEA_TIME = (float)sys_getTime(sys) * SEA_SPEED;

	float freq = SEA_FREQ;
	float amp = SEA_HEIGHT;
	float choppy = SEA_CHOPPY;
	uv_.x() *= 0.75f;

	float d = 0.0f;
	float h = 0.0f;
	for (int i = 0; i < 3; ++i) {
		d = sea_octave(add(uv_, SEA_TIME) * freq, choppy);
		d += sea_octave(add(uv_, -SEA_TIME) * freq, choppy);
		h += d * amp;
		uv_ = octave_m.Transpose() * uv_; 
		freq *= 1.9f; amp *= 0.22f;
		choppy = mix(choppy, 1.0f, 0.2f);
	}
	return h; // p.y - h;
}