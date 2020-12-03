#!/bin/bash
find -L . -type f -name "*.[hc]pp" | grep -v "^\./tools/" | grep -v "^\./client/external/" | grep -v "^\./client/miniEngineSDK/" | grep -v CMakeFiles | grep -v "ccls-cache" | grep -v "to_lua.cpp" > cscope2.files
find -L . -type f -name "*.[hc]" | grep -v "^\./tools/" | grep -v "^\./client/external/" | grep -v "^\./client/miniEngineSDK/" | grep -v CMakeFiles | grep -v "ccls-cache" | grep -v ".*\.pb\.h" | grep -v ".*\.pb-c\.[hc]"  >> cscope2.files
cp cscope2.files rg.files
sed -i 's/\.\/\(.*\)/--glob=\1/g' rg.files 
