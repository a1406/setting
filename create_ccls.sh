#!/bin/bash

echo "clang"
echo "%c -std=c11"
echo "%cpp -std=c++17"
echo "%h -x c++-header"

pwd=`pwd`
inc=`find . -type f -name "*.h" | grep -v '\.ccls-cache'  | xargs dirname | uniq`
for t in ${inc}
do
    echo "-I${pwd}/${t}"
done
