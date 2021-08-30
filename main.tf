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

variable "DOCKER_URL" {
  type = string
}

variable "DOCKER_USERNAME" {
  type = string
}

variable "DOCKER_PASSWORD" {
  type = string
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
  kind                = "Linux"
  reserved = true
  sku {
    tier = "Premium"
    size = "EP1"
  }

}

resource "azurerm_function_app" "func_api_blobber" {
  name                = "apiBlobber"
  location            = azurerm_resource_group.rec_api_blobber.location
  resource_group_name = azurerm_resource_group.rec_api_blobber.name
  app_service_plan_id        = azurerm_app_service_plan.service_plan_api_blobber.id
  storage_account_name       = azurerm_storage_account.stor_api_blobber.name
  storage_account_access_key = azurerm_storage_account.stor_api_blobber.primary_access_key
  os_type                    = "linux"

  app_settings = {
        FUNCTION_APP_EDIT_MODE                    = "readOnly"
        https_only                                = true
        DOCKER_REGISTRY_SERVER_URL                = var.DOCKER_URL
        DOCKER_REGISTRY_SERVER_USERNAME           = var.DOCKER_USERNAME
        DOCKER_REGISTRY_SERVER_PASSWORD           = var.DOCKER_PASSWORD
        WEBSITES_ENABLE_APP_SERVICE_STORAGE       = false
    }

   site_config {
      linux_fx_version  = "DOCKER|${data.azurerm_container_registry.registry.login_server}/${var.image_name}:${var.tag}"
    }
}