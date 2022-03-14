# AzureCode
A place to share all the Azure Code I am writing. This includes PowerShell, Terraform, ARM, Bicep, Ansible, etc...

> **Note**: As this is a relatively new repository, I will be adding new code almost daily for code I have previously written. 

## PowerShell

| Script | Description |
| --------------- | --------------- |
| [VMSKURegionAvailability](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/VMSKURegionAvailability) | Takes a list of Virtual Machine SKUs from a CSV and Regions specified as an array in script and gets a list of what Virtual Machine SKUs are supported in the specified Regions.  This script will provide output of the results in both the PowerShell Console as well as a CSV output in the same directory the script is executed from. |
| [HRWRemoteCodeExecution](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/HRWRemoteCodeExecution) | Enables a Hybrid Runbook Worker (in or outside Azure) and executes a remote PowerShell Script against servers specified within a PowerShell Array.  The script leverages a Run-As Account with API Permissions against an Azure Key Vault to retrieve password for an ADDS Service Account that is used to execute the remote code. | 
| [QuotaReport](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/QuotaReport) | Imports a Settings.json that defines Subscriptions, Regions, and Percentage Thresholds and retreives CPU Quotas and Subnet Usage Information and outputs results to an HTML. Based on thresholds defined in Settings.json, the percentage column will be color coded (green, yellow, or red) accordingly. |

## Terraform

| Script | Description |
| --------------- | --------------- |
| [Windows_VM_Marketplace](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/windows_vm_marketplace) | This Terraform Script executed on a Linux Server will deploy a single Windows Virtual Machine using a Marketplace Image. |
| [Linux_VM_Marketplace](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/linux_vm_marketplace) | This Terraform Script executed on a Linux Server will deploy a single Ubuntu Virtual Machine using a Marketplace Image. |
