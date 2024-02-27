terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "libracoder" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_storage_account" "libracodersa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.libracoder.name
  location                 = azurerm_resource_group.libracoder.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "libracoder_sa_c" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.libracodersa.name
  container_access_type = "private"
}


data "azurerm_storage_account_sas" "libracodersas" {
  connection_string = azurerm_storage_account.libracodersa.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2024-02-27"
  expiry = "2024-12-31"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = false
    filter  = false
  }
}

output "sas_token" {
  value = data.azurerm_storage_account_sas.libracodersas.sas
  sensitive = true
}

output "storage_account_connection_string" {
  value = azurerm_storage_account.libracodersa.primary_connection_string
  sensitive = true
}