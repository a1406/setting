#!/bin/bash

echo "clang"
echo "%c -std=c11"
echo "%cpp -std=c++17"
echo "%h -x c++-header"

pwd=`pwd`
filtercmd=" | grep -v \"^\./tools/\" | grep -v \"^\./client/external/\" | grep -v \"^\./client/miniEngineSDK/\" | grep -v CMakeFiles | grep -v \"ccls-cache\" | grep -v \"to_lua.cpp\" | grep -v \".*\.pb\.h\" | grep -v \".*\.pb-c\.[hc]\" "
cmd="cat cscope2.files | grep '.*\.h$' ${filtercmd} | xargs dirname | sort | uniq"
inc=`eval ${cmd}`
# inc=`find . -type f -name "*.h" | grep -v '\.ccls-cache'  | xargs dirname | uniq`
for t in ${inc}
do
    echo "-I${pwd}/${t}"
done
