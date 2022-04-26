#!/bin/sh

docker build --no-cache -t registry.2le.net/2le/[PROJET]:dbtest .
docker push registry.2le.net/2le/[PROJET]:dbtest
