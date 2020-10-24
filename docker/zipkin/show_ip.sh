#!/bin/bash
# all=`docker-compose -f ~/gitroot/setting/docker/kafka/docker-compose.yml ps | grep kafka_kafka | sed 's/^\(kafka_kafka[0-9_]*\).*/\1/g'`
all=`docker-compose -f docker-compose.yml ps | grep zipkin_zipkin | sed 's/^\(zipkin_zipkin[0-9_]*\).*/\1/g'`
for i in $all
do
    # echo "i = $i"
    addr=`docker inspect $i | grep 'IPAddress": "[0-9.]+*' | sed 's/[^0-9.]//g'`
    host=`docker inspect $i | grep "Hostname\"" | sed 's/^.*"Hostname": "\(.*\)",/\1/g'`
    echo "$addr $host"
done
