#!/bin/sh
while read name
do
#    echo "read name = ${name}"
    ctags -ea ${name}
done
