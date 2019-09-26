#!/bin/bash -x
set -eu -o pipefail

CF_OVP_TARGET=${CF_OVP_TARGET:-nomarket}

if [ ${CF_OVP_TARGET} == "market" ]; then
  export AWS_ACCESS_KEY_ID=${NAEVA_AWS_ACCESS_KEY_ID}
  export AWS_SECRET_ACCESS_KEY=${NAEVA_AWS_SECRET_ACCESS_KEY}
  export AWS_DEFAULT_REGION=us-east-1
else
    export AWS_DEFAULT_REGION=eu-west-1  
fi

DATESTAMP=$(date +%s)
TEMPJSON=$(mktemp -t cloudformation-XXX --suffix .json)

## Setting Openvidu Version
sed "s/OPENVIDU_VERSION/${OPENVIDU_PRO_VERSION}/" cfn-mkt-kms-ami.yaml.template > cfn-mkt-kms-ami.yaml
sed "s/OPENVIDU_VERSION/${OPENVIDU_PRO_VERSION}/" cfn-mkt-ov-ami.yaml.template  > cfn-mkt-ov-ami.yaml

## KMS AMI

# Copy template to S3
if [ ${CF_OVP_TARGET} == "market" ]; then
  aws s3 cp cfn-mkt-kms-ami.yaml s3://naeva-openvidu-pro
  TEMPLATE_URL=https://s3-eu-west-1.amazonaws.com/naeva-openvidu-pro/cfn-mkt-kms-ami.yaml
else
  aws s3 cp cfn-mkt-kms-ami.yaml s3://aws.openvidu.io
  TEMPLATE_URL=https://s3-eu-west-1.amazonaws.com/aws.openvidu.io/cfn-mkt-kms-ami.yaml
fi

aws cloudformation create-stack \
  --stack-name kms-${DATESTAMP} \
  --template-url ${TEMPLATE_URL} \
  --disable-rollback

aws cloudformation wait stack-create-complete --stack-name kms-${DATESTAMP}

echo "Getting instance ID"
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=kms-${DATESTAMP}" | jq -r ' .Reservations[] | .Instances[] | .InstanceId')

echo "Stopping the instance"
aws ec2 stop-instances --instance-ids ${INSTANCE_ID}

echo "wait for the instance to stop"
aws ec2 wait instance-stopped --instance-ids ${INSTANCE_ID}

echo "Creating AMI"
KMS_RAW_AMI_ID=$(aws ec2 create-image --instance-id ${INSTANCE_ID} --name KMS-ov-${OPENVIDU_PRO_VERSION}-${DATESTAMP} --description "Kurento Media Server" --output text)

echo "Cleaning up"
aws cloudformation delete-stack --stack-name kms-${DATESTAMP}

## OpenVidu AMI

# Copy template to S3
if [ ${CF_OVP_TARGET} == "market" ]; then
  aws s3 cp cfn-mkt-ov-ami.yaml s3://naeva-openvidu-pro
  TEMPLATE_URL=https://s3-eu-west-1.amazonaws.com/naeva-openvidu-pro/cfn-mkt-ov-ami.yaml
else
  aws s3 cp cfn-mkt-ov-ami.yaml s3://aws.openvidu.io
  TEMPLATE_URL=https://s3-eu-west-1.amazonaws.com/aws.openvidu.io/cfn-mkt-ov-ami.yaml
fi

cat > $TEMPJSON<<EOF
  [
    {"ParameterKey":"OpenViduProUsername","ParameterValue":"${OPENVIDU_PRO_USERNAME}"},
    {"ParameterKey":"OpenViduProPassword","ParameterValue":"${OPENVIDU_PRO_PASSWORD}"}
  ]
EOF

aws cloudformation create-stack \
  --stack-name openvidu-${DATESTAMP} \
  --template-url ${TEMPLATE_URL} \
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
OV_RAW_AMI_ID=$(aws ec2 create-image --instance-id ${INSTANCE_ID} --name OpenViduServerPro-${OPENVIDU_PRO_VERSION}-${DATESTAMP} --description "Openvidu Server Pro" --output text)

echo "Cleaning up"
aws cloudformation delete-stack --stack-name openvidu-${DATESTAMP}

# Wait for the instance
aws ec2 wait image-available --image-ids ${OV_RAW_AMI_ID}

# Updating the template
if [ ${CF_OVP_TARGET} == "market" ]; then
  sed "s/OV_AMI_ID/${OV_RAW_AMI_ID}/" cfn-mkt-openvidu-server-pro.yaml.template > cfn-openvidu-server-pro--${OPENVIDU_PRO_VERSION}.yaml
  sed -i "s/KMS_AMI_ID/${KMS_RAW_AMI_ID}/g" cfn-openvidu-server-pro-market-${OPENVIDU_PRO_VERSION}.yaml
else
  sed "s/OV_AMI_ID/${OV_RAW_AMI_ID}/" cfn-openvidu-server-pro-no-market.yaml.template > cfn-openvidu-server-pro-no-market-${OPENVIDU_PRO_VERSION}.yaml
  sed -i "s/KMS_AMI_ID/${KMS_RAW_AMI_ID}/g" cfn-openvidu-server-pro-no-market-${OPENVIDU_PRO_VERSION}.yaml
fi

rm $TEMPJSON
rm cfn-mkt-kms-ami.yaml
rm cfn-mkt-ov-ami.yaml
