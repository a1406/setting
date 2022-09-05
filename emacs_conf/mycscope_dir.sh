#!/bin/sh
dir=${1}
cwd=`pwd`
find -P ${dir} -type f -name "*.[hc]pp" | grep -v CMakeFiles | grep -v "ccls-cache" | grep -v "to_lua.cpp" > cscope.files
find -P ${dir} -type f -name "*.[hc]" | grep -v CMakeFiles | grep -v "ccls-cache" | grep -v ".*\.pb\.h" | grep -v ".*\.pb-c\.[hc]"  >> cscope.files
find -P ${dir} -type f -name "*.cc" | grep -v CMakeFiles | grep -v "ccls-cache" | grep -v ".*\.pb\.cc" | grep -v ".*\.pb-c\.[hc]"  >> cscope.files
find -P ${dir} -type f -name "*.[jt]s" | grep -v CMakeFiles | grep -v "ccls-cache"  >> cscope.files
find -P ${dir} -type f -name "*.lua" | grep -v CMakeFiles | grep -v "ccls-cache"  >> cscope.files
find -P ${dir} -type f -name "*.php" | grep -v CMakeFiles | grep -v "ccls-cache"  >> cscope.files
find -P ${dir} -type f -name "*.proto" | grep -v CMakeFiles | grep -v "ccls-cache"  >> cscope.files
find -P ${dir} -type f -name "*.java" | grep -v CMakeFiles | grep -v "ccls-cache"  >> cscope.files
find -P ${dir} -type f -name "*.scala" | grep -v CMakeFiles | grep -v "ccls-cache"  >> cscope.files
find -P ${dir} -type f -name "*.go" | grep -v CMakeFiles | grep -v "ccls-cache"  >> cscope.files
# #dos2unix `cat cscope.files` >/dev/null 2>/dev/null
# #cscope -bq
gtags -i -f cscope.files
cp cscope.files rg.files
# sed -i 's/${dir}\/\(.*\)/--glob=\1/g' rg.files
sed -i 's/\(.*\)/--glob=\1/g' rg.files 
