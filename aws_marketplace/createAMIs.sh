#!/bin/bash -x
set -eu -o pipefail

export AWS_ACCESS_KEY_ID=${NAEVA_AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${NAEVA_AWS_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION=us-east-1

DATESTAMP=$(date +%s)
TEMPJSON=$(mktemp -t cloudformation-XXX --suffix .json)

## Setting Openvidu Version
sed "s/OPENVIDU_VERSION/${OPENVIDU_VERSION}/" cfn-mkt-kms-ami.yaml.template > cfn-mkt-kms-ami.yaml
sed "s/OPENVIDU_VERSION/${OPENVIDU_VERSION}/" cfn-mkt-ov-ami.yaml.template  > cfn-mkt-ov-ami.yaml

## KMS AMI

# Copy template to S3
aws s3 cp cfn-mkt-kms-ami.yaml s3://naeva-openvidu-pro

aws cloudformation create-stack \
  --stack-name kms-${DATESTAMP} \
  --template-url https://s3-eu-west-1.amazonaws.com/naeva-openvidu-pro/cfn-mkt-kms-ami.yaml \
  --disable-rollback

aws cloudformation wait stack-create-complete --stack-name kms-${DATESTAMP}

echo "Getting instance ID"
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=kms-${DATESTAMP}" | jq -r ' .Reservations[] | .Instances[] | .InstanceId')

echo "Stopping the instance"
aws ec2 stop-instances --instance-ids ${INSTANCE_ID}

echo "wait for the instance to stop"
aws ec2 wait instance-stopped --instance-ids ${INSTANCE_ID}

echo "Creating AMI"
RAW_AMI_ID=$(aws ec2 create-image --instance-id ${INSTANCE_ID} --name KMS-ov-${OPENVIDU_VERSION}-${DATESTAMP} --description "Kurento Media Server")

echo "Cleaning up"
aws cloudformation delete-stack --stack-name kms-${DATESTAMP}

## OpenVidu AMI

# Copy template to S3
aws s3 cp cfn-mkt-ov-ami.yaml s3://naeva-openvidu-pro

cat > $TEMPJSON<<EOF
  [
    {"ParameterKey":"OpenViduProUsername","ParameterValue":"${OPENVIDU_PRO_USERNAME}"},
    {"ParameterKey":"OpenViduProPassword","ParameterValue":"${OPENVIDU_PRO_PASSWORD}"}
  ]
EOF

aws cloudformation create-stack \
  --stack-name openvidu-${DATESTAMP} \
  --template-url https://s3-eu-west-1.amazonaws.com/naeva-openvidu-pro/cfn-mkt-ov-ami.yaml \
  --parameters file:///$TEMPJSON \
  --disable-rollback

aws cloudformation wait stack-create-complete --stack-name openvidu-${DATESTAMP}

echo "Getting instance ID"
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=openvidu-${DATESTAMP}" | jq -r ' .Reservations[] | .Instances[] | .InstanceId')

echo "Stopping the instance"
aws ec2 stop-instances --instance-ids ${INSTANCE_ID}

echo "wait for the instance to stop"
aws ec2 wait instance-stopped --instance-ids ${INSTANCE_ID}

echo "Creating AMI"
RAW_AMI_ID=$(aws ec2 create-image --instance-id ${INSTANCE_ID} --name OpenViduServerPro-${OPENVIDU_VERSION}-${DATESTAMP} --description "Openvidu Server Pro")

echo "Cleaning up"
aws cloudformation delete-stack --stack-name openvidu-${DATESTAMP}

rm $TEMPJSON
