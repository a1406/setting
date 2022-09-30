#!/bin/sh
FILE=""
DIR=""
while getopts "f:d:" arg
do
    case $arg in
	f)
	    # echo "f's arg:$OPTARG"
	    FILE=$OPTARG
	    ;;
	d)
	    # echo "d's arg:$OPTARG"
	    DIR=$OPTARG
	    ;;
    esac
done

if [[ ! -x $FILE ]];
then
    echo "file ${FILE} can not exe"
    exit 1
fi   
if [[ ! -d $DIR ]];
then
    echo "dir ${DIR} can not exist"
    exit 1    
fi   

ldd ${FILE} | grep '=>' | awk '{printf("cp %s '$DIR'\n", $3)}' | /bin/sh
cp ${FILE} $DIR
