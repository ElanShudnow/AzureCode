# AzureCode
A place to share all the Azure Code I am writing. This includes PowerShell, Terraform, ARM, Bicep, Ansible, etc...

## PowerShell

| Script | Description |
| --------------- | --------------- |
| [VMSKURegionAvailability](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/VMSKURegionAvailability) | Takes a list of Virtual Machine SKUs from a CSV and Regions specified as an array in script and gets a list of what Virtual Machine SKUs are supported in the specified Regions.  This script will provide output of the results in both the PowerShell Console as well as a CSV output in the same directory the script is executed from. |
| [HRWRemoteCodeExecution](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/HRWRemoteCodeExecution) | Enables a Hybrid Runbook Worker (in or outside Azure) and executes a remote PowerShell Script against servers specified within a PowerShell Array.  The script leverages a Run-As Account with API Permissions against an Azure Key Vault to retrieve password for an ADDS Service Account that is used to execute the remote code. | 

## Terraform

| Script | Description |
| --------------- | --------------- |
| [Windows_VM_Marketplace](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/windows_vm_marketplace) | This Terraform Script executed on a Linux Server will deploy a single Windows Virtual Machine using a Marketplace Image. |
