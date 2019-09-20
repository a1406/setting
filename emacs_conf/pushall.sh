#!/bin/bash
pushall=(`git remote`)
# echo "$pushall"
for remote in ${pushall[*]}
do
    git push ${remote}
done
