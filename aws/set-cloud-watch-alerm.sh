#!/bin/bash

#REGION_CODE とPREFIX を指定する
# ********************************************
REGION_CODE='us-east-2'
PREFIX=redirect.sonic- # abc.tky-1までで正規表現
# ********************************************

INSTANCES=$(aws ec2 describe-instances \
    --filters Name=instance-state-name,Values=running \
    --query "Reservations[*].Instances[?starts_with(Tags[?Key==\`Name\`].Value | [0], \`$PREFIX\`)]" \
    --output json) && echo "$INSTANCES"

INSTANCE_IDS=$(echo "$INSTANCES" | jq -r '.[][] | .InstanceId') && echo "${INSTANCE_IDS[@]}"
# インスタンスIDを取得
# INSTANCE_IDS=$(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text)

# 各インスタンスIDについてループ処理(! アカウントによって、$INSTANCE_IDS を "${INSTANCE_IDS[@]}" と書かなければならないパターンもありました。)
for INSTANCE_ID in $INSTANCE_IDS; do
    aws cloudwatch put-metric-alarm \
        --alarm-name "awsec2-$INSTANCE_ID-GreaterThanOrEqualToThreshold-StatusCheckFailed" \
        --alarm-description "Alarm when StatusCheckFailed >= 0.99 for instance $INSTANCE_ID" \
        --metric-name StatusCheckFailed \
        --namespace AWS/EC2 \
        --statistic Average \
        --period 60 \
        --threshold 0.99 \
        --comparison-operator GreaterThanOrEqualToThreshold \
        --dimensions Name=InstanceId,Value="$INSTANCE_ID" \
        --evaluation-periods 1 \
        --alarm-actions arn:aws:automate:$REGION_CODE:ec2:stop \
        --unit Count
done
