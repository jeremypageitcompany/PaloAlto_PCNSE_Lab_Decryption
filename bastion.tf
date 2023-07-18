##PIP bastion
resource "azurerm_public_ip" "pip-bastion-001" {
  name                = "pip_bastion-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.resource_tags
}

# subnet
resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg-001.name
  virtual_network_name = azurerm_virtual_network.vnet-001.name
  address_prefixes     = ["10.0.7.0/24"]
}

##Host Bastion
resource "azurerm_bastion_host" "bastion-001" {
  name                = "bastion-host-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags

  ip_configuration {
    name                 = "internal"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.pip-bastion-001.id
  }
}
