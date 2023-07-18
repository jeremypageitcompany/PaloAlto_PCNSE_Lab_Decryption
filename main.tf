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
resource "azurerm_resource_group" "rg-001" {
  name     = "rg-${var.project}-${var.env}-${var.location}"
  location = var.location
  tags     = var.resource_tags
}

# VNET
resource "azurerm_virtual_network" "vnet-001" {
  name                = "vnet-${var.project}-${var.env}-${var.location}"
  resource_group_name = azurerm_resource_group.rg-001.name
  location            = var.location
  address_space       = [var.subnet_vnet]
  tags                = var.resource_tags
}

# Subnets
resource "azurerm_subnet" "subnet-000" {
  for_each = var.subnet

  name                 = "subnet_${each.key}-${var.project}-${var.env}-${var.location}"
  resource_group_name  = azurerm_resource_group.rg-001.name
  virtual_network_name = azurerm_virtual_network.vnet-001.name
  address_prefixes     = each.value.prefix
}


##Route Table
#toTrustInterface
resource "azurerm_route_table" "udr-001" {
  name                          = "udr-trust-${var.project}-${var.env}-${var.location}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg-001.name
  tags                          = var.resource_tags
  disable_bgp_route_propagation = true

  route {
    name                   = "DefaultRoutePaloTrust"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.subnet.trust.firstIp
  }

}

#toDmzInterface
resource "azurerm_route_table" "udr-002" {
  name                          = "udr-dmz-${var.project}-${var.env}-${var.location}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg-001.name
  tags                          = var.resource_tags
  disable_bgp_route_propagation = true

  route {
    name                   = "DefaultRoutePaloDmz"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.subnet.dmz.firstIp
  }

}

## Associate route with subnet
#W10 subnet
resource "azurerm_subnet_route_table_association" "association_subnet_0" {
  subnet_id      = azurerm_subnet.subnet-000["user"].id
  route_table_id = azurerm_route_table.udr-001.id
}

#AD subnet
resource "azurerm_subnet_route_table_association" "association_subnet_1" {
  subnet_id      = azurerm_subnet.subnet-000["serverInternal"].id
  route_table_id = azurerm_route_table.udr-001.id
}

#DMZ subnet
resource "azurerm_subnet_route_table_association" "association_subnet_2" {
  subnet_id      = azurerm_subnet.subnet-000["serverDmz"].id
  route_table_id = azurerm_route_table.udr-002.id
}