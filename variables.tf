 
##################################################################################
# VARIABLES
##################################################################################

variable "location" {
  type    = string
  default = "uksouth"
}

variable "name" {
  type    = string
  default = "wize"
}

variable "start_ip" {
    type = list(string)
    default = ["185.162.115.196", "0.0.0.0"]
}

variable "end_ip" {
    type = list(string)
    default = ["185.162.115.196", "0.0.0.0"]
}

variable "rules_names" {
    type = list(string)
    default = ["jenkins", "allow_azure_services"]
}

variable "applications" {
    type = list(string)
    default = ["web-app", "public-api", "assessment", "configuration", "employee", "identity",  "learning", "report", "talent", "wizechat", "worker1", "worker2", "worker3"]
}

variable "account_tier" {
    type = string
    default = "Standard"
}

variable "replication_type" {
    type = string
    default = "LRS"
}

variable "retention_in_days" {
    type = number
    default = 7
}

variable "storage_account_access_key_is_secondary" {
    type = bool
    default = true
}

variable "sql_server_version" {
  type = string
  description = "(optional) version of sql server instance"
  default = "12.0"
}

variable sku_name {
    type = string
    default = "Premium" 
}

variable family {
    type = string
    default = "P"
}

variable "capacity" {
    type = number
    default = 1
}

variable "minimum_tls_version" {
    type = number 
    default = 1.2
}

variable "enable_non_ssl_port" {
    type = bool
    default  = true
}

variable "db_create_mode" {
    type = string
    default = "Default"
}
variable "db_edition" {
    type = map(string)
    default = {
        Integration = "Standard"
        Demo = "Standard"
        Performance = "GeneralPurpose"
        Staging = "GeneralPurpose"
        Production = "GeneralPurpose"

    }
}

variable "cs_sku_name" {
    type = string
    default = "S0"
}

variable "cs_kind" {
    type = string
    default = "CognitiveServices"
}

variable "is_primary" {
    type = bool
    default = true
}

variable "sb_sku" {
    type = string
    default = "Standard"
}

variable "sb_capacity" {
    type = number
    default = 0
}

variable "sr_sku_name" {
    type = string
    default = "Standard_S1"
}

variable "sr_sku_capacity" {
    type = number
    default = 1
}

variable "allowed_origins" {
    type = list(string)
    default = ["*"]
}

variable "flag" {
    type = string
    default = "ServiceMode"
}

variable "value" {
    type = string
    default = "Default"
}

variable size {
    type = map(string)
    default = {
        Integration = "B3"
        prod = "P3V3"
    }

}

variable tier {
    type = map(string)
    default = {
        Integration = "Basic"
        prod = "PremiumV2"
    }

}

variable "search_sku" {
  default = "standard"
  description = "The sku tos use for the azure search service"
}

variable "account_sku" {
  default = "S0"
  description = "The sku to use for the azure congative account"
}

variable "plan_id" {
  default = ""
  description = "The app service plan to use.  If none is passed it will create one"
}
##################################################################################
# LOCALS
##################################################################################

locals {

env_name = lower(terraform.workspace)
web_url = "https://${element(var.applications, 0)}-app-svc-${local.env_name}.azurewebsites.net"
}