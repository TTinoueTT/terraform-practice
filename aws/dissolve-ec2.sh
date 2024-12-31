#!/bin/bash
INSTANCE_PREFIX=uno.pri
START_NUM=110
# Elastic IP の解放

PUBLIC_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${INSTANCE_PREFIX}-${START_NUM}" \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text) && echo "$PUBLIC_IP"

EIP_ALLOC=$(aws ec2 describe-addresses \
    --filters "Name=public-ip,Values=$PUBLIC_IP" \
    --query "Addresses[*].AllocationId" \
    --output text) && echo "$EIP_ALLOC"

aws ec2 release-address --allocation-id "$EIP_ALLOC"

# Name のプレフィックスと起動中であることを条件に EC2 インスタンスID リストを取得
TARGET_INSTANCE_IDS=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$INSTANCE_PREFIX*" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text) && echo "$TARGET_INSTANCE_IDS"

ALARM_NAMES=()

# インスタンス ID をもとにアラーム名を取得
for INSTANCE_ID in $TARGET_INSTANCE_IDS; do
    echo "$INSTANCE_ID"
    ALARM_NAME=$(aws cloudwatch describe-alarms \
        --query "MetricAlarms[?Dimensions[?Name=='InstanceId' && Value=='$INSTANCE_ID']].AlarmName" \
        --output text)
    echo "$ALARM_NAME"
    ALARM_NAMES+=("$ALARM_NAME")
done

echo "${ALARM_NAMES[@]}"

# アラーム名をもとにアラームを削除
aws cloudwatch delete-alarms \
    --alarm-names "${ALARM_NAMES[@]}"

# EC2 インスタンスを削除
# shellcheck disable=SC2206
INSTANCE_IDS=($TARGET_INSTANCE_IDS)
aws ec2 terminate-instances --instance-ids "${INSTANCE_IDS[@]}"
