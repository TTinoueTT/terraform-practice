#!/bin/bash

# Eventbrideg ルールの削除
RULE_NAME=Ec2StartStop_Task
FUNCTION_NAME=Ec2StartStop_Lambda
aws events describe-rule --name $RULE_NAME

# shellcheck disable=SC2207
TARGET_IDS=($(aws events list-targets-by-rule \
    --rule $RULE_NAME \
    --query "Targets[*].Id" \
    --output text)) && echo "${TARGET_IDS[@]}"

aws events remove-targets --rule $RULE_NAME --ids "${TARGET_IDS[@]}"

aws events delete-rule --name $RULE_NAME

# Lambda関数の削除
aws lambda delete-function --function-name $FUNCTION_NAME
