variable "azure-region" {
  type    = string
  default = "northcentralus"
}

variable "azure-resource-group" {
  type    = string
  default = "Packer-RG"
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

source "azure-arm" "windows" {
  client_id                         = "${var.azure_client_id}"
  client_secret                     = "${var.azure_client_secret}"
  communicator                      = "winrm"
  image_offer                       = "WindowsServer"
  image_publisher                   = "MicrosoftWindowsServer"
  image_sku                         = "2019-datacenter"
  location                          = "${var.azure-region}"
  managed_image_name                = "WindowsServer2022-IIS-Packer"
  managed_image_resource_group_name = "${var.azure-resource-group}"
  os_type                           = "Windows"
  subscription_id                   = "${var.azure_subscription_id}"
  tenant_id                         = "${var.azure_tenant_id}"
  vm_size                           = "${var.azure-vm-size}"
  winrm_insecure                    = true
  winrm_timeout                     = "3m"
  winrm_use_ssl                     = true
  winrm_username                    = "packer"
}

build {
  sources = ["source.azure-arm.windows"]

  provisioner "powershell" {
    inline = [
      "# Install IIS", 
      "Install-WindowsFeature -name Web-Server -IncludeManagementTools", 
      "Install-WindowsFeature Web-Asp-Net45", 
      "while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }", 
      "while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }", 
      "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit", 
      "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"]
  }
}
