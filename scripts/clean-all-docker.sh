#!/bin/sh

# Stop all containers
docker kill $(docker ps -q)

# Delete all stopped containers
docker rm $(docker ps -a -q)

# Delete all untagged/dangling images
docker rmi $(docker images -q -f dangling=true)

# Delete ALL images
docker rmi $(docker images -q)
