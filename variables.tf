variable "project" {
  description = "project name"
}

variable "location" {
  description = "Location of the resource group."
}

variable "env" {
  description = "Environment deployed"
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    org         = "jeremypageitcompany",
    environment = "lab"
  }
}

variable "subnet_vnet" {
  description = "subnet for the VNET"
  default     = "10.0.0.0/16"
}

variable "subnet" {
  description = "prefixes and names for different subnets"
  default = {
    "mgmt" = {
      "prefix"  = ["10.0.0.0/24"]
      "firstIp" = "10.0.0.4"
    },
    "untrust" = {
      "prefix"  = ["10.0.1.0/24"]
      "firstIp" = "10.0.1.4"
    },
    "trust" = {
      "prefix"  = ["10.0.2.0/24"]
      "firstIp" = "10.0.2.4"
    },
    "dmz" = {
      "prefix"  = ["10.0.3.0/24"]
      "firstIp" = "10.0.3.4"
    }
    "user" = {
      "prefix"  = ["10.0.4.0/24"]
      "firstIp" = "10.0.4.4"
    },
    "serverInternal" = {
      "prefix"  = ["10.0.5.0/24"]
      "firstIp" = "10.0.5.4"
    },
    "serverDmz" = {
      "prefix"  = ["10.0.6.0/24"]
      "firstIp" = "10.0.6.4"
    }
  }
}


variable "vm_publisher" {
  default = "paloaltonetworks"
}

variable "vm_sku" {
  default = "bundle1"
}

variable "vm_offer" {
  default = "vmseries-flex"
}

variable "vm_version" {
  default = "latest"
}
variable "vm_size" {
  description = "Size of the VM for the Palo Alto"
  default     = "Standard_DS3_v2" #vm100
}
variable "vm_username" {
  description = "vm username"
  type        = string
  sensitive   = true
}

variable "vm_password" {
  description = "vm password"
  type        = string
  sensitive   = true
}

