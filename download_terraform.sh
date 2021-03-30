#!/usr/bin/env bash

echo "********** Download terraform"

TER_VER=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip

echo "******** Unzip terraform and move to:  'usr/local/bin' "

unzip terraform_${TER_VER}_linux_amd64.zip
mv terraform /usr/local/bin

echo "********** Test terraform binary"

terraform -v

