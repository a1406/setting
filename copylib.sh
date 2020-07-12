#!/bin/bash
cmd=/usr/bin/emacs
alibs=`cat /tmp/1.log | sed 's/^\t\([^ ]*\) .*$/\1/g'`
for alib in ${alibs}  
do
    t1=`ldd ${cmd} | grep ${alib} | sed 's/\(^[^ ]*\) => \([^ ]*\) .*$/cp \2 \1/g'`
    echo "${t1}"
    bash -c "${t1}"
done  

