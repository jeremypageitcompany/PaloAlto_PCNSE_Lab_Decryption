## AD server
#nic ad
resource "azurerm_network_interface" "nicAd" {
  name                = "nicAd"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_5.id
    private_ip_address_allocation = "Dynamic"
  }
}

#VM AD
resource "azurerm_windows_virtual_machine" "vmAd" {
  name                = "DC01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.vm_username
  admin_password      = var.vm_password
  tags                = var.resource_tags
  network_interface_ids = [
    azurerm_network_interface.nicAd.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
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
resource "azurerm_network_interface" "nicLinux" {
  name                = "nicLinux"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags

  ip_configuration {

    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_6.id
    private_ip_address_allocation = "Dynamic"
  }
}

#VM linux
resource "azurerm_linux_virtual_machine" "vmLinux" {
  name                = "vmLinux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = var.vm_username
  tags                = var.resource_tags

  # If not using ssh key, require to set password auth to false
  disable_password_authentication = false
  admin_password                  = var.vm_password


  network_interface_ids = [
    azurerm_network_interface.nicLinux.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myOSdiskLinux"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}