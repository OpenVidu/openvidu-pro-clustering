#!/usr/bin/env bash

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

DOCKER_COMPOSE_FOLDER=kms
NGINX_CONF=${DOCKER_COMPOSE_FOLDER}/nginx_conf

# Create openvidu-docker-compose folder
mkdir ${DOCKER_COMPOSE_FOLDER}

# Create kms folder
mkdir ${NGINX_CONF}

# Download necessaries files
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/kms/nginx_conf/kms-recorder.conf \
     --output ${NGINX_CONF}/kms-recorder.conf
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/kms/nginx_conf/nginx.conf \
     --output ${NGINX_CONF}/nginx.conf

curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/kms/.env \
     --output ${DOCKER_COMPOSE_FOLDER}/.env
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/kms/docker-compose.yml \
     --output ${DOCKER_COMPOSE_FOLDER}/docker-compose.yml
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/kms/kms.sh \
     --output ${DOCKER_COMPOSE_FOLDER}/kms.sh

# Add execution permissions
chmod +x ${DOCKER_COMPOSE_FOLDER}/kms.sh

# Ready to use
printf "\n========================================"
printf "\nKMS has successfully installed."
printf '\nNow run "./kms.sh start" in folder "kms" for setup.'
printf '\nRun "./kms.sh help" in folder for more information about "kms" command.'
exit 0