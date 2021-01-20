#include "test.h"

#include <xmmintrin.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/time.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#define ARRAYCOUNT 1000

#define COUNTSIZE 10000

uint64_t now()
{
	struct timeval tv;
	int ret = gettimeofday(&tv, NULL);
	return tv.tv_sec * 1000000 + tv.tv_usec;
}

int main(int argc, char *argv[])
{
//    float __declspec(align(16))Array[ARRAYCOUNT];
	__attribute__ ((aligned (16))) float Array[ARRAYCOUNT];
	__attribute__ ((aligned (16))) float bakArray[ARRAYCOUNT];

	__attribute__ ((aligned (16))) float Ret[ARRAYCOUNT];
	__attribute__ ((aligned (16))) float Ret2[ARRAYCOUNT];		
    //__declspec(align(16))做为数组定义的修释符，这表示该数组是以16字节为边界对齐的，
    //因为SSE指令只能支持这种格式的内存数据

	srandom(getpid());
//    memset(Array, 0, sizeof(float)*ARRAYCOUNT);
	for (int i = 0; i < ARRAYCOUNT; ++i)
	{
		bakArray[i] = random() % 10000 / 10.0;
	}
	uint64_t s,e;

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
