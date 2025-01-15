#!/bin/bash

# インベントリファイルパス
INVENTORY_FILE_PATH="./project-zabbix/ansible/inventory/hosts.yaml"
PLAYBOOK_FILE_PATH="./project-zabbix/ansible/playbook/handlers.yaml"

WEB01_IP="54.123.45.67"

terraform -chdir=./project-zabbix init
terraform -chdir=./project-zabbix apply -var-file vars/sample.tfvars -auto-approve

ansible-playbook -i $INVENTORY_FILE_PATH $PLAYBOOK_FILE_PATH -e "web01_ip=$WEB01_IP"
