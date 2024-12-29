#!/bin/bash
# パッケージインデックスの更新
sudo yum update -y

# インタープリターの Python を3.8 にする
sudo amazon-linux-extras enable python3.8
sudo yum clean metadata
sudo yum install -y python3.8

# Python 3.8 を alternatives に登録（優先度 1）
sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

python3 --version
