#!/bin/bash
find -L . -type f -name "*.go" > cscope.files
find -L . -type f -name "*.proto" >> cscope.files
find -L . -type f -name "*.yaml" >> cscope.files
find -L . -type f -name "*.json" >> cscope.files
cp cscope.files rg.files
sed -i 's/\.\/\(.*\)/--glob=\1/g' rg.files 
gogtags -v 
