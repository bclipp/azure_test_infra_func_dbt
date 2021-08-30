terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.74.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rec_api_blobber" {
  name     = "azure-functions-cptest-rg"
  location = "East US"
}


resource "azurerm_storage_account" "stor_api_blobber" {
  name                     = "functionsapptestsa"
  resource_group_name      = azurerm_resource_group.rec_api_blobber.name
  location                 = azurerm_resource_group.rec_api_blobber.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "service_plan_api_blobber" {
  name                = "api_blobber_service_plan"
  location            = azurerm_resource_group.rec_api_blobber.location
  resource_group_name = azurerm_resource_group.rec_api_blobber.name
  kind                = "FunctionApp"
  reserved = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }

}

resource "azurerm_function_app" "func_api_blobber" {
  name                = "apiBlobber"
  location            = azurerm_resource_group.rec_api_blobber.location
  resource_group_name = azurerm_resource_group.rec_api_blobber.name
  app_service_plan_id        = azurerm_app_service_plan.service_plan_api_blobber.id
  storage_account_name       = azurerm_storage_account.stor_api_blobber.name
  storage_account_access_key = azurerm_storage_account.stor_api_blobber.primary_access_key
}