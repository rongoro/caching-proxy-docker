# caching-proxy-docker

Small tool for building and running a caching HTTP proxy under docker

## Problem this is trying to solve

The impetus was that I was repeatedly rebuilding docker and virtualbox
images that would result in repeatedly downloading the same software
packages. There are a few solutions but a generic large http cache
that could be reused for other cases as well seemed like a useful
little tool and I didn't find one.

## Design Choices

There are multiple ways this could have been done. The goal was to
have a single command that would start a working caching http forward
proxy and return a proxy URL. This url would be suitable for
environment variables or passing along to commands.

Also, I wanted a real http proxy, because of its flexibility and its
behavior is well understood. There are caches specifically designed
for package managers, for example, but I didn't want to be limited to
the one application.

I couldn't find a simple caching forward proxy that wouldn't require
global installation. Something like a single python file that extends
simple SimpleHTTPServer. So, I used a hammer and set up nginx in a
Ubuntu based docker container. Squid configuration wasn't as simple as
I would have liked and I was already familiar with how to setup nginx
on Ubuntu.

This all could be done better or just differently, but this was fast and easy.

## Example Usage

The hashes and stuff may differ for you.

```
$ ./caching-proxy-docker start
Sending build context to Docker daemon 166.4 kB
Step 1 : FROM ubuntu:rolling
 ---> bde41be8de8c
Step 2 : RUN apt update && apt install -y nginx
 ---> Running in fcab203885f5

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Get:1 http://security.ubuntu.com/ubuntu zesty-security InRelease [89.2 kB]
Get:2 http://archive.ubuntu.com/ubuntu zesty InRelease [243 kB]
Get:3 http://archive.ubuntu.com/ubuntu zesty-updates InRelease [89.2 kB]
Get:4 http://archive.ubuntu.com/ubu.....

.... [ REDACTED FOR BREVITY ]

Removing intermediate container dc3db2f93979
Successfully built a96bb7eff047
http://172.17.0.2:8080

$ ./caching-proxy-docker info
http://172.17.0.2:8080

$ ./caching-proxy-docker stop
fce126dd29f6
```


## How do you know it works?

One test would be to do:
```
$ ./caching-proxy-docker clean-all
$ time ./caching-proxy-docker rebuild
(note the time)
$ ./caching-proxy-docker start
$ time ./caching-proxy-docker build-with-cache
(note that the time is faster than the previous time)

or:

$ ./caching-proxy-docker start
$ http_proxy=`./caching-proxy-docker info` curl -I http://example.com
HTTP/1.1 200 OK
Server: nginx/1.10.3 (Ubuntu)
... [ REDATED FOR BREVITY ]
X-Proxied-Response: True
```
Note that the proxy adds the X-Proxied-Response header to the response. This is
basically what `./caching-proxy-docker run-test` does as well.
