#!/bin/bash
set -u -o pipefail

# Check where i am
MEMBER=$(cat /opt/openvidu/openvidu-cluster-member)

if [ "$MEMBER" == "server" ]; then

################################
### OpenVidu Server Pro Node ###
################################

# Check Docker
DOCKER=$(ps ax | grep [/]usr/bin/dockerd)
if [ "x${DOCKER}" == "x" ]; then
	echo "[ERROR] DOCKER is not running..."
	exit 1
else
	echo "[OK] DOCKER is running..."
fi

# Check NGiNX
NGINX=$(ps ax | grep [n]ginx)
if [ "x${NGINX}" == "x" ]; then
	echo "[ERROR] NGINX is not running..."
	exit 1
else
	echo "[OK] NGINX is running..."
fi

# Check Coturn
COTURN=$(ps ax | grep [t]urnserver)
if [ "x${COTURN}" == "x" ]; then
	echo "[ERROR] COTURN is not running..."
	exit 1
else
	echo "[OK] COTURN is running..."
fi

# Check Elastic
ELASTICSEARCH=$(ps ax | grep [e]lasticsearch)
if [ "x${ELASTICSEARCH}" == "x" ]; then
	echo "[ERROR] ELASTICSEARCH is not running..."
	exit 1
else
	echo "[OK] ELASTICSEARCH is running..."
fi

KIBANA=$(ps ax | grep [k]ibana)
if [ "x${KIBANA}" == "x" ]; then
	echo "[ERROR] KIBANA is not running..."
	exit 1
else
	echo "[OK] KIBANA is running..."
fi

else

##################
### Media Node ###
##################

KMS=$(ps ax | grep [k]urento-media-server)
if [ "x${KMS}" == "x" ]; then
	echo "[ERROR] KMS is not running..."
	exit 1
else
	echo "[OK] KMS is running..."
fi

# Check NGiNX
NGINX=$(ps ax | grep [n]ginx)
if [ "x${NGINX}" == "x" ]; then
	echo "[ERROR] NGINX is not running..."
	exit 1
else
	echo "[OK] NGINX is running..."
fi

fi