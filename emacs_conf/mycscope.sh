#!/bin/sh
cd `dirname $0`
find . -type f -name "*.[hc]pp" > cscope.files
find . -type f -name "*.[hc]" >> cscope.files
cscope -bq
~/.emacs.conf/create_tags_file.sh < cscope.files

