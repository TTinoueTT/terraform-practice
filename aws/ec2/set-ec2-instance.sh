#!/bin/bash
# 25番ポート開放用に適当な EC2 インスタンスを作成する
# 作成されるリソース
# - EC2 インスタンス(ubuntu)
# - EIP
# - セキュリティグループ(AWS-MTA)
# - AWS-PAY-SSH-KEY

# まず params/volume-mapping.json と ec2-user-data.sh を
# 作成してから以降を張りつけて実行

# 宣言部 *************************************************
PARENT_EC2_NAME="ic.tky-110"
UBUNTU_AMI_ID="ami-0a0b7b240264a48d7"
KEY_PAIR_NAME="AWS-PAY-SSH-KEY"
# KEY_PAIR_NAME="AWS-ASISTNET-KEY"
SG_NAME="AWS-MTA"

# 実行部 *************************************************
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$SG_NAME" \
    --query "SecurityGroups[0].GroupId" \
    --output text) && echo "$SECURITY_GROUP_ID"
# shellcheck disable=SC2207
ALLOCATION_IDS=($(aws ec2 describe-addresses \
    --query "Addresses[?InstanceId == null].AllocationId" \
    --output text)) && echo "${ALLOCATION_IDS[@]}"

# Check if ALLOCATION_IDS array is not empty
if [ ${#ALLOCATION_IDS[@]} -gt 0 ]; then
    echo "ALLOCATION_IDS is not empty. Proceeding with the next steps..."
    EIP_ALLOC=${ALLOCATION_IDS[0]} && echo "$EIP_ALLOC"
else
    echo "ALLOCATION_IDS is empty. No further action is required."
    EIP_ALLOC=$(aws ec2 allocate-address \
        --query "AllocationId" \
        --output text) && echo "$EIP_ALLOC"
fi

## CloudShell 実行用
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $UBUNTU_AMI_ID \
    --instance-type t3.micro \
    --key-name $KEY_PAIR_NAME \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=20,VolumeType=gp3}' \
    --associate-public-ip-address \
    --metadata-options HttpTokens=optional \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$PARENT_EC2_NAME},{Key=Ec2StartStop,Value=Start}]" \
    --query 'Instances[0].InstanceId' \
    --output text) && echo "$INSTANCE_ID"

aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"

aws ec2 associate-address \
    --instance-id "$INSTANCE_ID" \
    --allocation-id "$EIP_ALLOC"
