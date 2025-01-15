#!/bin/bash

# プロジェクトの削除
terraform -chdir=./project-zabbix destroy -var-file vars/sample.tfvars -auto-approve
