#!/bin/bash -x

# This script will launch OpenVidu Server on your machine

OV_PROPERTIES="/opt/openvidu/application.properties"

{% if whichcert == "letsencrypt" or whichcert == "owncert" or whichcert == "customcert" %}
PUBLIC_HOSTNAME={{ domain_name }}
{% else %}
{% if run_ec2 == true %}
PUBLIC_HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
{% else %}
PUBLIC_HOSTNAME={{ openvidu_publicurl }}
{% endif %}
{% endif %}

# Wait for ElasticSearch
while true
do
  HTTP_STATUS=$(curl -I http://localhost:9200/ | head -n1 | awk '{print $2}')
  if [ $HTTP_STATUS == 200 ]; then
    break
  fi
  sleep 1
done

# Wait for kibana
while true
do
  HTTP_STATUS=$(curl -I http://localhost:5601/app/kibana | head -n1 | awk '{print $2}')
  if [ $HTTP_STATUS == 200 ]; then
    break
  fi
  sleep 1
done

{% if openvidu_pro_cluster_environment == "on_premise" %}
KMS_IPs=$(echo {{ kms_private_ips }} | tr , ' ')
KMS_ENDPOINTS=$(for IP in $KMS_IPs
do
  echo $IP | awk '{ print "\"ws://" $1 ":8888/kurento\"" }'
done
)
KMS_ENDPOINTS_LINE=$(echo $KMS_ENDPOINTS | tr ' ' ,)
sed -i "s#kms.uris=.*#kms.uris=[${KMS_ENDPOINTS_LINE}]#" ${OV_PROPERTIES}

# Wait for KMS
for IP in ${KMS_IPs}
do
	while ! nc -z $IP 8888; do
		echo "Waiting for Kurento Media Server (${IP}) to be available"
    	sleep 10
    done
done
{% endif %}

sed -i "s#openvidu.publicurl=.*#openvidu.publicurl=https://${PUBLIC_HOSTNAME}:4443#" ${OV_PROPERTIES}
sed -i "s/MY_UID=.*/MY_UID=$(id -u $USER)/" ${OV_PROPERTIES}
sed -i "s#openvidu.recording.composed-url=.*#openvidu.recording.composed-url=https://${PUBLIC_HOSTNAME}/inspector/#" ${OV_PROPERTIES}

EVENTS_LIST=$(echo {{ openvidu_webhook_events }} | tr , ' ')
if [ "$EVENTS_LIST" != "WEBHOOK_EVENTS" ]; then
	E=$(for EVENT in ${EVENTS_LIST}
	do
		echo $EVENT | awk '{ print "\"" $1 "\"" }'
	done
	)
	EVENTS=$(echo $E | tr ' ' ,)
	if ! grep -Fq "openvidu.webhook.events" ${OV_PROPERTIES}
	then
		echo "openvidu.webhook.events=[${EVENTS}]" >> ${OV_PROPERTIES}
	fi
fi

HEADERS="{{ openvidu_webhook_headers }}"
if [ "${HEADERS}" != "WEBHOOK_HEADERS" ]; then
	OPENVIDU_HEADERS="[\"${HEADERS}\"]"
	if ! grep -Fq "openvidu.webhook.headers" ${OV_PROPERTIES}
	then
		echo "openvidu.webhook.headers=${OPENVIDU_HEADERS}" >> ${OV_PROPERTIES}
	fi
fi

pushd /opt/openvidu
exec java -jar -Dspring.config.additional-location=${OV_PROPERTIES} /opt/openvidu/openvidu-server.jar

