#include <math.h>
#include <assert.h>
#include <stdio.h>
#include <stdint.h>

#define PX_CUDA_CALLABLE
#define PX_FORCE_INLINE
#define PX_INLINE
#define PxAbs ::fabsf
#define PxSqrt ::sqrtf
#define PX_NORMALIZATION_EPSILON float(1e-20f)
PX_CUDA_CALLABLE PX_FORCE_INLINE float PxMin(float a, float b)
{
	return a < b ? a : b;	
}
PX_CUDA_CALLABLE PX_FORCE_INLINE float PxMax(float a, float b)
{
	return a > b ? a : b;
}

PX_CUDA_CALLABLE PX_FORCE_INLINE float PxRecipSqrt(float a)
{
	return 1.0f / ::sqrtf(a);
}

template <class T>
PX_CUDA_CALLABLE PX_INLINE void PX_UNUSED(T const&)
{
}
#define PX_SHARED_ASSERT(exp) assert(exp);
typedef uint32_t PxU32;
PX_CUDA_CALLABLE PX_FORCE_INLINE bool PxIsFinite(float a)
{
    union localU { PxU32 i; float f; } floatUnion;
    floatUnion.f = a;
    return !((floatUnion.i & 0x7fffffff) >= 0x7f800000);
}

/** enum for empty constructor tag*/
enum PxEMPTY
{
	PxEmpty
};

/** enum for zero constructor tag for vectors and matrices */
enum PxZERO
{
	PxZero
};

/** enum for identity constructor flag for quaternions, transforms, and matrices */
enum PxIDENTITY
{
	PxIdentity
};

#include "vec3.h"
#include "vec4.h"

PxVec3 rotateInv(float x, float y, float z, float w, PxVec3 v)
{
	const float vx   = 2.0f * v.x;
	const float vy   = 2.0f * v.y;
	const float vz   = 2.0f * v.z;
	const float w2   = w * w - 0.5f;                // 1/2 cos(x)
	const float dot2 = (x * vx + y * vy + z * vz);  // 旋转轴和坐标得点乘 * 2

	PxVec3 ret;
	ret.x = (vx * w2 - (y * vz - z * vy) * w + x * dot2);
	ret.y = (vy * w2 - (z * vx - x * vz) * w + y * dot2);
	ret.z = (vz * w2 - (x * vy - y * vx) * w + z * dot2);
	return ret;
	//   v * cos(*)
	// - (x,y,z) CROSS v * cos(* / 2) * 2
	// + (x,y,z) * 2 * ((x, y, z) DOT v)
}

// typedef struct PxVec4_
// {
// 	float w;		
// 	float x;
// 	float y;
// 	float z;
// } PxVec4;
PxVec4 vec4_cross(PxVec4 a, PxVec4 b)
{
	PxVec4 ret;
	ret.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z;
	ret.x = a.w * b.x + b.w * a.x + a.y * b.z - a.z * b.y;
	ret.y = a.w * b.y + b.w * a.y + a.z * b.x - a.x * b.z;
	ret.z = a.w * b.z + b.w * a.z + a.x * b.y - a.y * b.x;	
	return ret;
}

PxVec4 rotateInv2(float x, float y, float z, float w, PxVec3 v)
{
	float len = sqrtf(x * x + y * y + z * z);
	x = x / len;
	y = y / len;
	z = z / len;
	float sin = sqrtf(1 - w * w);
	PxVec4 pp = {
		w, sin * x, sin * y, sin * z
	};
	PxVec4 pstar = {
		w, -pp.x, -pp.y, -pp.z
	};
	PxVec4 vv = {
		0, v.x, v.y, v.z
	};
	PxVec4 r = vec4_cross(vv, pstar);
	r = vec4_cross(pp, r);
	return r;
// v' = p * v * (p*)
// v = [0, V]
// p = [cos(1/2 @), sin(1/2 @) * U]
	
}


