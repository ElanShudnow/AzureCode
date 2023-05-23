# AzureCode
A place to share all the Azure Code I am writing. This includes PowerShell, Terraform, ARM, Bicep, Ansible, etc...  

For additional Azure content, visit my blog: [https://www.shudnow.io](https://www.shudnow.io)

## PowerShell

| Script | Description |
| --------------- | --------------- |
| [VMSKURegionAvailability](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/VMSKURegionAvailability) | Takes a list of Virtual Machine SKUs from a CSV and Regions specified as an array in script and gets a list of what Virtual Machine SKUs are supported in the specified Regions.  This script will provide output of the results in both the PowerShell Console as well as a CSV output in the same directory the script is executed from. |
| [HRWRemoteCodeExecution](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/HRWRemoteCodeExecution) | Enables a Hybrid Runbook Worker (in or outside Azure) and executes a remote PowerShell Script against servers specified within a PowerShell Array.  The script leverages a Run-As Account with API Permissions against an Azure Key Vault to retrieve password for an ADDS Service Account that is used to execute the remote code. | 
| [QuotaReport](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/QuotaReport) | Imports a Settings.json that defines Subscriptions, Regions, and Percentage Thresholds and retreives CPU Quotas and Subnet Usage Information and outputs results to an HTML. Based on thresholds defined in Settings.json, the percentage column will be color coded (green, yellow, or red) accordingly. |
| [ServicePrincipalExpirationReport](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/ServicePrincipalExpirationReport) | Obtain a list of all Azure AD Application Service Principals and obtain a list of certificates and secrets associated and their expiration dates. This list will be created in an HTML Output where all expirations have color coded cells based on certain criteria.  Criteria is outlined in the script README. |
| [AzSubnetAvailability](https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/AzSubnetAvailability) | Obtain a list of all Azure AD Application Service Principals and obtain a list of certificates and secrets associated and their expiration dates. This list will be created in an HTML Output where all expirations have color coded cells based on certain criteria.  Criteria is outlined in the script README. |
| [AvailabilityZoneMapping](https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/AvailabilityZoneMapping) | This PowerShell Script takes a list of Azure Subscriptions you have selected in Grid View and cycles through each subscription and obtains information about the Logical to Physical Zone Mapping.  Information is collected and outputted to an output.csv in the same folder the script was executed in. |
| [DDOSVnetReport](https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/DDOSVnetReport) | This script creates an HTML Report on DDOS Standard Virtual Network Assignment across a single or all subscriptions.  This will help determine what Virtual Networks have DDOS Standard Plans assigned to Virtual Networks and which do not. |
| [AzPublicIPReport](https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/AzPublicIPReport) | This script creates an HTML Report on what Public IP Addresses exist across a single or all subscriptions.  This will also include information on the recently announced Public IP DDOS Protection feature. |
| [AzCostAdvisorMGScope](https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/AzCostAdvisorMGScope) | This script creates a report for Azure Advisor Cost Recommendations at the Management Group Scope in a recursive or non-recursive manner. |
| [AzVNETOverlap](https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/AzVNETOverlap) | This script creates will output any VNET that overlaps with another VNET within all Azure Subscriptions or specified Azure Subscriptions. |

## Terraform

| Script | Description |
| --------------- | --------------- |
| [Windows_VM_Marketplace](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/windows_vm_marketplace) | This Terraform Script executed on a Linux Server will deploy a single Windows Virtual Machine using a Marketplace Image. |
| [Linux_VM_Marketplace](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/linux_vm_marketplace) | This Terraform Script executed on a Linux Server will deploy a single Ubuntu Virtual Machine using a Marketplace Image. |
| [Windows_VM_ManagedImage](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/windows_vm_managedimage) | This Terraform Script executed on a Linux Server will deploy a single Windows Virtual Machine using a Managed Image. |
| [Linux_VM_ManagedImage](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/linux_vm_managedimage) | This script creates an HTML Report on Subnet Availability across a single or all subscriptions.  This will help in the decision making process if VNET sizes need to be increased and potentially additional subnets need to be created. |

## Packer

| Script | Description |
| --------------- | --------------- |
| [Windows_VM_Managed_Image](https://github.com/ElanShudnow/AzurePS/tree/main/Packer/windows_vm_managed_image) | Leverage a Packer Script executed on a Linux Server to deploy a Generalized Windows Server 2022 Managed Image for future VM deployments leveraging Terraform or manual procedures. Packer will configured the Managed Image to have IIS installed. |
| [Linux_VM_Managed_Image](https://github.com/ElanShudnow/AzurePS/tree/main/Packer/linux_vm_managed_image) | Leverage a Packer Script executed on a Linux Server to deploy a Generalized Linux (Ubuntu) Managed Image for future VM deployments leveraging Terraform or manual procedures. Packer will configured the Managed Image to have IIS installed. |
| [Linux_VM_Managed_Image_With_Ansible](https://github.com/ElanShudnow/AzureCode/tree/main/Packer/linux_vm_managed_image_with_ansible) | Leverage a Packer Script executed on a Linux Server to deploy a Generalized Linux (Ubuntu) Managed Image for future VM deployments leveraging Terraform or manual procedures. Packer will configured the Managed Image to have Nginx installed as well as leverage the Ansible Provisioner to install Ansible Roles defined within the ansible directory. |