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

PX_FORCE_INLINE PxVec3 V3Sub(const PxVec3 a, const PxVec3 b)
{
	return PxVec3(a.x - b.x, a.y - b.y, a.z - b.z);
}

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

PX_FORCE_INLINE PxVec3 QuatRotate(const PxVec4 q, const PxVec3 v)
{
	/*
	const PxVec3 qv(x,y,z);
	return (v*(w*w-0.5f) + (qv.cross(v))*w + qv*(qv.dot(v)))*2;
	*/

	const float two = (2.f);
	// const FloatV half = FloatV_From_F32(0.5f);
	const float nhalf = (-0.5f);
	const PxVec3 u(q.x, q.y, q.z);// = Vec3V_From_Vec4V(q);
	const float w = (q.w);
	// const FloatV w2 = FSub(FMul(w, w), half);
	const float w2 = w * w + nhalf;//FScaleAdd(w, w, nhalf);
	const PxVec3 a = v * w2;//V3Scale(v, w2);
	// const Vec3V b = V3Scale(V3Cross(u, v), w);
	// const Vec3V c = V3Scale(u, V3Dot(u, v));
	// return V3Scale(V3Add(V3Add(a, b), c), two);
//	const PxVec3 temp = V3ScaleAdd(V3Cross(u, v), w, a);
	const PxVec3 temp = u.cross(v) * w + a;//V3ScaleAdd(u.cross(v), w, a);
	// return V3Scale(V3ScaleAdd(u, V3Dot(u, v), temp), two);
	return (u * u.dot(v) + temp) * two;
}

PX_FORCE_INLINE PxVec4 QuatMul(const PxVec4 a, const PxVec4 b)
{
	const PxVec3 imagA(a.x, a.y, a.z);
	const PxVec3 imagB(b.x, b.y, b.z);
	const float rA = a.w;
	const float rB = b.w;

	// const float real = FSub(FMul(rA, rB), V3Dot(imagA, imagB));
	const float real = rA * rB - imagA.dot(imagB);
	const PxVec3 v0 = (imagA * rB);
	const PxVec3 v1 = (imagB * rA);
	// const PxVec3 v2 = V3Cross(imagA, imagB);
	const PxVec3 v2 = imagA.cross(imagB);	
	// const PxVec3 imag = V3Add(V3Add(v0, v1), v2);
	const PxVec3 imag = ((v0 + v1) + v2);	

	return PxVec4(imag.x, imag.y, imag.z, real);
	// return V4SetW(Vec4V_From_Vec3V(imag), real);
}

