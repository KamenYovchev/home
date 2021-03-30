##################################################################################
# PROVIDERS
################################################################################## 
terraform {
  required_version = " >= 0.13"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {

  features {}
//  subscription_id = var.supscription_id
//  client_id       = var.client_id
//  client_secret   = var.client_secret
//  tenant_id       = var.tennant_id
}
##################################################################################
# DATA
##################################################################################
//data "azurerm_app_service" "fe_app_name" {
//  name = "${var.fe_app_name}-app-svc-${local.env_name}"
//  resource_group_name = module.resource_group.resource_group_name
//}

data "azurerm_key_vault_secret" "environment_name" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "environment-name"
}


data "azurerm_key_vault" "kev_vault" {
  name = "wize-integration-kvt"
  resource_group_name = "wize-devops-rg"

}

data "azurerm_key_vault_secret" "sql_username" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "sql-username"
}


data "azurerm_key_vault_secret" "db_password" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "sql-password"
}

data "azurerm_key_vault_secret" "aad_client_id" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "azureClientID"
}

data "azurerm_key_vault_secret" "aad_client_secret" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "azureClientSecret"
}

data "azurerm_key_vault_secret" "aad_tennant_id" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "azureTennantId"
}

data "azurerm_key_vault_secret" "subscription_id" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "wize-subscription"
}

data "azurerm_key_vault_secret" "one_drive_id" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "oneDriveId"
}

data "azurerm_key_vault_secret" "guid_code" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "guidCode"
}

data "azurerm_key_vault_secret" "login-username" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "azcli-login-username"
}

data "azurerm_key_vault_secret" "login-password" {
  key_vault_id = data.azurerm_key_vault.kev_vault.id
  name = "azcli-login-password"
}


##################################################################################
# RESOURCES
##################################################################################
module "resource_group" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-resource-group.git"
  name = "${local.env_name}-rg"
  location  = var.location
}
module "storage_account" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-storage-account.git"
  name = "${replace(var.name,  "-", "")}storage${local.env_name}"
  location = var.location
  account_tier = var.account_tier
  replication_type = var.replication_type
  resource_group_name = module.resource_group.resource_group_name
}
module "sql_server" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-sql-server.git"
  name = "${var.name}-mssql-server-${local.env_name}"
  location = var.location
  sql_server_version = var.sql_server_version
  resource_group_name = module.resource_group.resource_group_name
  administrator_login = data.azurerm_key_vault_secret.sql_username.value
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value
  storage_endpoint = module.storage_account.storage_account_endpoint
  storage_account_access_key_is_secondary = var.storage_account_access_key_is_secondary
  storage_account_access_key = module.storage_account.storage_account_access_key
  retention_in_days = var.retention_in_days
}

module "sql_server_firewall_rule" {
  count = length(var.rules_names)
  source = "git@github.com:KamenYovchev/terraform-azurerm-sql-server-firewall-rule.git"
  name = element(var.rules_names, count.index)
  resource_group_name = module.resource_group.resource_group_name
  start_ip = element(var.start_ip, count.index)
  end_ip = element(var.end_ip, count.index)
  sql_server_name = module.sql_server.sql_server_name
  depends_on = [module.sql_server]

}

module "sql_database" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-sql-database.git"
  name = "${var.name}-mssql-db-${local.env_name}"
  resource_group_name = module.resource_group.resource_group_name
  location = var.location
  server_name = module.sql_server.sql_server_name
  storage_endpoint = module.storage_account.storage_account_endpoint
  storage_account_access_key = module.storage_account.storage_account_access_key
  storage_account_access_key_is_secondary = var.storage_account_access_key_is_secondary
  retention_in_days = var.retention_in_days
  depends_on = [module.sql_server]
  create_mode = var.db_create_mode
  edition = var.db_edition[terraform.workspace]
}

module "redis_cache" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-redis-cache.git"
  name = "${var.name}-redis-cahce-${local.env_name}"
  resource_group_name = module.resource_group.resource_group_name
  location = var.location
  sku_name = var.sku_name
  family = var.family
  capacity = var.capacity
  minimum_tls_version =var.minimum_tls_version
  enable_non_ssl_port = var.enable_non_ssl_port
  depends_on = [module.sql_server, module.sql_database]
}

module "cognitive_services" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-cognitive-account.git"
  location = var.location
  name = var.name
  resource_group_name = module.resource_group.resource_group_name
  cs_sku_name = var.cs_sku_name
  kind = var.cs_kind
}

