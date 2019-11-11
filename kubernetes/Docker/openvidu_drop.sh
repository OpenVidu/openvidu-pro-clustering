#!/bin/bash 
set -e -o pipefail

# Set debug mode
DEBUG=${DEBUG:-false}
[ "$DEBUG" == "true" ] && set -x

ID=$1
[ -z "${ID}" ] && { echo "Must provide pod ID"; exit 1; }

kubectl delete pod ${ID}
