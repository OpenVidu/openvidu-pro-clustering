#!/bin/bash
set -eu -o pipefail

# Check where i am
MEMBER=$(cat /opt/openvidu/openvidu-cluster-member)

if [ "$MEMBER" == "server" ]; then

# Check Docker
DOCKER=$(ps ax | grep /usr/bin/dockerd)
if [ "x${DOCKER}" == "x" ]; then
	echo "[ERROR] DOCKER is not running..."
	exit 1
else
	echo "[OK] DOCKER is running..."
fi

# Check NGiNX
NGINX=$(ps ax | grep nginx)
if [ "x${NGINX}" == "x" ]; then
	echo "[ERROR] NGINX is not running..."
	exit 1
else
	echo "[OK] NGINX is running..."
fi

# Check Coturn
COTURN=$(ps ax | grep coturn)
if [ "x${COTURN}" == "x" ]; then
	echo "[ERROR] COTURN is not running..."
	exit 1
else
	echo "[OK] COTURN is running..."
fi

# Check Openvidu
OPENVIDU=$(ps ax | grep openvidu-server)
if [ "x${OPENVIDU}" == "x" ]; then
	echo "[ERROR] OPENVIDU is not running..."
	exit 1
else
	echo "[OK] OPENVIDU is running..."	
fi

# Check Elastic
ELASTICSEARCH=$(ps ax | grep elasticsearch)
if [ "x${ELASTICSEARCH}" == "x" ]; then
	echo "[ERROR] ELASTICSEARCH is not running..."
	exit 1
else
	echo "[OK] ELASTICSEARCH is running..."
fi

KIBANA=$(ps ax | grep elasticsearch)
if [ "x${KIBANA}" == "x" ]; then
	echo "[ERROR] KIBANA is not running..."
	exit 1
else
	echo "[OK] KIBANA is running..."
fi

else

KMS=$(ps ax | grep kurento-media-server)
if [ "x${KMS}" == "x" ]; then
	echo "[ERROR] KMS is not running..."
	exit 1
else
	echo "[OK] KMS is running..."
fi

# Check NGiNX
NGINX=$(ps ax | grep nginx)
if [ "x${NGINX}" == "x" ]; then
	echo "[ERROR] NGINX is not running..."
	exit 1
else
	echo "[OK] NGINX is running..."
fi

fi