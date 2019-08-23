#!/bin/bash 
set -eu -o pipefail

# Replicate AMIs in all regions
#
# Input parameters:
#
# KMS_AMI_NAME  Media server AMI Name
# KMS_AMI_ID    Media server AMI ID
# 
# OV_AMI_NAME   OpenVidu AMI Name
# OV_AMI_ID     OpenVidu AMI ID

export AWS_DEFAULT_REGION=us-east-1

TARGET_REGIONS="us-east-2 
                us-west-1 
                us-west-2 
                ap-south-1 
                ap-northeast-2 
                ap-southeast-1 
                ap-southeast-2 
                ap-northeast-1 
                ca-central-1 
                eu-central-1 
                eu-west-1 
                eu-west-2 
                eu-west-3 
                eu-north-1 
                sa-east-1"

echo "Kurento IDs"
for REGION in ${TARGET_REGIONS}
do
	ID=$(aws ec2 copy-image --name ${KMS_AMI_NAME} --source-image-id ${KMS_AMI_ID} --source-region us-east-1 --region ${REGION})
    echo ${REGION}: $(echo ${ID} | awk '{ print $3 }')
done

echo ""
echo ""
echo "OV IDs"
for REGION in ${TARGET_REGIONS}
do
	ID=$(aws ec2 copy-image --name ${OV_AMI_NAME}  --source-image-id ${OV_AMI_ID}  --source-region us-east-1 --region ${REGION})
	echo ${REGION}: $(echo ${ID} | awk '{ print $3 }')
done