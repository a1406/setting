#include "test.h"

#include <xmmintrin.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/time.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#define ARRAYCOUNT 10000
//#define ARRAYCOUNT 4

#define COUNTSIZE 10000
//#define COUNTSIZE 1

uint64_t now()
{
	struct timeval tv;
	int ret = gettimeofday(&tv, NULL);
	return tv.tv_sec * 1000000 + tv.tv_usec;
}

struct Vector3f
{
	float x;
	float y;
	float z;
};

struct WCoord
{
	int x;
	int ttt1;	
	int y;
	int ttt2;
	int z;
};

struct Vector3f_v2
{
	float x;
	float y;
	float z;
};

struct WCoord_v2
{
	int x;
	int ttt1;		
	int y;
	int ttt2;		
	int z;
};


int main(int argc, char *argv[])
{
//    float __declspec(align(16))Array[ARRAYCOUNT];
	__attribute__ ((aligned (16))) float Array[ARRAYCOUNT];
	__attribute__ ((aligned (16))) float bakArray[ARRAYCOUNT];

	__attribute__ ((aligned (16))) float Ret[ARRAYCOUNT];
	__attribute__ ((aligned (16))) float Ret2[ARRAYCOUNT];		
    //__declspec(align(16))做为数组定义的修释符，这表示该数组是以16字节为边界对齐的，
    //因为SSE指令只能支持这种格式的内存数据

	int intRet[ARRAYCOUNT];
	int intRet2[ARRAYCOUNT];

	struct WCoord coord[ARRAYCOUNT];
	struct Vector3f vec3[ARRAYCOUNT];	

	struct WCoord_v2 coord_v2[ARRAYCOUNT];
	struct Vector3f_v2 vec3_v2[ARRAYCOUNT];	
	
	
	srandom(getpid());
//    memset(Array, 0, sizeof(float)*ARRAYCOUNT);
	for (int i = 0; i < ARRAYCOUNT; ++i)
	{
		bakArray[i] = random() % 10000 / 10.0;

		vec3[i].x = random() % 10000 / 10.0;
		vec3[i].y = random() % 10000 / 10.0;
		vec3[i].z = random() % 10000 / 10.0;

		vec3_v2[i].x = random() % 10000 / 10.0;
		vec3_v2[i].y = random() % 10000 / 10.0;
		vec3_v2[i].z = random() % 10000 / 10.0;
	}
	uint64_t s,e;

    //赋值
    printf("赋值:\n");
	memcpy(Array, bakArray, sizeof(Array));
	s = now();
	for (int i=0; i<COUNTSIZE; i++)
    {
		__attribute__((aligned(16))) float src[4];
		__attribute__((aligned(16))) int dst[4];
		for (int j = 0; j < ARRAYCOUNT; ++j)
		{
			memcpy(src, (float *)(&vec3[j]), 16);
			*(__m128i *)(&dst) = _mm_cvttps_epi32(*(__m128 *)(&src));
			coord[j].x = dst[0];
			coord[j].y = dst[1];
			coord[j].z = dst[2];
			
			// Float2Int1((int *)(&coord[j]), (float *)(&vec3[j]), ARRAYCOUNT);
			// coord[j].x = (int)(vec3[j].x);
			// coord[j].y = (int)(vec3[j].y);
			// coord[j].z = (int)(vec3[j].z);

			// *(__m128i *)(&coord[j]) = _mm_cvttps_epi32(*(__m128 *)(&vec3[j]));
		}
	}
    e = now();
    printf("    Use SSE: %lu\n", e - s);

	memcpy(Array, bakArray, sizeof(Array));
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
		for (int j = 0; j < ARRAYCOUNT; ++j)
		{
			coord_v2[j].x = (int)(vec3[j].x);
			coord_v2[j].y = (int)(vec3[j].y);
			coord_v2[j].z = (int)(vec3[j].z);			
			// Float2Int2(&intRet2[j * 4], &Array[j * 4], ARRAYCOUNT);
			// Float2Int2(&intRet2[j * 4 + 1], &Array[j * 4 + 1], ARRAYCOUNT);
			// Float2Int2(&intRet2[j * 4 + 2], &Array[j * 4 + 2], ARRAYCOUNT);
//			Float2Int2(&intRet2[j * 4 + 3], &Array[j * 4 + 3], ARRAYCOUNT);			
		}
    }
    e = now();

    printf("Not Use SSE: %lu\n", e - s);
