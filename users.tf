#NIC w10
resource "azurerm_network_interface" "nicUser" {
  name                = "nicUser"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_4.id
    private_ip_address_allocation = "Dynamic"
  }
}

#VM w10
resource "azurerm_windows_virtual_machine" "vmUserWindows10" {
  name                = "vmUserWindows10"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = var.vm_username
  admin_password      = var.vm_password
  tags                = var.resource_tags
  network_interface_ids = [
    azurerm_network_interface.nicUser.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-21h2-pro-g2"
    version   = "latest"
  }
}