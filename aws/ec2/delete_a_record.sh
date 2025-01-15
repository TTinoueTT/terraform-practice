#!/bin/bash
# NEXT 機の登録している A レコードの削除
# 設定(空白と改行の削除)
DOMAIN_NAME=$(echo "$1" | tr -d '[:space:]')
echo "対象のドメイン: $DOMAIN_NAME"
echo -n "この設定で進めてよろしいですか？ (yes/no): "
read -r answer

if [ "$answer" != "yes" ]; then
    echo "設定を中断しました。"
    exit 1
fi

hosted_zone_id=$(aws route53 list-hosted-zones-by-name \
    --dns-name "$DOMAIN_NAME" \
    --query "HostedZones[?Name == \`${DOMAIN_NAME}.\`].Id | [0]" \
    --output text) && echo "hosted_zone_id: $hosted_zone_id"

if [ "$hosted_zone_id" == "None" ] || [ -z "$hosted_zone_id" ]; then
    echo "Error: Hosted Zone ID for $DOMAIN_NAME not found."
    exit 1
fi

echo "Hosted Zone ID for $DOMAIN_NAME: $hosted_zone_id"

is_deletion_success=true

while true; do
    a_records=$(aws route53 list-resource-record-sets \
        --hosted-zone-id "$hosted_zone_id" \
        --query "ResourceRecordSets[?Type == 'A']" \
        --output json | jq '.[0:999]')

    count=$(echo "$a_records" | jq length)
    if [ "$count" -eq 0 ]; then
        echo "No A records found for $DOMAIN_NAME."
        break
        # exit 0
    fi
    echo "Found $count A records for $DOMAIN_NAME. Proceeding to delete..."

    # ChangeBatch の作成
    change_batch=$(echo "$a_records" | jq -r --arg ACTION "DELETE" '{
        "Changes": [
            .[] | {
                "Action": $ACTION,
                "ResourceRecordSet": {
                    "Name": .Name,
                    "Type": .Type,
                    "TTL": .TTL,
                    "ResourceRecords": .ResourceRecords
                }
            }
        ]
    }')

    # JSON ファイルに保存（オプション）
    echo "$change_batch" >change-batch.json

    # レコードの削除
    if ! aws route53 change-resource-record-sets \
        --hosted-zone-id "$hosted_zone_id" \
        --change-batch "file://change-batch.json"; then
        echo "Error: Failed to delete A records for $DOMAIN_NAME."
        is_deletion_success=false
        break
    fi

done

# 結果の確認
if $is_deletion_success; then
    echo "Successfully initiated deletion of all A records for $DOMAIN_NAME."
else
    echo "Error: Failed to delete A records for $DOMAIN_NAME."
fi
