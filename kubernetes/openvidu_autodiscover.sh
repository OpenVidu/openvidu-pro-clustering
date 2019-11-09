#!/bin/bash 
set -eu -o pipefail

# Set debug mode
DEBUG=${DEBUG:-false}
[ "$DEBUG" == "true" ] && set -x

OUTPUT=$(mktemp -t openvidu-autodiscover-XXX --suffix .json)

kubectl get pods --selector ov-cluster-member=media-node -o wide | tail -n +2 | awk '{ print $1 "\t" $6 }' > ${OUTPUT}

cat ${OUTPUT} | jq --raw-input --slurp 'split("\n") | map(split("\t")) | .[0:-1] | map( { "id": .[0], "ip": .[1] } )'
