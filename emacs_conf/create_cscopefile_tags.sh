#!/bin/bash
rm -f TAGS
for line in `cat cscope.files`
do
    # echo "read name = ${line}"
    ctags -ea ${line}
done
gtags -i -f cscope.files
