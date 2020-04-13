#!/usr/bin/env bash

OPENVIDU_VERSION=master
DOCKER_COMPOSE_FOLDER=openvidu
AWS_SCRIPTS=${DOCKER_COMPOSE_FOLDER}/aws

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

# Create aws scripts folder
mkdir ${AWS_SCRIPTS}

# Download necessaries files
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/aws/openvidu_autodiscover.sh \
     --output ${AWS_SCRIPTS}/openvidu_autodiscover.sh
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/aws/openvidu_drop.sh \
     --output ${AWS_SCRIPTS}/openvidu_drop.sh
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/aws/openvidu_launch_kms.sh \
     --output ${AWS_SCRIPTS}/openvidu_launch_kms.sh

curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/.env \
     --output ${DOCKER_COMPOSE_FOLDER}/.env
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/docker-compose.override.yml \
     --output ${DOCKER_COMPOSE_FOLDER}/docker-compose.override.yml
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/docker-compose.yml \
     --output ${DOCKER_COMPOSE_FOLDER}/docker-compose.yml
curl https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/openvidu \
    --output ${DOCKER_COMPOSE_FOLDER}/openvidu

# Add execution permissions
chmod +x ${AWS_SCRIPTS}/openvidu_autodiscover.sh
chmod +x ${AWS_SCRIPTS}/openvidu_drop.sh
chmod +x ${AWS_SCRIPTS}/openvidu_launch_kms.sh
chmod +x ${DOCKER_COMPOSE_FOLDER}/openvidu

# Create own certificated folder
mkdir ${DOCKER_COMPOSE_FOLDER}/owncert

# Ready to use
printf "\n"
printf "\n   Openvidu PRO successfully installed."
printf "\n"
printf '\n   1. Go to openvidu folder:'
printf '\n   $ cd openvidu'
printf "\n"
printf '\n   2. Configure OPENVIDU_DOMAIN_OR_PUBLIC_IP, OPENVIDU_SECRET, OPENVIDU_PRO_CLUSTER_MEDIA-NODES and KIBANA_PASSWORD in .env file:'
printf "\n   $ nano .env" 
printf "\n"
printf '\n   3. Start OpenVidu'
printf '\n   $ ./openvidu start'
printf '\n'
printf '\n   For more information, check readme.md'
printf '\n'
printf '\n'
exit 0
