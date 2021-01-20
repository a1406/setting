#ifndef __METHOD
#define __METHOD
#include <stdio.h>
#include <stdint.h>

typedef uint32_t DWORD;

void ScaleValue1(float *pRet, float *pArray, DWORD dwCount, float fScale);//乘法
void ScaleValue2(float *pRet, float *pArray, DWORD dwCount, float fScale);

void Add1(float *pRet, float *pArray, DWORD dwCount, float fScale);//加法
void Add2(float *pRet, float *pArray, DWORD dwCount, float fScale);

void Sqrt1(float *pRet, float *pArray, DWORD dwCount, float fScale);//平方
void Sqrt2(float *pRet, float *pArray, DWORD dwCount, float fScale);

void Min1(float *pRet, float *pArray, DWORD dwCount, float fScale);//最小值
void Min2(float *pRet, float *pArray, DWORD dwCount, float fScale);//最小值

void Max1(float *pRet, float *pArray, DWORD dwCount, float fScale);//最小值
void Max2(float *pRet, float *pArray, DWORD dwCount, float fScale);//最小值

void And1(float *pRet, float *pArray, DWORD dwCount, float fScale);//与操作
void And2(float *pRet, float *pArray, DWORD dwCount, float fScale);//与操作

#endif
