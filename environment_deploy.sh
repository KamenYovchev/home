#!/bin/bash
echo "************ Login in Azure with Service Principal"

# Variables data with credentials details
user_name=$1
un_password=$2
subscription=$3
environment=$4
administrator_login=$5
administrator_login_password=$6


##########################################
# Login to Azure with Service Principal
##########################################

az login -u $user_name  -p $un_password
az account set --subscription $subscription
az config set extension.use_dynamic_install=yes_without_prompt

echo "************ Initialize Modules and configure backends"

# Initialize process
terraform init

######################################
#Create workspace
######################################

echo "*********** Create or select workspace"
if [ $(terraform workspace list | grep -c "$4") -eq 0 ] ; then
  echo "Create new workspace $4"
  terraform workspace new "$4" -no-color
else
  echo "Switch to workspace $4"
  terraform workspace select "$4" -no-color
fi


######################################
# Create a plan for resources
######################################

terraform plan  -out plan.tfplan -var="administrator_login=$5" -var="administrator_login_password=$6"

######################################
# Deploy resources to Azure
######################################

terraform apply plan.tfplan