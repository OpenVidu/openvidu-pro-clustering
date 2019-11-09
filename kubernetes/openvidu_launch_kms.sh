#!/bin/bash 
set -eu -o pipefail

# Set debug mode
DEBUG=${DEBUG:-false}
[ "$DEBUG" == "true" ] && set -x

POD_NAME=kms-$(pwgen -A -0 4 1)
KMS_VERSION=$(curl --silent https://oudzlg0y3m.execute-api.eu-west-1.amazonaws.com/v1/ov_kms_matrix?ov=$OPENVIDU_VERSION | jq --raw-output '.[0] | .kms' )

cat>kms.yaml<<EOF
---
apiVersion: v1
kind: Pod
metadata:
  name: ${POD_NAME}
  labels:
    app: kurento-media-server
    ov-cluster-member: media-node
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
           matchLabels:
            app: kurento-media-server
        topologyKey: "kubernetes.io/hostname"
  hostNetwork: true
  containers:
  - name: kms
    image: kurento/kurento-media-server:${KMS_VERSION}
    env:
      - name: "KMS_STUN_IP"
        value: "74.125.140.127"
      - name: "KMS_STUN_PORT"
        value: "19302"
    ports:
      - containerPort: 8888
EOF

kubectl apply -f kms.yaml > /dev/null

KMS_IP=$(kubectl get pod ${POD_NAME} -o wide | tail -n1 | awk '{ print $6 }')

jq -n \
  --arg id "${POD_NAME}" \
  --arg ip "${KMS_IP}" \
  '{ id: $id, ip: $ip }'

