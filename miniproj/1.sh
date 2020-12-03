#!/bin/bash
find -L . -type f -iname "*.mk"  | grep -v "^\./tools/" | grep -v "^\./client/external/" | grep -v "^\./client/miniEngineSDK/" | grep -v CMakeFiles > cscope.files
find -L . -type f -iname "*.cmake"  | grep -v "^\./tools/" | grep -v "^\./client/external/" | grep -v "^\./client/miniEngineSDK/" | grep -v CMakeFiles >> cscope.files
find -L . -type f -iname "CMakeLists.txt" | grep -v "^\./tools/" | grep -v "^\./client/external/" | grep -v "^\./client/miniEngineSDK/" | grep -v CMakeFiles >> cscope.files
cp cscope.files rg.files
sed -i 's/\.\/\(.*\)/--glob=\1/g' rg.files 
