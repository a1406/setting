#!/bin/bash
for line in `cat cscope.files`
do
    # echo "read name = ${line}"
    ctags -ea ${line}
done
