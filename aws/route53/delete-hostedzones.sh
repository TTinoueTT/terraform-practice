#!/bin/bash

# ホストゾーン名の配列は、一括取得の方法と、配列に直接ドメインを入れる方法で定義する2通りを用意しています。
# どちらかをコメントアウトにして利用できるようにしてください。
# A レコードが 1000 以上あるホストゾーンはあらかじめ、delete_a_record.sh を実行してこちらのスクリプトを実行してください。

# アカウント内のホストゾーンの一括取得

# HOSTED_ZONE_NAMES=($(aws route53 list-hosted-zones --query "HostedZones[].Name" --output text))
# ↑ で json 形式のすべてのホストゾーンを出力してくれる。

HOSTED_ZONE_NAMES=(
    "aeuz-46mkan.com"
    "ethereal-realm.com"
    "destiny-diviner.com"
    "lucky-oracle.com"
    "auspicious-gaze.net"
    "predict-yourluck.com"
    "destiny-prognosticator.net"
    "endless-mirage.com"
    "timeless-fantasy.com"
    "night-phantasy.com"
    "phantasy-scope.com"
    "felicity-predictor.com"
    "oracle-tomorrow.net"
    "lucky-foretell.com"
    "dream-eternity.com"
)

for HZ_NAME in "${HOSTED_ZONE_NAMES[@]}"; do
    echo "ホストゾーン名: ${HZ_NAME}を削除します"

    # ホストゾーンIDを取得する
    HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name \
        --dns-name "$HZ_NAME" \
        --query "HostedZones[0].Id" \
        --output text) && echo "HOSTED_ZONE_ID: $HOSTED_ZONE_ID"
    # HOSTED_ZONE_ID=$(echo "$HOSTED_ZONE_ID" | cut -d'/' -f3)

    # すべてのレコードを取得する
    records=$(aws route53 list-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --output json)

    # NSとSOAレコード以外に絞り込む
    changes=$(echo "$records" | jq -r '.ResourceRecordSets[] | select(.Type != "NS" and .Type != "SOA") | {Action: "DELETE", ResourceRecordSet: {Name: .Name, Type: .Type, TTL: .TTL, ResourceRecords: .ResourceRecords}}' | jq -s '{Changes: .}')

    # 変更セットをJSONファイルに保存
    echo "$changes" >changes.json

    # レコードを削除
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch file://changes.json

    # 一時ファイルを削除
    rm changes.json

    # ホストゾーンを削除する
    aws route53 delete-hosted-zone --id "$HOSTED_ZONE_ID"
done
