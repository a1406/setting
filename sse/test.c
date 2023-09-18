#include "test.h"

#include <xmmintrin.h>
#include <math.h>

void Float2Int1(int *pRet, float *pArray, DWORD dwCount)
{
    // DWORD dwGroupCount = dwCount/4;

    // for (DWORD i=0; i<dwGroupCount; i++)
    // {
	// 	*(__m128i*)(pRet + i*4) = _mm_cvttps_epi32(*(__m128*)(pArray + i*4));
	// }
	*(__m128i *)(pRet) = _mm_cvttps_epi32(*(__m128 *)(pArray));
}

void Float2Int2(int *pRet, float *pArray, DWORD dwCount)
{
    // for (DWORD i =0; i<dwCount; i++)
    // {
    //     pRet[i] = (int)(pArray[i]);
    // }
	pRet[0] = (int)(pArray[0]);
	pRet[1] = (int)(pArray[1]);
	pRet[2] = (int)(pArray[2]);
//	pRet[3] = (int)(pArray[3]);	
}


void ScaleValue1(float *pRet, float *pArray, DWORD dwCount, float fScale)//乘法
{
    DWORD dwGroupCount = dwCount/4;
    __m128 e_Scale = _mm_set_ps1(fScale);//设置所有4个值为同一值

    for (DWORD i=0; i<dwGroupCount; i++)
    {
        *(__m128*)(pRet + i*4) = _mm_mul_ps( *(__m128*)(pArray + i*4),e_Scale);
    }
}

void ScaleValue2(float *pRet, float *pArray, DWORD dwCount, float fScale)
{
    for (DWORD i =0; i<dwCount; i++)
    {
        pRet[i] *= fScale;
    }
}

void Add1(float *pRet, float *pArray, DWORD dwCount, float fScale)//加法
{
    DWORD dwGroupCount = dwCount/4;
    __m128 e_Scale = _mm_set_ps1(fScale);//设置所有4个值为同一值

    for (DWORD i=0; i<dwGroupCount; i++)
    {
        *(__m128*)(pRet + i*4) = _mm_add_ps( *(__m128*)(pArray + i*4),e_Scale);
    }
}

void Add2(float *pRet, float *pArray, DWORD dwCount, float fScale)
{
    for (DWORD i =0; i<dwCount; i++)
    {
        pRet[i] += fScale;
    }
}

void Sqrt1(float *pRet, float *pArray, DWORD dwCount, float fScale)//平方
{
    DWORD dwGroupCount = dwCount/4;
    __m128 e_Scale = _mm_set_ps1(fScale);//设置所有4个值为同一值

    for (DWORD i=0; i<dwGroupCount; i++)
    {
        *(__m128*)(pRet + i*4) = _mm_sqrt_ps(e_Scale);
    }
}

void Sqrt2(float *pRet, float *pArray, DWORD dwCount, float fScale)
{
    for (DWORD i =0; i<dwCount; i++)
    {
        pRet[i] = sqrt(fScale);
    }
}

void Min1(float *pRet, float *pArray, DWORD dwCount, float fScale)//最小值
{
    DWORD dwGroupCount = dwCount/4;
    __m128 e_Scale = _mm_set_ps1(fScale);//设置所有4个值为同一值

    for (DWORD i=0; i<dwGroupCount; i++)
    {
        *(__m128*)(pRet + i*4) = _mm_min_ps( *(__m128*)(pArray + i*4),e_Scale);
    }
}

void Min2(float *pRet, float *pArray, DWORD dwCount, float fScale)
{
    for (DWORD i =0; i<dwCount; i++)
    {
        pRet[i] = (pArray[i]>fScale? fScale : pArray[i]);
    }
}

void Max1(float *pRet, float *pArray, DWORD dwCount, float fScale)//最大值
{
    DWORD dwGroupCount = dwCount/4;
    __m128 e_Scale = _mm_set_ps1(fScale);//设置所有4个值为同一值

    for (DWORD i=0; i<dwGroupCount; i++)
    {
        *(__m128*)(pRet + i*4) = _mm_max_ps( *(__m128*)(pArray + i*4),e_Scale);
    }
}

void Max2(float *pRet, float *pArray, DWORD dwCount, float fScale)
{
    for (DWORD i =0; i<dwCount; i++)
    {
        pRet[i] = (pArray[i]<fScale? fScale : pArray[i]);
    }
}

void And1(float *pRet, float *pArray, DWORD dwCount, float fScale)//与操作
{
    DWORD dwGroupCount = dwCount/4;
    __m128 e_Scale = _mm_set_ps1(fScale);//设置所有4个值为同一值

    for (DWORD i=0; i<dwGroupCount; i++)
    {
        *(__m128*)(pRet + i*4) = _mm_and_ps( *(__m128*)(pArray + i*4),e_Scale);
    }
}

void And2(float *pRet, float *pArray, DWORD dwCount, float fScale)
{
    for (DWORD i =0; i<dwCount; i++)
    {
        pRet[i] = (int)(pArray[i]) & (int)(fScale);
    }
}