PxVec3 rotateInv3(float x, float y, float z, float w, PxVec3 v)
{
	// v11 = (v . u ) u
	// v12 = v - v11
	// v11_ = v11
	// v12_ = cos * v12 + sin * ( U cross V12)
	// v_ = v11_ + v12_
	float len  = sqrtf(x * x + y * y + z * z);
	x = x / len;
	y = y / len;
	z = z / len;
	float cos = 2 * (w * w - 0.5f);
	float sin = sqrtf(1 - cos * cos);
	float t = (x * v.x + y * v.y + z * v.z);
	PxVec3 v11 = {
		x * t, y * t, z * t
	};
	PxVec3 v12 = {
		v.x = v11.x, v.y - v11.y, v.z - v11.z
	};
	PxVec3 v11_ = v11;
	PxVec3 v12_ = {
		v12.x * cos, v12.y * cos, v12.z * cos
	};
	PxVec3 tmpv = {
		y * v12.z - z * v12.y, z * v12.x - x * v12.z, x * v12.y - y * v12.x
	};
	v12_.x += sin * tmpv.x;
	v12_.y += sin * tmpv.y;
	v12_.z += sin * tmpv.z;
	PxVec3 ret = {
	    v11_.x + v12_.x, v11_.y + v12_.y, v11_.z + v12_.z
	};
	return ret;
}

PxVec3 Matrix33_Vec3(PxVec3 v1, PxVec3 v2, PxVec3 v3, PxVec3 v)
{
	return v1 * v.x + v2 * v.y + v3 * v.z;
}

PxVec3 rotateInv4(float x, float y, float z, float w, PxVec3 v)
{
	PxVec3 v1, v2, v3;
	v1.x = 1.0f - 2.0f * y * y - 2.0f * z * z;
	v1.y = 2.0f * x * y + 2.0f * z * w;
	v1.z = 2.0f * x * z - 2.0f * y * w;

	v2.x = 2.0f * x * y - 2.0f * z * w;
	v2.y = 1.0f - 2.0f * x * x - 2.0f * z * z;
	v2.z = 2.0f * y * z + 2.0f * x * w;

	v3.x = 2.0f * x * z + 2.0f * y + w;
	v3.y = 2.0f * y * z - 2.0f * x * w;
	v3.z = 1.0f - 2.0f * x * x - 2.0f * y * y;

	return Matrix33_Vec3(v1, v2, v3, v);
}

#define PI (3.1415926)
int main(int argc, char *argv[])
{
    float x, y, z, w;
	x = 3;
	y = 1;
	z = -1;

	// w = 1.732 / 2.0;
	w = cosf(PI / 6.0 / 2.0);

	float len = (x * x + y * y + z * z);
	float N = 1 - w * w;
	len = sqrtf(N / len);
	
	x = x * len;
	y = y * len;
	z = z * len;
	
//	z = sqrtf(1 - w * w);
	assert(x * x + y * y + z * z + w * w == 1);

	PxVec3 v;
	v.x = 1;
	v.y = 3;
	v.z = -10;

	len = sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
	v.x = v.x / len;
	v.y = v.y / len;
	v.z = v.z / len;	

//	printf("sqrt(3) = %f, sqrt(3) / 2 = %f\n", sqrtf(3.0), sqrtf(3.0) / 2);
	PxVec3 v2 = rotateInv(x, y, z, w, v);
	printf("(%f,  %f,   %f, %f)\n", v2.x, v2.y, v2.z, v2.x * v2.x + v2.y * v2.y + v2.z * v2.z);
	PxVec4 v3 = rotateInv2(x, y, z, w, v);
	printf("(%f,  %f,   %f, %f)\n", v3.x, v3.y, v3.z, v3.x * v3.x + v3.y * v3.y + v3.z * v3.z);
	PxVec3 v4 = rotateInv3(x, y, z, w, v);
	printf("(%f,  %f,   %f, %f)\n", v4.x, v4.y, v4.z, v4.x * v4.x + v4.y * v4.y + v4.z * v4.z);

	PxVec3 v5 = rotateInv4(x, y, z, w, v);
	printf("(%f,  %f,   %f, %f)\n", v5.x, v5.y, v5.z, v5.x * v5.x + v5.y * v5.y + v5.z * v5.z);
	return 0;
}
//	gcc -g -O0 -o test rotateInv.c -lm
 
