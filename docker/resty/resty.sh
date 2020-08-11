#!/bin/sh
docker run -it -d --name resty --mount type=bind,source=/home/jack/docker-test/sharedata/lua,target=/usr/local/openresty/nginx/lua openresty/openresty
