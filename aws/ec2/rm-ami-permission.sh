#!/bin/bash

# AMIの名前のリストを指定
AMI_NAMES=("parent" "child")

for AMI_NAME in "${AMI_NAMES[@]}"; do
    echo "Processing AMI with name: ${AMI_NAME}"

    # AMIのIDを取得
    AMI_ID=$(aws ec2 describe-images \
        --filters "Name=name,Values=${AMI_NAME}" \
        --query 'Images[*].ImageId' \
        --output text) && echo "$AMI_ID"

    if [ -z "$AMI_ID" ]; then
        echo "No AMI found with name: ${AMI_NAME}"
        continue
    fi

    # 現在のAMIの使用許可を取得
    PERMISSION_ACCOUNTS=$(aws ec2 describe-image-attribute \
        --image-id "${AMI_ID}" \
        --attribute launchPermission \
        --query 'LaunchPermissions[*].UserId' \
        --output text) && echo "$PERMISSION_ACCOUNTS"

    if [ -z "$PERMISSION_ACCOUNTS" ]; then
        echo "No launch permissions found for AMI with ID: ${AMI_ID}"
        continue
    fi

    # 使用許可を個別に削除
    for ACCOUNT_ID in $PERMISSION_ACCOUNTS; do
        aws ec2 modify-image-attribute \
            --image-id "${AMI_ID}" \
            --launch-permission "Remove=[{UserId=${ACCOUNT_ID}}]"
        echo "Removed launch permission for user ${ACCOUNT_ID} from image ${AMI_ID}"
    done

    echo "Completed processing for AMI with name: ${AMI_NAME}"
done
