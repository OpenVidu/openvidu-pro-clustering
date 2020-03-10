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

if [ "${OPENVIDU_PRO_IS_SNAPSHOT}" ]; then
  OPENVIDU_PRO_VERSION=${OPENVIDU_PRO_VERSION}-SNAPSHOT
fi

DATESTAMP=$(date +%s)
TEMPJSON=$(mktemp -t cloudformation-XXX --suffix .json)

# Get Latest Ubuntu AMI id from specified region
# Parameters
# $1 Aws region
getUbuntuAmiId() {
    local AMI_ID=$(
        aws --region ${1} ec2 describe-images \
        --filters Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64* \
        --query 'Images[*].[ImageId,CreationDate]' \
        --output text  \
        | sort -k2 -r  | head -n1 | cut -d$'\t' -f1
    )
    echo $AMI_ID
}

AMIEUWEST1=$(getUbuntuAmiId 'eu-west-1')
AMIUSEAST1=$(getUbuntuAmiId 'us-east-1')

# Copy templates to feed
cp cfn-mkt-kms-ami.yaml.template cfn-mkt-kms-ami.yaml
cp cfn-mkt-ov-ami.yaml.template cfn-mkt-ov-ami.yaml

## Setting Openvidu Version and Ubuntu Latest AMIs
sed -i "s/OPENVIDU_VERSION/${OPENVIDU_PRO_VERSION}/" cfn-mkt-kms-ami.yaml
sed -i "s/OPENVIDU_VERSION/${OPENVIDU_PRO_VERSION}/" cfn-mkt-ov-ami.yaml
sed -i "s/AMIEUWEST1/${AMIEUWEST1}/" cfn-mkt-kms-ami.yaml
sed -i "s/AMIEUWEST1/${AMIEUWEST1}/" cfn-mkt-ov-ami.yaml
sed -i "s/AMIUSEAST1/${AMIUSEAST1}/" cfn-mkt-kms-ami.yaml
sed -i "s/AMIUSEAST1/${AMIUSEAST1}/" cfn-mkt-ov-ami.yaml

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
  sed "s/OV_AMI_ID/${OV_RAW_AMI_ID}/" cfn-mkt-openvidu-server-pro.yaml.template > cfn-mkt-openvidu-server-pro-${OPENVIDU_PRO_VERSION}.yaml
  sed -i "s/KMS_AMI_ID/${KMS_RAW_AMI_ID}/g" cfn-mkt-openvidu-server-pro-${OPENVIDU_PRO_VERSION}.yaml
else
  sed "s/OV_AMI_ID/${OV_RAW_AMI_ID}/" cfn-openvidu-server-pro-no-market.yaml.template > cfn-openvidu-server-pro-no-market-${OPENVIDU_PRO_VERSION}.yaml
  sed -i "s/KMS_AMI_ID/${KMS_RAW_AMI_ID}/g" cfn-openvidu-server-pro-no-market-${OPENVIDU_PRO_VERSION}.yaml
fi

rm $TEMPJSON
rm cfn-mkt-kms-ami.yaml
rm cfn-mkt-ov-ami.yaml
