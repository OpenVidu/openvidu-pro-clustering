#!/bin/bash

# Set debug mode
DEBUG=${DEBUG:-false}
[ "$DEBUG" == "true" ] && set -x

# Download openvidu server
OPENVIDU_PRO_PASS=$(cat /tmp/openvidu-pro-password/password)
mkdir -p /opt/openvidu
curl -o /opt/openvidu/openvidu-server.jar -u ${OPENVIDU_PRO_USERNAME}:${OPENVIDU_PRO_PASS} https://pro.openvidu.io/openvidu-server-pro-${OPENVIDU_VERSION}.jar

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
