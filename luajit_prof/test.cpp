extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luajit.h"
}
#include <stdio.h>
#include <signal.h>
#include <sys/time.h>
#include <string.h>
#include <time.h>
#include <map>
#include <string>
#define BILLION  1000000000L;

std::map<std::string, int> stacks;
static int                 cb_index = 0;

lua_State *L;
void profile_cb(void *data, lua_State *L,
                int samples, int vmstate)
{
	size_t len;
	// char *p = (char *)luaJIT_profile_dumpstack(L, "f [l];", 16, &len);
	char *p = (char *)luaJIT_profile_dumpstack(L, "f;", 16, &len);	
	std::string k(p, len);
	auto it = stacks.find(k);
	if (it != stacks.end())
	{
		it->second = it->second + samples;
	}
	else
	{
		stacks[k] = samples;
	}

	cb_index += samples;
	// (p[len]) = '\0';
	// printf("======== %d: samples[%d]=========\n%s\n", ++cb_index, samples, p);
	// if (cb_index == 1000)
	// {
	// 	luaJIT_profile_stop(L);
	// 	printf("size = %d\n", stacks.size());
	// 	for (it = stacks.begin(); it != stacks.end(); ++it)
	// 	{
	// 		std::string key = it->first;
	// 		int value = it->second;
	// 		printf("%s %d\n", key.c_str(), value);
	// 	}
	// 	stacks.clear();
	// }
}

LUALIB_API int lua_traceback_buf(lua_State *L, lua_State *L1,
	int level, char *buf, int buf_len);

void signalHandler(int signo)
{
	switch (signo)
	{
		case SIGINT:
		case SIGUSR1:			
			luaJIT_profile_stop(L);
			printf("index = %d, size = %d\n", cb_index, stacks.size());
			break;
		case SIGALRM:
		case SIGPROF:
		{
			if (L)
			{
				// long        len;
				// const char *stackbuf = my_debug_dumpstack(L, 16, &len);
				// if (len > 0 && stackbuf)
				// {
				// 	printf(stackbuf);
				// }
				// static char stackbuf[1024];
				// if (lua_traceback_buf(L, L, 1, stackbuf, 1024) >= 0)
				// printf(stackbuf);
			}
		}
		break;
	}
}
int c_test_mod(lua_State* L)
{
	int N = 5000000;
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
	return 0;
}
int c_test_mod2(lua_State* L)
{
	int N = 5000000 * 2;
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
	return 0;
}

int C_Func(lua_State* L)
{
	printf("C_Func is run \r\n");
	long len;
	// const char *stackbuf = luaJIT_profile_dumpstack(L, "\nfl", 16, &len);
	// const char *stackbuf = my_debug_dumpstack(L, 16, &len);	
	// if (len > 0 && stackbuf)
	// {
	// 	printf(stackbuf);
	// }

	luaL_dostring(L, "print(debug.traceback());");
	return 0;
}

int main(int argc, char *argv[])
{
	L = luaL_newstate();
	luaL_openlibs(L);
	lua_register(L, "C_Func", C_Func);/*将C语言函数注册到Lua中*/
	lua_register(L, "c_test_mod", c_test_mod);/*将C语言函数注册到Lua中*/
	lua_register(L, "c_test_mod2", c_test_mod2);/*将C语言函数注册到Lua中*/	
	
	// int retLoad = luaL_loadfile(L, "test3.lua");
	int retLoad = luaL_loadfile(L, "test2.lua");	
	if (retLoad == 0)
	{
		printf("load file success retLoad:%d\n", retLoad);
	}
	if (retLoad || lua_pcall(L, 0, 0, 0))
	{
		printf("error %s\n", lua_tostring(L, -1));
		return -1;
	}

	struct timespec start, stop;
	double          accum;
	if (clock_gettime(CLOCK_REALTIME, &start) == -1)
	{
		perror("clock gettime");
		return EXIT_FAILURE;
	}

	if (argc > 1)
		luaJIT_profile_start(L, "i10", profile_cb, NULL);

	// signal(SIGPROF, signalHandler);
	// signal(SIGINT, signalHandler);
	signal(SIGUSR1, signalHandler);		
	// struct itimerval new_value, old_value;
	// new_value.it_value.tv_sec     = 0;
	// new_value.it_value.tv_usec    = 1;
	// new_value.it_interval.tv_sec  = 0;
	// new_value.it_interval.tv_usec = 200000;

	// lua_getglobal(L, "testlua_addqueen");
	// setitimer(ITIMER_PROF, &new_value, &old_value);

	lua_getglobal(L, "testmain");
	lua_pushinteger(L, getpid());
	lua_pcall(L, 1, 0, 0);
	printf("end\n");

	if (clock_gettime(CLOCK_REALTIME, &stop) == -1)
	{
		perror("clock gettime");
		return EXIT_FAILURE;
	}
	accum = (stop.tv_sec - start.tv_sec) + (double)(stop.tv_nsec - start.tv_nsec) / (double)BILLION;
	if (argc > 1)
	{
		luaJIT_profile_stop(L);
	}
	printf("size = %d, cb_index = %d\n", stacks.size(), cb_index);
	for (auto it = stacks.begin(); it != stacks.end(); ++it)
	{
		std::string key   = it->first;
		int         value = it->second;
		printf("%s %d\n", key.c_str(), value);
	}
	stacks.clear();
	printf("%lf\n", accum);

	// memset(&new_value, 0, sizeof(new_value));
	// setitimer(ITIMER_PROF, &new_value, &old_value);

	
	// lua_getglobal(L, "name");  //lua获取全局变量name的值并且返回到栈顶
	// lua_getglobal(L, "age");   //lua获取全局变量age的值并且返回到栈顶,这个时候length对应的值将代替width的值成为新栈顶
	// //注意读取顺序
	// int         age  = lua_tointeger(L, -1);  //栈顶
	// const char *name = lua_tostring(L, -2);   //次栈顶
	// printf("name = %s\n", name);
	// printf("age = %d\n", age);

	// lua_getglobal(L, "add");
	// lua_pushnumber(L, 10);
    // lua_pushnumber(L, 20);
	// int pcallRet = lua_pcall(L, 2, 1, 0);
	// printf("pcallRet:%d\n", pcallRet);
    // int val = lua_tonumber(L, -1); //在栈顶取出数据
    // printf("val:%d\n", val);
    // lua_pop(L, -1); //弹出栈顶
	lua_State *t = L;
	L = NULL;
	lua_close(t);
	return 0;
}
