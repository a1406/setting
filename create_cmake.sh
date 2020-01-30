#!/bin/bash

echo "CMAKE_MINIMUM_REQUIRED(VERSION 2.8)"
echo "project(XGame)"

echo "set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} \"./cmake/\")"

echo ""

echo "FILE(GLOB_RECURSE SRC_LIST"
echo "     \"*.cpp\""
echo "     \"*.c\""
echo "     \"*.cc\""
echo "  )"

echo ""

inc=`find . -type f -name "*.h" | grep -v '\.ccls-cache'  | xargs dirname | sort | uniq`
for t in ${inc}
do
    echo "INCLUDE_DIRECTORIES(\"\${PROJECT_SOURCE_DIR}/${t}\")"
done

echo ""

echo "FOREACH(src \${SRC_LIST})"
echo "  IF(NOT (src MATCHES \".*[.]ccls-cache.*\") AND NOT(src MATCHES \".*/CMakeFiles/.*\"))"
echo "    LIST(APPEND SRC_LIST2 \${src})"
echo "  ENDIF()"
echo "ENDFOREACH()"

echo "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY \${CMAKE_CURRENT_SOURCE_DIR})"
echo "add_executable  (game_srv \${SRC_LIST2})"

