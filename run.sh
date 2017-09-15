#!/bin/bash

IMAGENAME="caching_proxy_docker"

HASIMAGE=`docker images | grep $IMAGENAME`
DOCKERLABEL="localhost.job_type=caching_http_proxy"
PORT=8080

WORKINGDIR=$(dirname $(realpath $0))

function usage() {
    echo "Manage an cahing HTTP proxy and http_proxy environment variable"
    echo "$0 (start|stop|status|info|rebuild)"
}

function rebuild() {
    docker build -t $IMAGENAME --label "$DOCKERLABEL" $WORKINGDIR
}

function getImage() {
    docker images --filter "label=$DOCKERLABEL" --format "{{.ID}}"
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
    CID=`getContainer`
    if [[ "$CID" != "" ]] ; then
        echo "Already running."
        info
        return 2
    fi

    if [[ `getImage` == "" ]] ; then
        rebuild
    fi
    CID=`docker run -d -p $PORT:$PORT -l "$DOCKERLABEL" $IMAGENAME`
    info
}


function stop() {
    CID=`getContainer`
    if [[ "$CID" == "" ]] ; then
        # We didn't technically stop anything so return a non-zero
        # value
        return 2
    fi
    docker rm -f $CID
}

function cleanAll() {
    stop
    IID=`getImage`
    if [[ "$IID" != "" ]] ; then
        docker rmi $IID
    fi
}
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
    "clean-all" )
        cleanAll
        ;;
    *)
        echo "Invalid Argument: $*"
        usage
        exit 1;;
esac
