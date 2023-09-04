jemalloc内存泄漏排查
====


1. jemalloc默认的编译是没有包含–enable-prof ，在jemalloc官网下载jemalloc的代码并编译。也可以使用我已经编译好的，在开发机224上，目录是/home/jack/jemalloc

2. 修改LinuxGameApp.cpp的check\_param\_handler函数，这个函数对应的是SIGUSR1信号，添加如下代码，目的是在给进程发送SIGUSR1信号的时候，生成内存快照用于对比。如下  
>  171 #include "jemalloc/jemalloc.h"  
>  172 void check_param_handler(int sig)  
>  173 {
>  174     printf("==== check_param_handler get SIGUSR1\n");
>  175     bool active = true;
>  176     mallctl("opt.prof_active", NULL, NULL, &active, sizeof(bool));
>  177     active = true;
>  178     mallctl("prof.active", NULL, NULL, &active, sizeof(bool));
>  179     mallctl("prof.dump", NULL, NULL, NULL, 0);
>  180

3. gameserver启动的时候，设置环境变量MALLOC\_CONF和LD\_PRELOAD，注意这里设置的LD\_PRELOAD要指向我们新编译出来的jemalloc库， 如下：  
> export LD_PRELOAD=/data/rent_server/ver1.4/bin/libjemalloc.so; 
> export MALLOC_CONF=prof:true,prof_active:false,prof_prefix:/data/rent_server/ver1.4/bin/proflog/jeprof.out

4. 观察gameserver进程，在需要的时候发送SIGUSR1信号给对应进程，进程会自动在prof\_prefix下生成快照文件，并且序号自动递增

5. 使用jeprof对两个快照文件进行分析，生成对应的dot文件, 命令如下
> ./jeprof --dot ./iworldpcserver --base=proflog/jeprof.out.932.0.m0.heap proflog/jeprof.out.932.3.m3.heap > 1.dot

6. 使用工具把dot文件转成其他格式的图片文件，比如用dot命令生成svg文件，命令如下：
> dot -Tsvg 1.dot -o 1.svg