PX_FORCE_INLINE void transformInv(PxVec3 p, PxVec4 q, PxVec3& pos, PxVec4& rot)
{
	// PX_ASSERT(src.isSane());
	// PX_ASSERT(isFinite());
	// src = [srct, srcr] -> [r^-1*(srct-t), r^-1*srcr]
	/*PxQuat qinv = q.getConjugate();
	return PxTransform(qinv.rotate(src.p - p), qinv*src.q);*/
	PxVec4 qinv = (q);
	qinv.x = -qinv.x;
	qinv.y = -qinv.y;
	qinv.z = -qinv.z;	
	pos = QuatRotate(qinv, V3Sub(pos, p));
	rot = QuatMul(qinv, rot);
	// return PsTransformV(v, rot);
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

PxVec3 rotateInv2(float x, float y, float z, float w, PxVec3 v)
{
	// PxVec3 u(x, y, z);
	// u.normalizeSafe();

	// float sin = sqrtf(1 - w * w);
	// PxVec4 pp(sin * u, w);
	// PxVec4 pstar(-pp.x, -pp.y, -pp.z, w);
	// PxVec4 vv(v, 0);
	// PxVec4 r = vec4_cross(vv, pstar);
	// r = vec4_cross(pp, r);
	// return r.getXYZ();

	PxVec4 pp(x, y, z, w);
	PxVec4 pstar(-pp.x, -pp.y, -pp.z, w);
	PxVec4 vv(v, 0);
	PxVec4 r = vec4_cross(vv, pstar);
	r = vec4_cross(pp, r);
	return r.getXYZ();
// v' = p * v * (p*)
// v = [0, V]
// p = [cos(1/2 @), sin(1/2 @) * U]
	
}

PxVec3 rotateInv2_1(float x, float y, float z, float w, PxVec3 v)
{
//qvq∗ = [0, cos(θ)v + (1 − cos(θ))(u · v)u + sin(θ)(u × v)]

	float cos = 2 * (w * w - 0.5f);
	float sin = sqrtf(1 - cos * cos);

	PxVec3 u(x, y, z);
	u.normalizeSafe();

	PxVec3 t1 = v * cos;
	PxVec3 t2 = u * (u.dot(v)) * (1 - cos);
	PxVec3 t3 = u.cross(v) * sin;
	PxVec3 t4 = t1 + t2 + t3;
	return t4;
}


PxVec3 rotateInv3(float x, float y, float z, float w, PxVec3 v)
{
	// v11 = (v . u ) u
	// v12 = v - v11
	// v11_ = v11
	// v12_ = cos * v12 + sin * ( U cross V12)
	// v_ = v11_ + v12_
	PxVec3 U(x, y, z);
	U.normalize();
	float cos = 2 * (w * w - 0.5f);
	float sin = sqrtf(1 - cos * cos);
	float t = U.dot(v);
	PxVec3 v11 = U * t;
	PxVec3 v12 = v - v11;
	PxVec3 v11_ = v11;
	PxVec3 v12_ = v12 * cos;
	// PxVec3 tmpv = U.cross(v12);
	PxVec3 tmpv = U.cross(v);	// 叉乘V和v12结果是一样的
	v12_ += (tmpv * sin);
	PxVec3 ret = v11_ + v12_;
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

	v3.x = 2.0f * x * z + 2.0f * y * w;
	v3.y = 2.0f * y * z - 2.0f * x * w;
	v3.z = 1.0f - 2.0f * x * x - 2.0f * y * y;

	return Matrix33_Vec3(v1, v2, v3, v);
}

PxVec3 rotateInv10(float x, float y, float z, float w, PxVec3 v)
{
	PxVec3 v1(1, 0, 0);
	PxVec3 v2(0, 1, 0);
	PxVec3 v3(0, 0, 1);
	PxVec3 v1_2 = rotateInv2(x, y, z, w, v1);
	PxVec3 v2_2 = rotateInv2(x, y, z, w, v2);
	PxVec3 v3_2 = rotateInv2(x, y, z, w, v3);

	return PxVec3(v.dot(v1_2),
		v.dot(v2_2),
		v.dot(v3_2));
}

void print_result(const char *prefix, PxVec3 v)
{
	printf("%s (%f,  %f,   %f, %f)\n", prefix, v.x, v.y, v.z, v.x * v.x + v.y * v.y + v.z * v.z);	
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

//	"(-0.00447, 0.00953, 0.50002, 0.86595)"
	// x = -0.00447;
	// y = 0.00953;
	// z = 0.50002;
	// w = 0.86595;

//	printf("sqrt(3) = %f, sqrt(3) / 2 = %f\n", sqrtf(3.0), sqrtf(3.0) / 2);
	PxVec3 v2 = rotateInv(x, y, z, w, v);
	print_result("rotateInv: ", v2);

	PxVec3 pos = v;
	PxVec4 rot;
	transformInv(PxVec3(0,0,0), PxVec4(x, y, z, w), pos, rot);
	
	PxVec3 v10 = rotateInv10(x, y, z, w, v);
	print_result("rotateInv10: ", v10);	

	PxVec3 v3 = rotateInv2(x, y, z, w, v);
	print_result("四元数1 rotateInv2: ", v3);
	v3 = rotateInv2_1(x, y, z, w, v);
	print_result("四元数2 rotateInv2_1: ", v3);
	
	PxVec3 v4 = rotateInv3(x, y, z, w, v);
	print_result("几何方式 rotateInv3: ", v4);

	PxVec3 v5 = rotateInv4(x, y, z, w, v);
	print_result("旋转矩阵 rotateInv4: ", v5);
	return 0;
}
//	gcc -g -O0 -o test rotateInv.c -lm
 
