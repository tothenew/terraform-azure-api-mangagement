locals {
  env         = var.environment
  name        = var.client_name
  name_prefix = "${local.env}${local.name}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name_prefix}rg"
  location = var.location
  tags     = var.extra_tags
}

module "storage_account" {
  source = "git::https://github.com/tothenew/terraform-azure-storageaccount.git"

  account_name               = "{local.name_prefix}sa"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  log_analytics_workspace_id = module.log_analytics.workspace_id

  account_kind = "BlobStorage"
}


module "log_analytics" {
  source = "git::https://github.com/tothenew/terraform-azure-loganalytics.git"

  workspace_name      = "${local.name_prefix}-log"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.extra_tags
}

module "apim" {
  source = "../../"

  location    = var.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack

  resource_group_name = azurerm_resource_group.rg.name

  sku_tier     = "Standard"
  sku_capacity = 1

  publisher_name  = "Contoso ApiManager"
  publisher_email = "api_manager@test.com"

  named_values = [
    {
      name   = "my_named_value"
      value  = "my_secret_value"
      secret = true
    },
    {
      display_name = "My second value explained"
      name         = "my_second_value"
      value        = "my_not_secret_value"
    }
  ]

  additional_location = [
    {
      location  = "eastus2"
      subnet_id = var.subnet_id
    },
  ]

  logs_destinations_ids = [
    module.storage_account.account_id,
    module.log_analytics.workspace_id
  ]
}