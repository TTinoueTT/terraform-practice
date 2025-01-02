# What project ?

このプロジェクトディレクトリでは、Webサーバーと監視サーバーの自動構築を行なっていきます。

## 手順
1. Terraform によるインフラリソースの用意
1. Ansible による サーバー構築・設定
1. Web サーバーを監視対象にしている状態を確認

```bash
ssh -o HostKeyAlgorithms=+ssh-rsa ubuntu@[ip-address] -i ~/.ssh/[key-file]
```

user-data の実行結果である、python のバージョンを確認

```bash frame=none
python3 --version

which python3
```


## other
```
# aws ec2 describe-images --owners 099720109477 \
#   --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*24*" \
#   --query 'reverse(sort_by(Images, &CreationDate))' \
#   --output json >> output-imge-info.json
```
