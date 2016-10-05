CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
project(HELLO)
#set(SRC_LIST mem_pool.cpp)
#aux_source_directory (. SRC_LIST)
#set(SRC_LIST ${SRC_LIST} include/*.h)
#set(SRC_LIST ${SRC_LIST} ../comm_include/*.h)
FILE(GLOB_RECURSE SRC_LIST
#  "include/*.h"
#  "../comm_include/*.h"
  "./*.cpp"
  )

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0")
add_definitions(-Wall -g -O0 -fstack-protector-all)
INCLUDE_DIRECTORIES("../comm_include"
  "include"
  "../thirdlib/libevent-2.0.21-stable/include"
  "../thirdlib/log4c-1.2.1/src"
  "../thirdlib/libevent-2.0.21-stable"
  )

execute_process (
  COMMAND echo "tangpeilei ${SRC_LIST}"
  )

add_library  (hello ${SRC_LIST})