//	if (memcmp(intRet, intRet2, sizeof(intRet)) != 0)
	// if (memcmp(coord, coord_v2, sizeof(coord_v2)) != 0)	
	// {
	// 	printf("check fail\n");
	// }
	for (int i = 0; i < ARRAYCOUNT; ++i)
	{
		if (coord[i].x != coord_v2[i].x ||
			coord[i].y != coord_v2[i].y ||
			coord[i].z != coord_v2[i].z)
		{
			printf("check fail\n");
			break;
		}
	}
	

    //乘法
    printf("乘法:\n");
	memcpy(Array, bakArray, sizeof(Array));
	s = now();
	for (int i=0; i<COUNTSIZE; i++)
    {
        ScaleValue1(Ret, Array, ARRAYCOUNT, 1000.0f);
    }
    e = now();

    printf("    Use SSE: %lu\n", e - s);

	memcpy(Array, bakArray, sizeof(Array));
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        ScaleValue2(Ret2, Array, ARRAYCOUNT, 1000.0f);
    }
    e = now();

    printf("Not Use SSE: %lu\n", e - s);
	if (memcmp(Ret, Ret2, sizeof(Ret)) != 0)
	{
		printf("check fail\n");
	}


//加法
    printf("加法：\n");
	memcpy(Array, bakArray, sizeof(Array));	
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        Add1(Ret, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("    Use SSE: %lu\n", e - s);

	memcpy(Array, bakArray, sizeof(Array));
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        Add2(Ret2, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("Not Use SSE: %lu\n", e - s);
	if (memcmp(Ret, Ret2, sizeof(Ret)) != 0)
	{
		printf("check fail\n");
	}

    //平方
    printf("平方：\n");
	memcpy(Array, bakArray, sizeof(Array));	
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        Sqrt1(Ret, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("    Use SSE: %lu\n", e - s);
	memcpy(Array, bakArray, sizeof(Array));
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        Sqrt2(Ret2, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("Not Use SSE: %lu\n", e - s);
	if (memcmp(Ret, Ret2, sizeof(Ret)) != 0)
	{
		printf("check fail\n");
	}


    //最小值
    printf("最小值：\n");
	memcpy(Array, bakArray, sizeof(Array));
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        Min1(Ret, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("    Use SSE: %lu\n", e - s);
	memcpy(Array, bakArray, sizeof(Array));
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        Min2(Ret2, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("Not Use SSE: %lu\n", e - s);
	if (memcmp(Ret, Ret2, sizeof(Ret)) != 0)
	{
		printf("check fail\n");
	}


    //最大值
	printf("最大值：\n");
	memcpy(Array, bakArray, sizeof(Array));	
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        Max1(Ret, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("    Use SSE: %lu\n", e - s);
	memcpy(Array, bakArray, sizeof(Array));
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        Max2(Ret2, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("Not Use SSE: %lu\n", e - s);
	if (memcmp(Ret, Ret2, sizeof(Ret)) != 0)
	{
		printf("check fail\n");
	}


    //与操作
    printf("与操作：\n");
	memcpy(Array, bakArray, sizeof(Array));	
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        And1(Ret, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("    Use SSE: %lu\n", e - s);
	memcpy(Array, bakArray, sizeof(Array));
	s = now();
    for (int i=0; i<COUNTSIZE; i++)
    {
        And2(Ret2, Array, ARRAYCOUNT, 1000.0f);
    }
	e = now();

    printf("Not Use SSE: %lu\n", e - s);
	if (memcmp(Ret, Ret2, sizeof(Ret)) != 0)
	{
		printf("check fail\n");
	}

    return 0;
}
