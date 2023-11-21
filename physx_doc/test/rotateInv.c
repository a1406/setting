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
        const float vx = 2.0f * v.x;
        const float vy = 2.0f * v.y;
        const float vz = 2.0f * v.z;
        const float w2 = w * w - 0.5f;  // 1/2 cos(x)
        const float dot2 = (x * vx + y * vy + z * vz);  // 旋转轴和坐标得点乘 * 2

		PxVec3 ret;
		ret.x = (vx * w2 - (y * vz - z * vy) * w + x * dot2);
		ret.y = (vy * w2 - (z * vx - x * vz) * w + y * dot2);
		ret.z = (vz * w2 - (x * vy - y * vx) * w + z * dot2);
        return ret;
//   v * cos(*)
// - (x,y,z) CROSS v * cos(*)
// + (x,y,z) * 2 * ((x, y, z) DOT v)
}
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
	return 0;
}
//	gcc -g -O0 -o test test.c -lm
