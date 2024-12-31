#!/bin/bash
# AMI 使用許可を渡す AWS アカウントの ID をリストする
ACCOUNT_ID_LIST=("000000000000" "111111111111" "222222222222")

# 使用許可される AMI 名を指定
AMI_NAMES=("amiNameA" "amiNameB")

for ACCOUNT_ID in "${ACCOUNT_ID_LIST[@]}"; do

    for AMI_NAME in "${AMI_NAMES[@]}"; do

        AMI_ID=$(aws ec2 describe-images \
            --filters "Name=name,Values=$AMI_NAME" "Name=state,Values=available" \
            --owners self \
            --query 'Images[*].ImageId' \
            --output text) && echo "$AMI_ID"
        aws ec2 modify-image-attribute \
            --image-id "$AMI_ID" \
            --launch-permission "Add=[{UserId=$ACCOUNT_ID}]"

        aws ec2 describe-image-attribute \
            --image-id "${AMI_ID}" \
            --attribute launchPermission \
            --query 'LaunchPermissions[*].UserId'
    done
done
