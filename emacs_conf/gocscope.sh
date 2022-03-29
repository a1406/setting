#!/bin/bash
find -L . -type f -name "*.go" > cscope.files
cp cscope.files rg.files
sed -i 's/\.\/\(.*\)/--glob=\1/g' rg.files 
gogtags -v 
