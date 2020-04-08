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

DOCKER_COMPOSE_FOLDER=openvidu
AWS_SCRIPTS=${DOCKER_COMPOSE_FOLDER}/aws

# Create openvidu-docker-compose folder
mkdir ${DOCKER_COMPOSE_FOLDER}

# Create aws scripts folder
mkdir ${AWS_SCRIPTS}

# Download necessaries files
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/openvidu-server-pro/aws/openvidu_autodiscover.sh \
     --output ${AWS_SCRIPTS}/openvidu_autodiscover.sh
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/openvidu-server-pro/aws/openvidu_drop.sh \
     --output ${AWS_SCRIPTS}/openvidu_drop.sh
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/openvidu-server-pro/aws/openvidu_launch_kms.sh \
     --ouput ${AWS_SCRIPTS}/openvidu_launch_kms.sh

curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/openvidu-server-pro/.env \
     --output ${DOCKER_COMPOSE_FOLDER}/.env
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/openvidu-server-pro/docker-compose.override.yml \
     --output ${DOCKER_COMPOSE_FOLDER}/docker-compose.override.yml
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/openvidu-server-pro/docker-compose.yml \
     --output ${DOCKER_COMPOSE_FOLDER}/docker-compose.yml
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/deploy-with-docker/docker/openvidu-server-pro/openvidu.sh \
    --output ${DOCKER_COMPOSE_FOLDER}/openvidu.sh

# Add execution permissions
chmod +x ${DOCKER_COMPOSE_FOLDER}/openvidu.sh

# Create own certificated folder
mkdir ${DOCKER_COMPOSE_FOLDER}/owncert

# Ready to use
printf "\n========================================"
printf "\nOpenvidu CE has successfully installed."
printf '\nNow run "./openvidu.sh start" in folder "openvidu" for setup.'
printf '\nRun "./openvidu.sh help" in folder for more information about "openvidu" command.'
printf '\n"Check "readme.md" in folder "openvidu" for more details.\n\n'
exit 0
