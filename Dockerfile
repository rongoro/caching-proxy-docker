FROM ubuntu:rolling

WORKDIR /working

ADD . /working

RUN apt update && apt install -y nginx
