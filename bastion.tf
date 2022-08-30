##PIP bastion
resource "azurerm_public_ip" "pipBastion" {
  name                = "pipBastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.resource_tags
}

##Host Bastion
resource "azurerm_bastion_host" "bastion" {
  name                = "bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags

  ip_configuration {
    name                 = "ipConfiguration"
    subnet_id            = azurerm_subnet.subnet_7.id
    public_ip_address_id = azurerm_public_ip.pipBastion.id
  }
}