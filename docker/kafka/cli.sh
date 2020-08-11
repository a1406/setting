#!/bin/bash
docker run -u root -it --rm --mount type=bind,source=/home/jack/docker-test/sharedata,target=/mnt/sharedata --network zookeeper-cluster_default bitnami/kafka:latest bash
