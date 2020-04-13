#!/usr/bin/env bash

MEDIA_NODE_VERSION=master
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
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/nginx_conf/kms-recorder.conf \
     --output ${NGINX_CONF}/kms-recorder.conf
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/nginx_conf/nginx.conf \
     --output ${NGINX_CONF}/nginx.conf

curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/.env \
     --output ${DOCKER_COMPOSE_FOLDER}/.env
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/docker-compose.yml \
     --output ${DOCKER_COMPOSE_FOLDER}/docker-compose.yml
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/media_node \
     --output ${DOCKER_COMPOSE_FOLDER}/media_node

# Add execution permissions
chmod +x ${DOCKER_COMPOSE_FOLDER}/media_node

# Ready to use
printf "\n========================================"
printf "\nMedia Node has successfully installed."
printf '\nNow run "./media_node.sh start" in folder "media_node" for setup.'
printf '\nRun "./media_node.sh help" in folder for more information about "media_node" command.'
exit 0
