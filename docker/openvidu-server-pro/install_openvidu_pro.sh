#!/usr/bin/env bash

OPENVIDU_VERSION=v2.13.0
DOCKER_COMPOSE_FOLDER=openvidu
AWS_SCRIPTS_FOLDER=${DOCKER_COMPOSE_FOLDER}/cluster/aws
ELASTICSEARCH_FOLDER=${DOCKER_COMPOSE_FOLDER}/elasticsearch

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
mkdir -p ${AWS_SCRIPTS_FOLDER}

# Create elasticsearch folder
mkdir -p ${ELASTICSEARCH_FOLDER}
chown 1000:1000 ${ELASTICSEARCH_FOLDER}

# Download necessaries files
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/cluster/aws/openvidu_autodiscover.sh \
     --output ${AWS_SCRIPTS_FOLDER}/openvidu_autodiscover.sh
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/cluster/aws/openvidu_drop.sh \
     --output ${AWS_SCRIPTS_FOLDER}/openvidu_drop.sh
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/cluster/aws/openvidu_launch_kms.sh \
     --output ${AWS_SCRIPTS_FOLDER}/openvidu_launch_kms.sh

curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/.env \
     --output ${DOCKER_COMPOSE_FOLDER}/.env
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/docker-compose.override.yml \
     --output ${DOCKER_COMPOSE_FOLDER}/docker-compose.override.yml
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/docker-compose.yml \
     --output ${DOCKER_COMPOSE_FOLDER}/docker-compose.yml
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/openvidu \
    --output ${DOCKER_COMPOSE_FOLDER}/openvidu
curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${OPENVIDU_VERSION}/docker/openvidu-server-pro/readme.md \
    --output ${DOCKER_COMPOSE_FOLDER}/readme.md

# Add execution permissions
chmod +x ${AWS_SCRIPTS_FOLDER}/openvidu_autodiscover.sh
chmod +x ${AWS_SCRIPTS_FOLDER}/openvidu_drop.sh
chmod +x ${AWS_SCRIPTS_FOLDER}/openvidu_launch_kms.sh
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
printf '\n   2. Configure OPENVIDU_DOMAIN_OR_PUBLIC_IP, OPENVIDU_PRO_LICENSE, OPENVIDU_SECRET, and KIBANA_PASSWORD in .env file:'
printf "\n   $ nano .env" 
printf "\n"
printf '\n   3. Start OpenVidu'
printf '\n   $ ./openvidu start'
printf '\n'
printf "\n   CAUTION: The folder 'openvidu/elasticsearch' use user and group 1000 permissions. This folder is necessary for store elasticsearch data."
printf '\n   For more information, check readme.md'
printf '\n'
printf '\n'
exit 0
