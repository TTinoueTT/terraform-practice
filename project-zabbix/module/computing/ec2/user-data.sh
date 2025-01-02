#!/bin/bash
# パッケージインデックスの更新
sudo apt-get update -y

# 必要なパッケージのインストール（必要に応じて追加）
sudo apt-get install -y software-properties-common

# Python 3.8 のインストール
sudo apt-get install -y python3.8

# Python 3.8 を alternatives に登録（優先度 1）
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# デフォルトの python3 を Python 3.8 に設定
sudo update-alternatives --set python3 /usr/bin/python3.8

# Python バージョンの確認
python3 --version
