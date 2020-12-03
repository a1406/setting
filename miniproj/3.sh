#!/bin/bash

echo "CMAKE_MINIMUM_REQUIRED(VERSION 2.8)"
echo "project(XGame)"

echo "set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} \"./cmake/\")"

echo ""

filtercmd=" | grep -v \"^\./tools/\" | grep -v \"^\./client/external/\" | grep -v \"^\./client/miniEngineSDK/\" | grep -v CMakeFiles | grep -v \"ccls-cache\" | grep -v \"to_lua.cpp\" | grep -v \".*\.pb\.h\" | grep -v \".*\.pb-c\.[hc]\" "

cmd="cat cscope2.files | grep '.*\.h$' ${filtercmd} | xargs dirname | sort | uniq"
# echo "cmd = ${cmd}"
allfiles=`eval ${cmd}`
for t in ${allfiles}
do
    echo "INCLUDE_DIRECTORIES(\"\${PROJECT_SOURCE_DIR}/${t}\")"
done

cmd="cat cscope2.files | grep '.*\.cpp$' ${filtercmd}"
allfiles=`eval ${cmd}`
for src in ${allfiles}
do
    echo "    LIST(APPEND SRC_LIST2 ${src})"
done

cmd="cat cscope2.files | grep '.*\.cc$' ${filtercmd}"
allfiles=`eval ${cmd}`
for src in ${allfiles}
do
    echo "    LIST(APPEND SRC_LIST2 ${src})"
done

echo "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY \${CMAKE_CURRENT_SOURCE_DIR})"
echo "add_executable  (game_srv \${SRC_LIST2})"


