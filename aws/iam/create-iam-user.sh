#!/bin/bash

POLICY_NAME=registerRoute53
USER_NAME=registerRoute53

ACTIONS=("ec2:DescribeInstances" "route53:ListHostedZonesByName")

# アクションをJSON形式に変換
ACTION_JSON=$(printf ',"%s"' "${ACTIONS[@]}")
ACTION_JSON="${ACTION_JSON:1}"

POLICY_DOCUMENT=$(
    cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [${ACTION_JSON}],
            "Resource": "*"
        }
    ]
}
EOF
)

echo "$POLICY_DOCUMENT"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text) && echo "$ACCOUNT_ID"
aws iam create-policy --policy-name $POLICY_NAME --policy-document "$POLICY_DOCUMENT" >/dev/null

aws iam create-user --user-name $USER_NAME
aws iam attach-user-policy --user-name $USER_NAME --policy-arn arn:aws:iam::"$ACCOUNT_ID":policy/$POLICY_NAME
aws iam create-access-key --user-name $USER_NAME
