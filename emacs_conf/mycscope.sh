#!/bin/sh
find . -type f -name "*.[hc]pp" > cscope.files
find . -type f -name "*.[hc]" >> cscope.files
find . -type f -name "*.js" >> cscope.files
find . -type f -name "*.lua" >> cscope.files
cscope -bq
~/.emacs.conf/create_tags_file.sh < cscope.files

