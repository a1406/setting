#include <stdio.h>
#include <signal.h>
#include <sys/time.h>
#include <string.h>
#include <time.h>
#include <map>
#include <string>
#define BILLION  1000000000L;

void test_mod1(int N)
{
	for (int i = 1; i <= N; ++i)
	{
		int v = i;
		int s = 0;
		while (v > 0)
		{
            int x = v % 10;
            s = s + x * x * x;
            v = (v / 10);
		}
	}
}

void test1(int N)
{
	for (int i = 1; i <= N; ++i)
		test_mod1(5000000);
}

int main(int argc, char *argv[])
{
	struct timespec start, stop;
	double          accum;
	if (clock_gettime(CLOCK_REALTIME, &start) == -1)
	{
		perror("clock gettime");
		return EXIT_FAILURE;
	}

    for (int i = 1; i <= 100; ++i)
	{
		test1(10);		
	}
	if (clock_gettime(CLOCK_REALTIME, &stop) == -1)
	{
		perror("clock gettime");
		return EXIT_FAILURE;
	}
	accum = (stop.tv_sec - start.tv_sec) + (double)(stop.tv_nsec - start.tv_nsec) / (double)BILLION;
	printf("%lf\n", accum);	
    return 0;
}