module "event_grid_topic" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-event-grid-topic.git"
  name = "${var.name}-event-grid-${local.env_name}"
  location = var.location
  resource_group_name = module.resource_group.resource_group_name
}

module "media_service_account" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-media-service-account.git"
  name = "${replace(var.name,  "-", "")}media${local.env_name}"
  location = var.location
  resource_group_name = module.resource_group.resource_group_name
  storage_account_id = module.storage_account.storage_account_id
  is_primary = var.is_primary
}

module "service_bus" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-service-bus.git"
  name = "${var.name}-service-bus-${local.env_name}"
  location = var.location
  resource_group_name = module.resource_group.resource_group_name
  sb_sku = var.sb_sku
  sb_capacity = var.sb_capacity
}

module "signalr" {
  source = "git@github.com:KamenYovchev/terraform-azurerm-signalr.git"
  name = "${var.name}-signalr-${local.env_name}"
  location = var.location
  resource_group_name = module.resource_group.resource_group_name
  sr_sku_name = var.sr_sku_name
  sr_sku_capacity = var.sr_sku_capacity
  flag = var.flag
  value = var.value
  allowed_origins = var.allowed_origins
}

module "app_service_plan" {
  source  = "git@github.com:KamenYovchev/terraform-azurerm-app-service-plan.git"
  name = "${var.name}-svc-plan-${terraform.workspace}"
  location = var.location
  size = var.size[terraform.workspace]
  tier = var.tier[terraform.workspace]
  resource_group_name = module.resource_group.resource_group_name
  # insert the 5 required variables here
}

module "fe_app" {
  source  = "git@github.com:KamenYovchev/terraform-azurerm-fe-app-service.git"
  name = "${element(var.applications, 0)}-app-svc-${local.env_name}"
  email_url = local.web_url
  storage_account_connection_string = module.storage_account.primary_connection_string
  ad_aad_client_id = data.azurerm_key_vault_secret.aad_client_id.value
  api_key = module.cognitive_services.cognitive_account_api_key
  app_service_plan_id = module.app_service_plan.app_service_plan_id
  drive_id = data.azurerm_key_vault_secret.one_drive_id.value
  entity_guid = data.azurerm_key_vault_secret.guid_code.value
  location = var.location
  ms_aad_client_id = data.azurerm_key_vault_secret.aad_client_id.value
  ms_aad_client_secret = data.azurerm_key_vault_secret.aad_client_secret.value
  ms_aad_tennant_id = data.azurerm_key_vault_secret.aad_tennant_id.value
  ms_account_name = module.media_service_account.media_service_name
  ms_resource_group_name = module.resource_group.resource_group_name
  ms_susbscription_id = data.azurerm_key_vault_secret.subscription_id.value
  od_aad_client_id = data.azurerm_key_vault_secret.aad_client_id.value
  od_aad_client_secret = data.azurerm_key_vault_secret.aad_client_secret.value
  od_aad_tennant_id = data.azurerm_key_vault_secret.aad_tennant_id.value
  redis_cache_connection_string = module.redis_cache.redis_cache_connection_string
  redis_cache_coockies_connection_string = module.redis_cache.redis_cache_connection_string
  resource_group_name = module.resource_group.resource_group_name
  service_bus_connection_string = module.service_bus.service_bus_connection_string
  signalR_connection_string = module.signalr.signalR_connection_string
  susbscription_id = data.azurerm_key_vault_secret.subscription_id.value
  web_app_url = local.web_url
}


module "application_insights" {
  count = length(var.applications)
  source  = "git@github.com:KamenYovchev/terraform-azurerm-application-insights.git"
  name = "${element(var.applications, count.index)}-app-insights-${local.env_name}"
  resource_group_name = module.resource_group.resource_group_name
  location = var.location
  # insert the 4 required variables here
}

resource "null_resource" "app_insights_mapping" {
  provisioner "local-exec" {
    command = "bash ./app_insights_mapping.sh ${data.azurerm_key_vault_secret.login-username.value} ${data.azurerm_key_vault_secret.login-password.value} ${data.azurerm_key_vault_secret.aad_tennant_id.value} ${data.azurerm_key_vault_secret.subscription_id.value} ${module.resource_group.resource_group_name} ${data.azurerm_key_vault_secret.environment_name.value}"

  }
  depends_on = [module.fe_app, module.application_insights]
}





