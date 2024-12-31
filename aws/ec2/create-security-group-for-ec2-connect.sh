#!/bin/bash
GROUP_NAME="ec2-connect"
DESCRIPTION="for ec2-connect"

# セキュリティグループの作成
aws ec2 create-security-group --group-name $GROUP_NAME --description "$DESCRIPTION"

# SSH
aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 22 --cidr 0.0.0.0/0 >>/dev/null
