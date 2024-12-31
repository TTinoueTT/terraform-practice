#!/bin/bash
# FIXME:途中
# 1. ポリシーの作成
# 2. 実行ロールの作成
# 3. 実行ロールにポリシーをアタッチ
# 4. Lambda 関数の作成
# 5. EventBridge ルールの作成

POLICY_NAME=Ec2StartStop_Policy

aws iam create-policy \
    --policy-name $POLICY_NAME --policy-document \
    "{ \
        \"Version\": \"2012-10-17\", \
        \"Statement\": [ \
            { \
            \"Effect\": \"Allow\", \
            \"Action\": [ \
                \"logs:CreateLogGroup\", \
                \"logs:CreateLogStream\", \
                \"logs:PutLogEvents\" \
            ], \
            \"Resource\": \"arn:aws:logs:*:*:*\" \
            }, \
            { \
            \"Effect\": \"Allow\", \
            \"Action\": [ \
                \"ec2:Describe*\", \
                \"ec2:Start*\", \
                \"ec2:Stop*\" \
            ], \
            \"Resource\": \"*\" \
            } \
        ] \
    } " >/dev/null
