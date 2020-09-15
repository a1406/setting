#!/bin/bash
docker run -u root -it --rm --mount type=bind,source=/home/jack/docker-test/sharedata,target=/mnt/sharedata --network kafka_default bitnami/kafka:latest bash
