#!/bin/sh

# Stop all containers
docker kill $(docker ps -q -a)

# Delete all stopped containers
docker rm $(docker ps -a -q)

# Delete all untagged/dangling images
docker rmi $(docker images -q -f dangling=true)

# Delete ALL images
docker rmi $(docker images -a -q)

# Delete volumes
docker volume rm $(docker volume ls -qf dangling=true)
docker volume rm $(docker volume ls -q)

# Little pruning
docker system prune --volumes -a -f
docker volume prune -f
docker system prune -a -f
