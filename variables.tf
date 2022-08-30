variable "project" {
  default     = "paloDecrypt"
  description = "project name"
}

variable "location" {
  default     = "canadaeast"
  description = "Location of the resource group."
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    org         = "jeremypageitcompany",
    environment = "terraform"
  }
}

variable "suffix_0" {
  default = "-mgmt"
}

variable "suffix_1" {
  default = "-untrust"
}

variable "suffix_2" {
  default = "-trust"
}

variable "suffix_3" {
  default = "-dmz"
}

variable "suffix_4" {
  default = "-users"
}

variable "suffix_5" {
  default = "-serversInternal"
}

variable "suffix_6" {
  default = "-serversDmz"
}

variable "subnet_vnet" {
  default = "10.0.0.0/16"
}

variable "subnet_0" {
  default = "10.0.0.0/24"
}
variable "subnet_1" {
  default = "10.0.1.0/24"
}
variable "subnet_2" {
  default = "10.0.2.0/24"
}
variable "subnet_3" {
  default = "10.0.3.0/24"
}
variable "subnet_4" {
  default = "10.0.4.0/24"
}
variable "subnet_5" {
  default = "10.0.5.0/24"
}
variable "subnet_6" {
  default = "10.0.6.0/24"
}
variable "subnet_7" {
  default = "10.0.7.0/24"
}

variable "subnet_0_first_ip" {
  default = "10.0.0.4"
}

variable "subnet_1_first_ip" {
  default = "10.0.1.4"
}

variable "subnet_2_first_ip" {
  default = "10.0.2.4"
}

variable "subnet_3_first_ip" {
  default = "10.0.3.4"
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