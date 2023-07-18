#NIC w10
resource "azurerm_network_interface" "nic-w10-001" {
  name                = "nic_w10-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["user"].id
    private_ip_address_allocation = "Dynamic"
  }
}

#VM w10
resource "azurerm_windows_virtual_machine" "vm-w10-001" {
  name                = "vm_w10-${var.project}-${var.env}-${var.location}"
  resource_group_name = azurerm_resource_group.rg-001.name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = var.vm_username
  admin_password      = var.vm_password
  computer_name       = "w10001"
  tags                = var.resource_tags
  network_interface_ids = [
    azurerm_network_interface.nic-w10-001.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "disk_w10-${var.project}-${var.env}-${var.location}"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-21h2-pro-g2"
    version   = "latest"
  }
}
