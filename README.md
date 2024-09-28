# 本プロジェクトでの terraform apply の実行まで

## variable の管理

### variable の宣言について

resource セクションなどで、変数を参照するような記述となる場合、その記述のある tf ファイルはvariable セクションを参照する必要がある。

```bash
.
├── main.tf       # resource セクションを宣言
└── variable.tf   # variable セクションを宣言
```

このような構成で、main.tf で利用する変数は variable.tf で参照することになる。

さらにモジュールを利用すると、モジュール内で利用する変数の宣言もモジュールの tf ファイルと同じ階層での variable の宣言が必要になってくる

```bash
.
├── main.tf
├── modules
│   ├── network
│   │   └── vpc
│   │       ├── 00_subnet.tf
│   │       ├── 00_vpc.tf
│   │       └── 99_variable.tf
│   └── storage
├── variable.tf
└── vars
    └── dev
        ├── computing
        ├── network
        │   └── vpc.tfvars
        └── storage
```

各モジュールで宣言している variable の内容はルートモジュールでの宣言と重複してしまう。
しかし、それが Terraform のベストプラクティスであるようです。Terraform を拡張した Terragrunt が DRY な記述を簡略化してくれることもあるようですが、プリミティブな terraform のルールを変更してしまうのもかけ離れていってしまうので、ルートモジュールの variable を直接編集しないように `terraform apply` を行えるようにしたい

### bundle_variable.tf に書き込むスクリプト

```bash
cd project
python shells/variable-bundle.py $PWD
```

module で参照する変数をルートモジュールから渡す際に、ルートモジュールが参照する variable が必要となるため、上記のスクリプトを利用する前提が以下

- module が利用する変数の定義がすでに用意されている
- main.tf (ルートモジュール) で参照する変数を呼び出す(このタイミングでは variable の定義ができてなくてもいい)
- ルートモジュールは main.tf、モジュールが参照する変数の定義は *_variable.tf という形式

これによって、実行結果として bundle_variable.tf に書き込みが行われる


## 環境毎の apply 実行

### dev の実行

```bash
terraform plan \
    -var-file=vars/dev/.secret/secret.tfvars \
    -var-file=vars/dev/network/vpc.tfvars \
    -var "tag_name_prefix=project-dev"
```


```bash
terraform apply \
    -var-file=vars/dev/.secret/secret.tfvars \
    -var-file=vars/dev/network/vpc.tfvars \
    -var "tag_name_prefix=project-dev"
```
