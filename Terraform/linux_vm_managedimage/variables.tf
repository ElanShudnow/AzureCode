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
    Environment = "Terraform GS"
    Dept        = "Engineering"
  }
}

variable "inbound_rules" {
  type = map
  description = "A map of allowed inbound ports and their priority value"
  default = {
    101 = 22
    103 = 443
  }
}