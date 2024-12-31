#!/bin/bash

GROUP_NAME="sg-group-sample"
GROUP_DESCRIPTION="sg-group description"

SSH_PERMISSION_IP=("163.43.113.75/24" "27.133.155.72/24")
CUSTOM_PERMISSION_IP=("163.43.113.75/24" "27.133.155.72/24" "221.117.53.240/29" "210.249.66.208/28")

# セキュリティグループの作成
if aws ec2 describe-security-groups --group-names "$GROUP_NAME" >/dev/null 2>&1; then
    echo "Security group '$GROUP_NAME' already exists. Skipping creation."
else
    aws ec2 create-security-group --group-name "$GROUP_NAME" --description "$GROUP_DESCRIPTION"
    echo "Security group '$GROUP_NAME' created."
fi

# SSH
echo "Configuring SSH permissions..."
for ip in "${SSH_PERMISSION_IP[@]}"; do
    aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 22 --cidr "$ip" >>/dev/null
done

{
    # SMTP
    aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 25 --cidr 0.0.0.0/0

    # HTTP, HTTPS
    aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 80 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 443 --cidr 0.0.0.0/0

    # POP3
    aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 110 --cidr 0.0.0.0/0
} || {
    echo "Failed to authorize common ports"
    exit 1
}

# カスタムTCP
echo "Configuring custom TCP permissions..."
for ip in "${CUSTOM_PERMISSION_IP[@]}"; do
    aws ec2 authorize-security-group-ingress --group-name $GROUP_NAME --protocol tcp --port 59630 --cidr "$ip" >>/dev/null
done
