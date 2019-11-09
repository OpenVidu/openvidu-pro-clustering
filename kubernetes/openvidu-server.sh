#!/bin/bash -x

# Wait for kibana
while true
do 
  HTTP_STATUS=$(curl -I http://kibana:5601/app/kibana | head -n1 | awk '{print $2}')
  if [ $HTTP_STATUS == 200 ]; then
    break
  fi
  sleep 1
done

cat >/opt/openvidu/application.properties<<EOF
openvidu.secret=${OPENVIDU_SECRET}
server.ssl.enabled=false
server.port=5443
openvidu.cdr=${OPENVIDU_CDR}

openvidu.recording=${OPENVIDU_RECORDING}
openvidu.recording.public-access=${OPENVIDU_RECORDING_PUBLIC_ACCESS}
openvidu.recording.notification=${OPENVIDU_RECORDING_NOTIFICATION}

openvidu.streams.video.max-recv-bandwidth=${OPENVIDU_STREAMS_VIDEO_MAX_RECV_BANDWIDTH}
openvidu.streams.video.min-recv-bandwidth=${OPENVIDU_STREAMS_VIDEO_MIN_RECV_BANDWIDTH}
openvidu.streams.video.max-send-bandwidth=${OPENVIDU_STREAMS_VIDEO_MAX_SEND_BANDWIDTH}
openvidu.streams.video.min-send-bandwidth=${OPENVIDU_STREAMS_VIDEO_MIN_SEND_BANDWIDTH}

openvidu.pro.kibana.host=http://kibana/kibana
openvidu.pro.elasticsearch.host=http://elasticsearch:9200

openvidu.webhook=${OPENVIDU_WEBHOOK}

openvidu.publicurl=${OPENVIDU_PUBLICURL}
MY_UID=0
openvidu.recording.composed-url=${OPENVIDU_PUBLICURL}/inspector/

kms.uris=[]

openvidu.pro.cluster=${OPENVIDU_PRO_CLUSTER}
openvidu.pro.cluster.load-strategy=${OPENVIDU_PRO_CLUSTER_LOAD_STRATEGY}
openvidu.pro.cluster.mode=${OPENVIDU_PRO_CLUSTER_MODE}
openvidu.pro.cluster.environment=${OPENVIDU_PRO_CLUSTER_ENVIRONMENT}
openvidu.pro.cluster.media-nodes=${OPENVIDU_PRO_CLUSTER_MEDIA_NODES}

EOF

java -jar -Dspring.config.additional-location=/opt/openvidu/application.properties openvidu-server.jar