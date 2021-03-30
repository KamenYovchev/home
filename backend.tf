terraform {
  backend "azurerm" {
    resource_group_name  = "wize-devops-rg"
    storage_account_name = "wizedevopssa"
    container_name = "terraform-states"
    key = "integration.tfstate"
  }
}