#!/bin/sh
find . -type f -name "*.[hc]pp" | grep -v CMakeFiles > cscope.files
find . -type f -name "*.[hc]" | grep -v CMakeFiles >> cscope.files
find . -type f -name "*.[jt]s" | grep -v CMakeFiles >> cscope.files
find . -type f -name "*.lua" | grep -v CMakeFiles >> cscope.files
find . -type f -name "*.php" | grep -v CMakeFiles >> cscope.files
dos2unix `cat cscope.files` >/dev/null 2>/dev/null
cscope -bq
#~/.emacs.conf/create_tags_file.sh < cscope.files
