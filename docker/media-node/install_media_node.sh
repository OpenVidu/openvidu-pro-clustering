#!/usr/bin/env bash

MEDIA_NODE_FOLDER=kms
MEDIA_NODE_VERSION=master
NGINX_CONF_FOLDER=${MEDIA_NODE_FOLDER}/nginx_conf

fatal_error() {
     printf "\n     =======¡ERROR!======="
     printf "\n     %s" "$1"
     printf "\n"
     exit 0
}

new_media_node_installation() {
     printf '\n'
     printf '\n     ======================================='
     printf '\n          Install Media Node %s' "${MEDIA_NODE_VERSION}"
     printf '\n     ======================================='
     printf '\n'

     # Create kms folder
     printf '\n     => Creating folder '%s'...' "${MEDIA_NODE_FOLDER}"
     mkdir "${MEDIA_NODE_FOLDER}" || fatal_error "Error while creating the folder '${MEDIA_NODE_FOLDER}'"

     # Create nginx folder
     printf "\n     => Creating folder 'nginx_conf'..."
     mkdir "${NGINX_CONF_FOLDER}" || fatal_error "Error while creating the folder 'nginx_conf'"

     # Download necessaries files
     printf '\n     => Downloading Media Node files:'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/docker-compose.yml \
          --output "${MEDIA_NODE_FOLDER}/docker-compose.yml" || fatal_error "Error when downloading the file 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/.env \
          --output "${MEDIA_NODE_FOLDER}/.env" || fatal_error "Error when downloading the file '.env'"
     printf '\n          - .env'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/media_node \
          --output "${MEDIA_NODE_FOLDER}/media_node" || fatal_error "Error when downloading the file 'media_node'"
     printf '\n          - media_node'
     
     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/readme.md \
          --output "${MEDIA_NODE_FOLDER}/readme.md" || fatal_error "Error when downloading the file 'readme.md'"
     printf '\n          - readme.md'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/nginx_conf/kms-recorder.conf \
          --output "${NGINX_CONF_FOLDER}/kms-recorder.conf" || fatal_error "Error when downloading the file 'kms-recorder.conf'"
     printf '\n          - kms-recorder.conf'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/nginx_conf/nginx.conf \
          --output "${NGINX_CONF_FOLDER}/nginx.conf" || fatal_error "Error when downloading the file 'nginx.conf'"
     printf '\n          - nginx.conf'

     # Add execution permissions
     printf "\n     => Adding permission to 'media_node' program..."
     chmod +x "${MEDIA_NODE_FOLDER}/media_node" || fatal_error "Error while adding permission to 'media_node' program"

     # Ready to use
     printf "\n"
     printf '\n     ======================================='
     printf "\n          Media Node successfully installed."
     printf '\n     ======================================='
     printf "\n"
     printf '\n     1. Go to kms folder:'
     printf '\n     $ cd kms'
     printf "\n"
     printf '\n     2. Start KMS'
     printf '\n     $ ./media_node start'
     printf '\n'
     printf '\n     For more information, check readme.md'
     printf '\n'
     printf '\n'
     exit 0
}

