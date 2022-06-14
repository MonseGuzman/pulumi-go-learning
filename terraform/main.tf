provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "monserrat-guzman"
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "example" {
  name                = "saterraform${random_string.random.result}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "primaryStorageKey" {
  value = azurerm_storage_account.example.primary_access_key
  sensitive = true
}


###### NEW CHANGES
resource "azurerm_virtual_network" "vnet" {
  name                = "example-network-terraform"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  
  address_space       = ["10.1.0.0/16"]
  dns_servers         = ["10.1.0.4", "10.1.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.1.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.1.2.0/24"
    # security_group = azurerm_network_security_group.example.id
  }
}

output "vnetName" {
  value = azurerm_virtual_network.vnet.name
}