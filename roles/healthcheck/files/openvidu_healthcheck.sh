#!/bin/bash
set -eu -o pipefail

# Check Docker
DOCKER=$(ps ax | grep /usr/bin/dockerd)
if [ "x${DOCKER}" == "x" ]; then
	echo "[ERROR] DOCKER is not running..."
	exit 1
fi

# Check NGiNX
NGINX=$(ps ax | grep nginx)
if [ "x${NGINX}" == "x" ]; then
	echo "[ERROR] NGINX is not running..."
	exit 1
fi

# Check Coturn
COTURN=$(ps ax | grep coturn)
if [ "x${COTURN}" == "x" ]; then
	echo "[ERROR] COTURN is not running..."
	exit 1
fi

# Check Openvidu
OPENVIDU=$(ps ax | grep openvidu-server)
if [ "x${OPENVIDU}" == "x" ]; then
	echo "[ERROR] OPENVIDU is not running..."
	exit 1
fi

# Check Elastic
ELASTICSEARCH=$(ps ax | grep elasticsearch)
if [ "x${ELASTICSEARCH}" == "x" ]; then
	echo "[ERROR] ELASTICSEARCH is not running..."
	exit 1
fi

KIBANA=$(ps ax | grep elasticsearch)
if [ "x${KIBANA}" == "x" ]; then
	echo "[ERROR] KIBANA is not running..."
	exit 1
fi
