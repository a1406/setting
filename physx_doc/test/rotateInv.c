#include <math.h>
#include <assert.h>
#include <stdio.h>
typedef struct PxVec3_
{
	float x;
	float y;
	float z;	
} PxVec3;
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

// PxVec3 rotateInv2(float x, float y, float z, float w, PxVec3 v)
// {
// 	float cos = (w * w - 0.5f) * 2.0;                // cos(x)
// 	float coscos = cos * cos;
// 	float sin = sqrtf(1.0 - coscos);
// 	float sinsin = sin * sin;
	
// 	PxVec3 ret;
// 	ret.x = v.x * coscos + v.y * (sin * cos + sinsin * cos) + v.z * (sinsin - sin * coscos);
// 	ret.y = v.x * (-sin * cos) + v.y * (coscos - sinsin * sin) + v.z * (sin * cos + sinsin * cos);
// 	ret.z = v.x * sin + v.y * (-sin * cos) + v.z * (cos * cos);
// 	return ret;
	
// }


#define PI (3.1415926)
int main(int argc, char *argv[])
{
    float x, y, z, w;
	x = 0;
	y = 0;
	z = -1;
	// w = 1.732 / 2.0;
	w = cosf(PI / 6.0 / 2.0);
	z = sqrtf(1 - w * w);
	assert(x * x + y * y + z * z + w * w == 1);

	PxVec3 v;
	v.x = 1;
	v.y = 0;
	v.z = 0;

	printf("sqrt(3) = %f, sqrt(3) / 2 = %f\n", sqrtf(3.0), sqrtf(3.0) / 2);
	PxVec3 v2 = rotateInv(x, y, z, w, v);
	printf("(%f,  %f,   %f)\n", v2.x, v2.y, v2.z);
	// PxVec3 v3 = rotateInv2(x, y, z, w, v);
	// printf("(%f,  %f,   %f)\n", v3.x, v3.y, v3.z);	
	return 0;
}
//	gcc -g -O0 -o test rotateInv.c -lm
 