upgrade_media_node() {
 # Search local Openvidu installation
     printf '\n'
     printf '\n     ============================================'
     printf '\n      Search Previous Installation of Media Node'
     printf '\n     ============================================'
     printf '\n'

     SEARCH_IN_FOLDERS=(
          "." 
          "/opt/kms"
     )

     for folder in "${SEARCH_IN_FOLDERS[@]}"; do
          printf "\n     => Searching in '%s' folder..." "${folder}"

          if [ -f "${folder}/docker-compose.yml" ]; then
               MEDIA_NODE_PREVIOUS_FOLDER="${folder}"

               printf "\n     => Found installation in folder '%s'" "${folder}"
               break
          fi
     done

     [ -z "${MEDIA_NODE_PREVIOUS_FOLDER}" ] && fatal_error "No previous Media Node installation found"

     # Uppgrade Media Node
     OPENVIDU_PREVIOUS_VERSION=$(grep 'Openvidu Version:' "${MEDIA_NODE_PREVIOUS_FOLDER}/docker-compose.yml" | awk '{ print $4 }')
     [ -z "${OPENVIDU_PREVIOUS_VERSION}" ] && OPENVIDU_PREVIOUS_VERSION=2.13.0

     # In this point using the variable 'OPENVIDU_PREVIOUS_VERSION' we can verify if the upgrade is 
     # posible or not. If it is not posible launch a warning and stop the upgrade.

     printf '\n'
     printf '\n     ======================================='
     printf '\n       Upgrade Media Node %s to %s' "${OPENVIDU_PREVIOUS_VERSION}" "${MEDIA_NODE_VERSION}"
     printf '\n     ======================================='
     printf '\n'

     ROLL_BACK_FOLDER="${MEDIA_NODE_PREVIOUS_FOLDER}/.old-${OPENVIDU_PREVIOUS_VERSION}"
     TMP_FOLDER="${MEDIA_NODE_PREVIOUS_FOLDER}/tmp"

     printf "\n     Creating roll back folder '%s'..." ".old-${OPENVIDU_PREVIOUS_VERSION}"
     mkdir "${ROLL_BACK_FOLDER}" || fatal_error "Error while creating the folder '.old-${OPENVIDU_PREVIOUS_VERSION}'"

     printf "\n     Creating temporal folder 'tmp'..."
     mkdir "${TMP_FOLDER}" || fatal_error "Error while creating the folder 'temporal'"

     # Download necessaries files
     printf '\n     => Downloading new Media Node files:'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/docker-compose.yml \
          --output "${TMP_FOLDER}/docker-compose.yml" || fatal_error "Error when downloading the file 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/.env \
          --output "${TMP_FOLDER}/.env" || fatal_error "Error when downloading the file '.env'"
     printf '\n          - .env'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/media_node \
          --output "${TMP_FOLDER}/media_node" || fatal_error "Error when downloading the file 'media_node'"
     printf '\n          - media_node'
     
     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/readme.md \
          --output "${TMP_FOLDER}/readme.md" || fatal_error "Error when downloading the file 'readme.md'"
     printf '\n          - readme.md'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/nginx_conf/kms-recorder.conf \
          --output "${TMP_FOLDER}/kms-recorder.conf" || fatal_error "Error when downloading the file 'kms-recorder.conf'"
     printf '\n          - kms-recorder.conf'

     curl --silent https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}/docker/media-node/nginx_conf/nginx.conf \
          --output "${TMP_FOLDER}/nginx.conf" || fatal_error "Error when downloading the file 'nginx.conf'"
     printf '\n          - nginx.conf'

     # Dowloading new images and stoped actual Media Node
     printf '\n     => Dowloading new images...'
     printf '\n'
     sleep 1

     [ -f "${TMP_FOLDER}/docker-compose.yml" ] && docker-compose -f "${TMP_FOLDER}/docker-compose.yml" pull
     
     printf '\n     => Stoping Media Node...'
     printf '\n'
     sleep 1

     docker-compose -f "${MEDIA_NODE_PREVIOUS_FOLDER}/docker-compose.yml" down
     printf '\n'

     # Move old files to roll back folder
     printf '\n     => Moving previous installation files to rollback folder:'

     mv "${MEDIA_NODE_PREVIOUS_FOLDER}/docker-compose.yml" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     mv "${MEDIA_NODE_PREVIOUS_FOLDER}/media_node" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous 'openvidu'"
     printf '\n          - media_node'

     mv "${MEDIA_NODE_PREVIOUS_FOLDER}/readme.md" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous 'readme.md'"
     printf '\n          - readme.md'

     mv "${MEDIA_NODE_PREVIOUS_FOLDER}/nginx_conf" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous 'nginx_conf'"
     printf '\n          - nginx_conf'

     # Move tmp files to Openvidu
     printf '\n     => Updating files:'

     mv "${TMP_FOLDER}/docker-compose.yml" "${MEDIA_NODE_PREVIOUS_FOLDER}" || fatal_error "Error while updating 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     mv "${TMP_FOLDER}/.env" "${MEDIA_NODE_PREVIOUS_FOLDER}/.env-${MEDIA_NODE_VERSION}" || fatal_error "Error while moving previous '.env'"
     printf '\n          - .env-%s' "${MEDIA_NODE_VERSION}"

     mv "${TMP_FOLDER}/media_node" "${MEDIA_NODE_PREVIOUS_FOLDER}" || fatal_error "Error while updating 'media_node'"
     printf '\n          - media_node'

     mv "${TMP_FOLDER}/readme.md" "${MEDIA_NODE_PREVIOUS_FOLDER}" || fatal_error "Error while updating 'readme.md'"
     printf '\n          - readme.md'

     mkdir "${MEDIA_NODE_PREVIOUS_FOLDER}/nginx_conf" || fatal_error "Error while creating the folder 'nginx_conf'"

     mv "${TMP_FOLDER}/kms-recorder.conf" "${MEDIA_NODE_PREVIOUS_FOLDER}/nginx_conf" || fatal_error "Error while updating 'readme.md'"
     printf '\n          - kms-recorder.conf'

     mv "${TMP_FOLDER}/nginx.conf" "${MEDIA_NODE_PREVIOUS_FOLDER}/nginx_conf" || fatal_error "Error while updating 'readme.md'"
     printf '\n          - nginx.conf'

     printf "\n     => Deleting 'tmp' folder"
     rm -rf "${TMP_FOLDER}" || fatal_error "Error deleting 'tmp' folder"

     # Add execution permissions
     printf "\n     => Adding permission to 'media_node' program..."
     chmod +x "${MEDIA_NODE_PREVIOUS_FOLDER}/media_node" || fatal_error "Error while adding permission to 'media_node' program"

     # Ready to use
     printf '\n'
     printf '\n'
     printf '\n     ======================================='
     printf '\n     Openvidu Platform successfully upgrade.'
     printf '\n     ======================================='
     printf '\n'
     printf "\n     1. A new file 'docker-compose.yml' has been created with the new services"
     printf '\n'
     printf "\n     2. The current file '.env' has been kept but a new file '.env-%s' has been created." "${MEDIA_NODE_VERSION}" 
     printf "\n     Please check the new file '.env-%s' use your data from the file '.env' and replace it" "${MEDIA_NODE_VERSION}"
     printf '\n     to have the new improvements.' 
     printf '\n'
     printf '\n     3. Start new version of Media Node'
     printf '\n     $ ./media_node start'
     printf '\n'
     printf "\n     If you want to roll-back all the files from the previous installation are in the folder '.old-%s'" "${OPENVIDU_PREVIOUS_VERSION}"
     printf '\n'
     printf '\n     For more information, check readme.md'
     printf '\n'
     printf '\n'
}

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

# Check type of installation
if [[ ! -z "$1" && "$1" == "upgrade" ]]; then
     upgrade_media_node
else
     new_media_node_installation
fi
