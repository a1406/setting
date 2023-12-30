#!/bin/sh
find -P . -type f -name "*.[hc]pp" | grep -v CMakeFiles | grep -v "ccls-cache" | grep -v "to_lua.cpp" > cscope.files
find -P . -type f -name "*.[hc]" | grep -v CMakeFiles | grep -v "ccls-cache" | grep -v ".*\.pb\.h" | grep -v ".*\.pb-c\.[hc]"  >> cscope.files
find -P . -type f -name "*.cc" | grep -v CMakeFiles | grep -v "ccls-cache" | grep -v ".*\.pb\.cc" | grep -v ".*\.pb-c\.[hc]"  >> cscope.files
find -P . -type f -name "*.lua" | grep -v CMakeFiles | grep -v "ccls-cache"  >> cscope.files
cp cscope.files rg.files
sed -i 's/\.\/\(.*\)/--glob=\1/g' rg.files 
