#!/usr/bin/env bash

MEDIA_NODE_FOLDER=kms
MEDIA_NODE_VERSION=v2.15.1
BEATS_FOLDER=${MEDIA_NODE_FOLDER}/beats
DOWNLOAD_URL=https://raw.githubusercontent.com/OpenVidu/openvidu-pro-clustering/${MEDIA_NODE_VERSION}
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

     # Create beats folder
     printf '\n     => Creating folder '%s'...' "${BEATS_FOLDER}"
     mkdir "${BEATS_FOLDER}" || fatal_error "Error while creating the folder 'beats'"

     # Download necessaries files
     printf '\n     => Downloading Media Node files:'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/docker-compose.yml \
          --output "${MEDIA_NODE_FOLDER}/docker-compose.yml" || fatal_error "Error when downloading the file 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/.env \
          --output "${MEDIA_NODE_FOLDER}/.env" || fatal_error "Error when downloading the file '.env'"
     printf '\n          - .env'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/media_node \
          --output "${MEDIA_NODE_FOLDER}/media_node" || fatal_error "Error when downloading the file 'media_node'"
     printf '\n          - media_node'

     curl --silent ${DOWNLOAD_URL} \
          --output "${MEDIA_NODE_FOLDER}/readme.md" || fatal_error "Error when downloading the file 'readme.md'"
     printf '\n          - readme.md'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/beats/filebeat.yml \
          --output "${BEATS_FOLDER}/filebeat.yml" || fatal_error "Error when downloading the file 'filebeat.yml'"
     printf '\n          - filebeat.yml'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/beats/metricbeat-elasticsearch.yml \
          --output "${BEATS_FOLDER}/metricbeat-elasticsearch.yml" || fatal_error "Error when downloading the file 'metricbeat-elasticsearch.yml'"
     printf '\n          - metricbeat-elasticsearch.yml'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/beats/metricbeat-openvidu.yml \
          --output "${BEATS_FOLDER}/metricbeat-openvidu.yml" || fatal_error "Error when downloading the file 'metricbeat-openvidu.yml'"
     printf '\n          - metricbeat-openvidu.yml'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/beats/copy_config_files.sh \
          --output "${BEATS_FOLDER}/copy_config_files.sh" || fatal_error "Error when downloading the file 'copy_config_files.sh'"
     printf '\n          - copy_config_files.sh'

     # Add execution permissions
     printf "\n     => Adding permission to 'media_node' program..."
     chmod +x "${MEDIA_NODE_FOLDER}/media_node" || fatal_error "Error while adding permission to 'media_node' program"

     # Add execution permissions
     printf "\n     => Adding permission to 'copy_config_files.sh' script..."
     chmod +x "${MEDIA_NODE_FOLDER}/beats/copy_config_files.sh" || fatal_error "Error while adding permission to 'copy_config_files.sh' script"

     # Pull images
     printf "\n     => Pulling images...\n"
     cd "${MEDIA_NODE_FOLDER}" || fatal_error "Error when moving to '${MEDIA_NODE_FOLDER}' folder"
     KMS_IMAGE=$(cat docker-compose.yml | grep KMS_IMAGE | sed 's/\(^.*KMS_IMAGE:-\)\(.*\)\(\}.*$\)/\2/')
     METRICBEAT_IMAGE=$(cat docker-compose.yml | grep METRICBEAT_IMAGE | sed 's/\(^.*METRICBEAT_IMAGE:-\)\(.*\)\(\}.*$\)/\2/')
     FILEBEAT_IMAGE=$(cat docker-compose.yml | grep FILEBEAT_IMAGE | sed 's/\(^.*FILEBEAT_IMAGE:-\)\(.*\)\(\}.*$\)/\2/')
     docker pull $KMS_IMAGE || fatal "Error while pulling docker image: $KMS_IMAGE"
     docker pull $METRICBEAT_IMAGE || fatal "Error while pulling docker image: $METRICBEAT_IMAGE"
     docker pull $FILEBEAT_IMAGE || fatal "Error while pulling docker image: $FILEBEAT_IMAGE"
     docker-compose pull | true

     # Ready to use
     printf "\n"
     printf '\n     ======================================='
     printf "\n          Media Node successfully installed."
     printf '\n     ======================================='
     printf "\n"
     printf '\n     1. Go to kms folder:'
     printf '\n     $ cd kms'
     printf "\n"
     printf '\n     2. Start Media Node Controller'
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
          "${PWD}"
          "/opt/${MEDIA_NODE_FOLDER}"
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
     [ -z "${OPENVIDU_PREVIOUS_VERSION}" ] && OPENVIDU_PREVIOUS_VERSION=2.14.0

     # In this point using the variable 'OPENVIDU_PREVIOUS_VERSION' we can verify if the upgrade is
     # posible or not. If it is not posible launch a warning and stop the upgrade.

     printf '\n'
     printf '\n     ======================================='
     printf '\n       Upgrade Media Node %s to %s' "${OPENVIDU_PREVIOUS_VERSION}" "${MEDIA_NODE_VERSION}"
     printf '\n     ======================================='
     printf '\n'

     ROLL_BACK_FOLDER="${MEDIA_NODE_PREVIOUS_FOLDER}/.old-${OPENVIDU_PREVIOUS_VERSION}"
     TMP_FOLDER="${MEDIA_NODE_PREVIOUS_FOLDER}/tmp"
     ACTUAL_FOLDER="$PWD"

     printf "\n     Creating roll back folder '%s'..." ".old-${OPENVIDU_PREVIOUS_VERSION}"
     mkdir "${ROLL_BACK_FOLDER}" || fatal_error "Error while creating the folder '.old-${OPENVIDU_PREVIOUS_VERSION}'"

     printf "\n     Creating temporal folder 'tmp'..."
     mkdir "${TMP_FOLDER}" || fatal_error "Error while creating the folder 'temporal'"

     # Download necessaries files
     printf '\n     => Downloading new Media Node files:'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/docker-compose.yml \
          --output "${TMP_FOLDER}/docker-compose.yml" || fatal_error "Error when downloading the file 'docker-compose.yml'"
     printf '\n          - docker-compose.yml'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/.env \
          --output "${TMP_FOLDER}/.env" || fatal_error "Error when downloading the file '.env'"
     printf '\n          - .env'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/media_node \
          --output "${TMP_FOLDER}/media_node" || fatal_error "Error when downloading the file 'media_node'"
     printf '\n          - media_node'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/readme.md \
          --output "${TMP_FOLDER}/readme.md" || fatal_error "Error when downloading the file 'readme.md'"
     printf '\n          - readme.md'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/beats/filebeat.yml \
          --output "${TMP_FOLDER}/filebeat.yml" || fatal_error "Error when downloading the file 'filebeat.yml'"
     printf '\n          - filebeat.yml'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/beats/metricbeat-elasticsearch.yml \
          --output "${TMP_FOLDER}/metricbeat-elasticsearch.yml" || fatal_error "Error when downloading the file 'metricbeat-elasticsearch.yml'"
     printf '\n          - metricbeat-elasticsearch.yml'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/beats/metricbeat-openvidu.yml \
          --output "${TMP_FOLDER}/metricbeat-openvidu.yml" || fatal_error "Error when downloading the file 'metricbeat-openvidu.yml'"
     printf '\n          - metricbeat-openvidu.yml'

     curl --silent ${DOWNLOAD_URL}/docker/media-node/beats/copy_config_files.sh \
          --output "${TMP_FOLDER}/copy_config_files.sh" || fatal_error "Error when downloading the file 'copy_config_files.sh'"
     printf '\n          - copy_config_files.sh'

     # Dowloading new images and stoped actual Media Node
     printf '\n     => Dowloading new images...'
     printf '\n'
     sleep 1

     printf "\n          => Moving to 'tmp' folder..."
     printf '\n'

     # Pull images
     printf "\n     => Pulling images...\n"
     cd "${TMP_FOLDER}" || fatal_error "Error when moving to '${TMP_FOLDER}' folder"
     KMS_IMAGE=$(cat docker-compose.yml | grep KMS_IMAGE | sed 's/\(^.*KMS_IMAGE:-\)\(.*\)\(\}.*$\)/\2/')
     METRICBEAT_IMAGE=$(cat docker-compose.yml | grep METRICBEAT_IMAGE | sed 's/\(^.*METRICBEAT_IMAGE:-\)\(.*\)\(\}.*$\)/\2/')
     FILEBEAT_IMAGE=$(cat docker-compose.yml | grep FILEBEAT_IMAGE | sed 's/\(^.*FILEBEAT_IMAGE:-\)\(.*\)\(\}.*$\)/\2/')
     docker pull $KMS_IMAGE || fatal "Error while pulling docker image: $KMS_IMAGE"
     docker pull $METRICBEAT_IMAGE || fatal "Error while pulling docker image: $METRICBEAT_IMAGE"
     docker pull $FILEBEAT_IMAGE || fatal "Error while pulling docker image: $FILEBEAT_IMAGE"
     docker-compose pull | true

     printf '\n     => Stoping Media Node...'
     printf '\n'
     sleep 1

     printf "\n          => Moving to 'openvidu' folder..."
     printf '\n'
     cd "${MEDIA_NODE_PREVIOUS_FOLDER}" || fatal_error "Error when moving to 'openvidu' folder"
     docker-compose down | true

     printf '\n'
     printf '\n     => Moving to working dir...'
     cd "${ACTUAL_FOLDER}" || fatal_error "Error when moving to working dir"

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

     cp "${MEDIA_NODE_PREVIOUS_FOLDER}/.env" "${ROLL_BACK_FOLDER}" || fatal_error "Error while moving previous '.env'"
     printf '\n          - .env'

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

     mkdir "${MEDIA_NODE_PREVIOUS_FOLDER}/beats" || fatal_error "Error while creating the folder 'beats'"

     mv "${TMP_FOLDER}/filebeat.yml" "${MEDIA_NODE_PREVIOUS_FOLDER}/beats" || fatal_error "Error while updating 'filebeat.yml'"
     printf '\n          - filebeat.yml'

     mv "${TMP_FOLDER}/metricbeat-elasticsearch.yml" "${MEDIA_NODE_PREVIOUS_FOLDER}/beats" || fatal_error "Error while updating 'metricbeat-elasticsearch.yml'"
     printf '\n          - metricbeat-elasticsearch.yml'

     mv "${TMP_FOLDER}/metricbeat-openvidu.yml" "${MEDIA_NODE_PREVIOUS_FOLDER}/beats" || fatal_error "Error while updating 'metricbeat-openvidu.yml'"
     printf '\n          - metricbeat-openvidu.yml'

     mv "${TMP_FOLDER}/copy_config_files.sh" "${MEDIA_NODE_PREVIOUS_FOLDER}/beats" || fatal_error "Error while updating 'copy_config_files.sh'"
     printf '\n          - copy_config_files.sh'

     printf "\n     => Deleting 'tmp' folder"
     rm -rf "${TMP_FOLDER}" || fatal_error "Error deleting 'tmp' folder"

     # Add execution permissions
     printf "\n     => Adding permission to 'media_node' program..."
     chmod +x "${MEDIA_NODE_PREVIOUS_FOLDER}/media_node" || fatal_error "Error while adding permission to 'media_node' program"

     # Add execution permissions
     printf "\n     => Adding permission to 'copy_config_files.sh' script..."
     chmod +x "${MEDIA_NODE_PREVIOUS_FOLDER}/beats/copy_config_files.sh" || fatal_error "Error while adding permission to 'copy_config_files.sh' script"

     # Define old mode: On Premise or Cloud Formation
     OLD_MODE=$(grep -E "Installation Mode:.*$" "${ROLL_BACK_FOLDER}/docker-compose.yml" | awk '{ print $4,$5 }')
     [ ! -z "${OLD_MODE}" ] && sed -i -r "s/Installation Mode:.+/Installation Mode: ${OLD_MODE}/" "${MEDIA_NODE_PREVIOUS_FOLDER}/docker-compose.yml"

     # Ready to use
     printf '\n'
     printf '\n'
     printf '\n     ================================================'
     printf "\n     Openvidu successfully upgraded to version %s" "${OPENVIDU_VERSION}"
     printf '\n     ================================================'
     printf '\n'
     printf "\n     1. A new file 'docker-compose.yml' has been created with the new OpenVidu %s services" "${OPENVIDU_VERSION}"
     printf '\n'
     printf "\n     2. The previous file '.env' remains intact, but a new file '.env-%s' has been created." "${OPENVIDU_VERSION}"
     printf "\n     Transfer any configuration you wish to keep in the upgraded version from '.env' to '.env-%s'." "${OPENVIDU_VERSION}"
     printf "\n     When you are OK with it, rename and leave as the only '.env' file of the folder the new '.env-%s'." "${OPENVIDU_VERSION}"
     printf '\n'
     printf '\n     3. Start new version of Media Node'
     printf '\n     $ ./media_node start'
     printf '\n'
     printf "\n     If you want to rollback, all the files from the previous installation have been copied to folder '.old-%s'" "${OPENVIDU_PREVIOUS_VERSION}"
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
