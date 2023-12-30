#!/bin/sh
find -P . -type f -name "*.lua" | grep -v CMakeFiles | grep -v "ccls-cache"  > cscope.files
cp cscope.files rg.files
sed -i 's/\.\/\(.*\)/--glob=\1/g' rg.files 
