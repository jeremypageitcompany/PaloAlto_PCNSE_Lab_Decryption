#NSG MGMT Palo
resource "azurerm_network_security_group" "nsg-001" {
  name                = "nsg_mgmt-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags

  security_rule = [{
    access                                     = "Allow"
    description                                = "AllowInboundHome"
    destination_address_prefix                 = "*"
    destination_port_range                     = ""
    direction                                  = "Inbound"
    name                                       = "AllowInboundHome"
    priority                                   = 100 # between 100 - 4096
    protocol                                   = "Tcp"
    source_address_prefix                      = "${chomp(data.http.myip.response_body)}"
    source_port_range                          = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_ranges                    = ["22", "443"]
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_ranges                         = []
  }]

}

# Empty NSG for the untrust interface
resource "azurerm_network_security_group" "nsg-002" {
  name                = "nsg_untrust-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags
}

#NSG Association
#MGMT
resource "azurerm_subnet_network_security_group_association" "association_0" {
  subnet_id                 = azurerm_subnet.subnet-000["mgmt"].id
  network_security_group_id = azurerm_network_security_group.nsg-001.id
}

#Untrust
resource "azurerm_subnet_network_security_group_association" "association_1" {
  subnet_id                 = azurerm_subnet.subnet-000["untrust"].id
  network_security_group_id = azurerm_network_security_group.nsg-002.id
}

##Public IP
#MGMT
resource "azurerm_public_ip" "pip-001" {
  name                = "pip_mgmt-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  allocation_method   = "Static"
  tags                = var.resource_tags
  sku                 = "Standard"

}

#Untrust
resource "azurerm_public_ip" "pip-002" {
  name                = "pip_untrust-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  allocation_method   = "Static"
  tags                = var.resource_tags
  sku                 = "Standard"

}

##Network interfaces
#MGMT PALO
resource "azurerm_network_interface" "nic-mgmt-001" {
  name                = "nic_mgmt-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["mgmt"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.subnet.mgmt.firstIp
    public_ip_address_id          = azurerm_public_ip.pip-001.id
  }
}

#Untrust Palo
resource "azurerm_network_interface" "nic-untrust-001" {
  name                          = "nic_untrust-${var.project}-${var.env}-${var.location}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg-001.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true
  tags                          = var.resource_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["untrust"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.subnet.untrust.firstIp
    public_ip_address_id          = azurerm_public_ip.pip-002.id
  }
}

#TrustPalo
resource "azurerm_network_interface" "nic-trust-001" {
  name                          = "nic_trust-${var.project}-${var.env}-${var.location}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg-001.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true
  tags                          = var.resource_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["trust"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.subnet.trust.firstIp
  }
}

#DMZPalo
resource "azurerm_network_interface" "nic-dmz-001" {
  name                          = "nic_dmz-${var.project}-${var.env}-${var.location}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg-001.name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true
  tags                          = var.resource_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-000["dmz"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.subnet.dmz.firstIp
  }
}


# VM
resource "azurerm_virtual_machine" "vm-palo-001" {
  name                = "vm_palo-${var.project}-${var.env}-${var.location}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-001.name
  tags                = var.resource_tags
  vm_size             = var.vm_size

  plan {
    #bundle1 with license
    name      = var.vm_sku
    publisher = var.vm_publisher
    product   = var.vm_offer
  }

  storage_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku
    version   = var.vm_version
  }

  # FromImage will automatically create it
  storage_os_disk {
    name          = "disk_palo-${var.project}-${var.env}-${var.location}"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "palovm1"
    admin_username = var.vm_username
    admin_password = var.vm_password

  }

  primary_network_interface_id = azurerm_network_interface.nic-mgmt-001.id
  network_interface_ids = [
    azurerm_network_interface.nic-mgmt-001.id,
    azurerm_network_interface.nic-untrust-001.id,
    azurerm_network_interface.nic-trust-001.id,
    azurerm_network_interface.nic-dmz-001.id
  ]

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
