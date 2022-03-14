variable "location" {}

variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
  default = "eshudnow"
}

variable "admin_password" {
  type        = string
  description = "Password must meet Azure complexity requirements"
  sensitive   = true
}

variable "prefix" {
  type    = string
  default = "my"
}

variable "tags" {
  type = map

  default = {
    Environment = "Terraform Demo"
    Dept        = "Engineering"
  }
}

variable "sku" {
  default = {
    westus2 = "2016-Datacenter"
    eastus  = "2019-Datacenter"
  }
}

variable "inbound_rules" {
  type = map
  description = "A map of allowed inbound ports and their priority value"
  default = {
    101 = 3389
    103 = 443
  }
}