terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {

  }
}


#Market Place Agreement
##Uncomment if you have issue with the Market Place Agreement
/*
resource "azurerm_marketplace_agreement" "paloAgreement" {
  publisher = "paloaltonetworks"
  offer     = "vmseries-flex"
  plan      = "bundle1"
}

resource "azurerm_marketplace_agreement" "microsoftAgreementW10" {
  publisher = "MicrosoftWindowsDesktop"
  offer     = "Windows-10"
  plan      = "win10-21h2-pro-g2"
}

resource "azurerm_marketplace_agreement" "microsoftAgreementAD" {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  plan      = "2016-Datacenter"
}
*/


# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = join("", [var.project, "-rg"])
  location = var.location
  tags     = var.resource_tags
}

# VNET
resource "azurerm_virtual_network" "vnet" {
  name                = join("", [var.project, "-vnet"])
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = [var.subnet_vnet]
  tags                = var.resource_tags
}

## Subnets
#MGMT Palo
resource "azurerm_subnet" "subnet_0" {
  name                 = join("", ["subnet_0", var.suffix_0])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_0]
}

#Untrust Palo
resource "azurerm_subnet" "subnet_1" {
  name                 = join("", ["subnet_1", var.suffix_1])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_1]
}

#Trust Palo
resource "azurerm_subnet" "subnet_2" {
  name                 = join("", ["subnet_2", var.suffix_2])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_2]
}

#DMZ Palo
resource "azurerm_subnet" "subnet_3" {
  name                 = join("", ["subnet_3", var.suffix_3])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_3]
}

#W10 User
resource "azurerm_subnet" "subnet_4" {
  name                 = join("", ["subnet_4", var.suffix_4])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_4]
}

#AD
resource "azurerm_subnet" "subnet_5" {
  name                 = join("", ["subnet_5", var.suffix_5])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_5]
}

#Ubuntu DMZ
resource "azurerm_subnet" "subnet_6" {
  name                 = join("", ["subnet_6", var.suffix_6])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_6]
}

#Bastion
resource "azurerm_subnet" "subnet_7" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_7]
}

##Route Table
#toTrustInterface
resource "azurerm_route_table" "udr_0" {
  name                          = join("", ["udr_0", var.suffix_2])
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  tags                          = var.resource_tags
  disable_bgp_route_propagation = true

  route {
    name                   = "DefaultRoutePaloTrust"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.subnet_2_first_ip
  }

}

#toDmzInterface
resource "azurerm_route_table" "udr_1" {
  name                          = join("", ["udr_1", var.suffix_3])
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  tags                          = var.resource_tags
  disable_bgp_route_propagation = true

  route {
    name                   = "DefaultRoutePaloTrust"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.subnet_3_first_ip
  }

}

## Associate route with subnet
#W10 subnet
resource "azurerm_subnet_route_table_association" "association_subnet_0" {
  subnet_id      = azurerm_subnet.subnet_4.id
  route_table_id = azurerm_route_table.udr_0.id
}

#AD subnet
resource "azurerm_subnet_route_table_association" "association_subnet_1" {
  subnet_id      = azurerm_subnet.subnet_5.id
  route_table_id = azurerm_route_table.udr_0.id
}

#DMZ subnet
resource "azurerm_subnet_route_table_association" "association_subnet_2" {
  subnet_id      = azurerm_subnet.subnet_6.id
  route_table_id = azurerm_route_table.udr_1.id
}