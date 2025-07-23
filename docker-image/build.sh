#!/bin/bash

DOCKER_TAG=0.1

docker rmi slackluis/samba:${DOCKER_TAG}
docker build -t slackluis/samba:${DOCKER_TAG} .
