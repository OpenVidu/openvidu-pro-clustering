#!/usr/bin/env bash

MEDIA_NODE_VERSION=v2.13.0
DOCKER_COMPOSE_FOLDER=kms
NGINX_CONF=${DOCKER_COMPOSE_FOLDER}/nginx_conf

# Check docker and docker-compose installation
docker -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
     echo "You don't have docker installed, please install it and re-run the command"
     exit 0
fi

docker-compose -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
     echo "You don't have docker-compose installed, please install it and re-run the command"
     exit 0
fi

# Create openvidu-docker-compose folder
mkdir ${DOCKER_COMPOSE_FOLDER}

# Create kms folder
mkdir ${NGINX_CONF}

# Download necessaries files
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/nginx_conf/kms-recorder.conf \
     --output ${NGINX_CONF}/kms-recorder.conf
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/nginx_conf/nginx.conf \
     --output ${NGINX_CONF}/nginx.conf

curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/.env \
     --output ${DOCKER_COMPOSE_FOLDER}/.env
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/docker-compose.yml \
     --output ${DOCKER_COMPOSE_FOLDER}/docker-compose.yml
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/media_node \
     --output ${DOCKER_COMPOSE_FOLDER}/media_node
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/readme.md \
     --output ${DOCKER_COMPOSE_FOLDER}/readme.md

# Add execution permissions
chmod +x ${DOCKER_COMPOSE_FOLDER}/media_node


# Ready to use
printf "\n"
printf "\n   Media Node successfully installed."
printf "\n"
printf '\n   1. Go to kms folder:'
printf '\n   $ cd kms'
printf "\n"
printf '\n   2. Start KMS'
printf '\n   $ ./media_node start'
printf '\n'
printf '\n   For more information, check readme.md'
printf '\n'
printf '\n'
exit 0
