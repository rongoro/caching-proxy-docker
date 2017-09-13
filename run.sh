#!/bin/bash

IMAGENAME="caching_proxy_docker"

HASIMAGE=`docker images | grep $IMAGENAME`

echo $1

if [[ $1 == "rebuild" || ! $HASIMAGE ]] ; then
   docker build -t $IMAGENAME .
fi

docker run -p 8888:8888 $IMAGENAME
