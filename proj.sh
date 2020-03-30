#!/bin/bash
# rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake
rm -rf .ccls-cache
rm -rf tmpbuild
sh ~/.emacs.conf/mycscope.sh
~/gitroot/setting/create_cmake.sh > CMakeLists.txt
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -Btmpbuild .
cp tmpbuild/compile_commands.json .
~/gitroot/setting/create_ccls.sh > .ccls
if [ ${#} -gt 0 ]
then
    ccls --index=.    
fi



