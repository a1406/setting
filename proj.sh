#!/bin/bash
rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake
rm -rf .ccls-cache
sh ~/.emacs.conf/mycscope.sh
~/gitroot/setting/create_cmake.sh > CMakeLists.txt
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .
~/gitroot/setting/create_ccls.sh > .ccls
ccls --index=.

