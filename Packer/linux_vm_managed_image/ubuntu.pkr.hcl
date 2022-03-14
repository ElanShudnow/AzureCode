variable "azure-region" {
  type    = string
  default = "northcentralus"
}

variable "azure-resource-group" {
  type    = string
  default = "packer-rg"
}

variable "azure-vm-size" {
  type    = string
  default = "Standard_DS1_v2"
}

variable "azure_client_id" {
  type    = string
  default = "${env("ARM_CLIENT_ID")}"
}

variable "azure_client_secret" {
  type    = string
  default = "${env("ARM_CLIENT_SECRET")}"
}

variable "azure_subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "azure_tenant_id" {
  type    = string
  default = "${env("ARM_TENANT_ID")}"
}

source "azure-arm" "ubuntu" {
  client_id                         = "${var.azure_client_id}"
  client_secret                     = "${var.azure_client_secret}"
  image_offer                       = "UbuntuServer"
  image_publisher                   = "Canonical"
  image_sku                         = "18.04-LTS"
  location                          = "${var.azure-region}"
  managed_image_name                = "Ubuntu-Packer"
  managed_image_resource_group_name = "${var.azure-resource-group}"
  os_type                           = "Linux"
  subscription_id                   = "${var.azure_subscription_id}"
  tenant_id                         = "${var.azure_tenant_id}"
  vm_size                           = "${var.azure-vm-size}"
}


build {
  sources = ["source.azure-arm.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt update", 
      "sudo apt install nginx -y"
      ]
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = [
      "apt-get update",
      "apt-get upgrade -y",
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
      ]
    inline_shebang  = "/bin/sh -x"
  }
}
