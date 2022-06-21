provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "monserrat-guzman"
    storage_account_name = "sa06212022"
    container_name       = "pulumi-terraform-states"
    key                  = "terraform.tfstate"
  }
}


data "azurerm_resource_group" "rg" {
  name = "monserrat-guzman"
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

# resource "azurerm_storage_account" "example" {
#   name                = "saterraform${random_string.random.result}"
#   resource_group_name = data.azurerm_resource_group.rg.name
#   location            = data.azurerm_resource_group.rg.location

#   account_kind             = "StorageV2"
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

resource "azurerm_network_security_group" "securitygroup" {
  name                = "sg-terraform"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    protocol                   = "*"
    priority                   = 100
    name                       = "Allow_SSH_Port"
    description                = "Allow SSH port"
    destination_port_range     = "22"
    destination_address_prefix = "*"
    source_port_ranges         = ["0-65535"]
    source_address_prefix      = "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Outbound"
    protocol                   = "*"
    priority                   = 4096
    name                       = "Allow_All_Outbound"
    source_port_ranges         = ["0-65535"]
    source_address_prefix      = "*"
    destination_port_ranges    = ["0-65535"]
    destination_address_prefix = "*"
  }

}

resource "azurerm_virtual_network" "vnet" {
  name                = "example-network-terraform"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  address_space = ["10.1.0.0/16"]
  dns_servers   = ["10.1.0.4", "10.1.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.1.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.1.2.0/24"
    security_group = azurerm_network_security_group.securitygroup.id
  }
}

# output "primaryStorageKey" {
#   value     = azurerm_storage_account.example.primary_access_key
#   sensitive = true
# }

output "vnetName" {
  value = azurerm_virtual_network.vnet.name
}

output "securityGroupId" {
  value = azurerm_network_security_group.securitygroup.id
}