## AD server
#nic ad
resource "azurerm_network_interface" "nic-ad-001" {
  name                = "nic_ad-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["serverInternal"].id
    private_ip_address_allocation = "Dynamic"
  }
}

#VM AD
resource "azurerm_windows_virtual_machine" "vm-ad-001" {
  name                = "vm_ad-${var.project}-${var.env}-${var.location}"
  resource_group_name = azurerm_resource_group.rg-001.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.vm_username
  admin_password      = var.vm_password
  tags                = var.resource_tags
  computer_name       = "ad001"
  network_interface_ids = [
    azurerm_network_interface.nic-ad-001.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "disk_ad-${var.project}-${var.env}-${var.location}"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

##Linux Server DMZ
#nic
resource "azurerm_network_interface" "nic-linux-001" {
  name                = "nic_linux-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags

  ip_configuration {

    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["serverDmz"].id
    private_ip_address_allocation = "Dynamic"
  }
}

#VM linux
resource "azurerm_linux_virtual_machine" "vm-linux-001" {
  name                = "vm_linux-${var.project}-${var.env}-${var.location}"
  resource_group_name = azurerm_resource_group.rg-001.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.vm_username
  tags                = var.resource_tags
  computer_name       = "linux001"

  # If not using ssh key, require to set password auth to false
  disable_password_authentication = false
  admin_password                  = var.vm_password


  network_interface_ids = [
    azurerm_network_interface.nic-linux-001.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "disk_linux-${var.project}-${var.env}-${var.location}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
