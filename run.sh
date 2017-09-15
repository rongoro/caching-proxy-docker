#!/bin/bash

IMAGENAME="caching_proxy_docker"

HASIMAGE=`docker images | grep $IMAGENAME`
DOCKERLABEL="localhost.job_type=caching_http_proxy"
PORT=8080

function usage() {
    echo "Manage an cahing HTTP proxy and http_proxy environment variable"
    echo "$0 (start|stop|status|info|rebuild)"
}

function rebuild() {
   docker build -t $IMAGENAME .
}

function getContainer() {
    docker ps --filter "label=$DOCKERLABEL" --format "{{.ID}}"
}

function status() {
    docker ps --filter "label=$DOCKERLABEL"
}

function info() {
    CID=`getContainer`
    if [[ "$CID" == "" ]] ; then
        echo "Not running."
        return 0
    fi
    PROXYIP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${CID}`
    echo "http://$PROXYIP:$PORT"
}

function start() {
    CID=`docker run -d -p $PORT:$PORT -l "$DOCKERLABEL" $IMAGENAME`
    info
}


function stop() {
    CID=`getContainer`
    docker kill $CID
}

if [[ $# -ne 1 ]] ; then
    echo "Invalid number of arguments."
    usage
    exit 1
fi

COMMAND=$1

VALID_ARGS=(start stop rebuild)


case "$COMMAND" in
    "rebuild" )
        rebuild
        ;;
    "start" )
        start
        ;;
    "stop" )
        stop
        ;;
    "status" )
        status
        ;;
    "info" )
        info
        ;;
    *)
        echo "Invalid Argument: $*"
        usage
        exit 1;;
esac
