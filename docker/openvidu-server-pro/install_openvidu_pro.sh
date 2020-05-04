#!/usr/bin/env bash

OPENVIDU_VERSION=master
DOCKER_COMPOSE_FOLDER=openvidu
AWS_SCRIPTS_FOLDER=${DOCKER_COMPOSE_FOLDER}/cluster/aws
ELASTICSEARCH_FOLDER=${DOCKER_COMPOSE_FOLDER}/elasticsearch

# Check docker and docker-compose installation
if ! command -v docker > /dev/null; then
     echo "You don't have docker installed, please install it and re-run the command"
     exit 0
fi

if ! command -v docker-compose > /dev/null; then
     echo "You don't have docker-compose installed, please install it and re-run the command"
     exit 0
else
     COMPOSE_VERSION=$(docker-compose version --short | sed "s/-rc[0-9]*//")
     if ! printf '%s\n%s\n' "1.24" "$COMPOSE_VERSION" | sort -V -C; then
          echo "You need a docker-compose version equal or higher than 1.24, please update your docker-compose and re-run the command"; \
          exit 0
     fi
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
printf '\n   2. Configure DOMAIN_OR_PUBLIC_IP, OPENVIDU_PRO_LICENSE, OPENVIDU_SECRET, and KIBANA_PASSWORD in .env file:'
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
