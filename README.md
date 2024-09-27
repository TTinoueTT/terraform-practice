# terraform apply の実行

## 環境毎の apply 実行

### dev の実行

```bash
terraform apply \
    -var-file=vars/dev/.secret/secret.tfvars \
    -var-file=vars/dev/network/vpc.tfvars
```
