The goal of this project is to produce a docker image of an caching
HTTP proxy that is easy to build and deploy.

The impetus was that I was repeatedly rebuilding docker and virtualbox
images that would result in repeatedly downloading the same software
packages. There are a few solutions but a generic large http cache
that could be reused for other cases as well seemed like a useful
tool.