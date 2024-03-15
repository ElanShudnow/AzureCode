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
| [AzResourceMoveSupport](https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/AzResourceMoveSupport) | This script will take an Azure Usage Report csv file and provide new columns as to whether each resource supports migration to another Resource Group, to another Subscription, or to another Region. |

## Terraform

| Script | Description |
| --------------- | --------------- |
| [Windows_VM_Marketplace](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/windows_vm_marketplace) | This Terraform Script executed on a Linux Server will deploy a single Windows Virtual Machine using a Marketplace Image. |
| [Linux_VM_Marketplace](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/linux_vm_marketplace) | This Terraform Script executed on a Linux Server will deploy a single Ubuntu Virtual Machine using a Marketplace Image. |
| [Windows_VM_ManagedImage](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/windows_vm_managedimage) | This Terraform Script executed on a Linux Server will deploy a single Windows Virtual Machine using a Managed Image. |
| [Linux_VM_ManagedImage](https://github.com/ElanShudnow/AzurePS/tree/main/Terraform/linux_vm_managedimage) | This Terraform Script executed on a Linux Server will deploy a single Linux Virtual Machine using a Managed Image. |

## Packer

| Script | Description |
| --------------- | --------------- |
| [Windows_VM_Managed_Image](https://github.com/ElanShudnow/AzurePS/tree/main/Packer/windows_vm_managed_image) | Leverage a Packer Script executed on a Linux Server to deploy a Generalized Windows Server 2022 Managed Image for future VM deployments leveraging Terraform or manual procedures. Packer will configured the Managed Image to have IIS installed. |
| [Linux_VM_Managed_Image](https://github.com/ElanShudnow/AzurePS/tree/main/Packer/linux_vm_managed_image) | Leverage a Packer Script executed on a Linux Server to deploy a Generalized Linux (Ubuntu) Managed Image for future VM deployments leveraging Terraform or manual procedures. Packer will configured the Managed Image to have IIS installed. |
| [Linux_VM_Managed_Image_With_Ansible](https://github.com/ElanShudnow/AzureCode/tree/main/Packer/linux_vm_managed_image_with_ansible) | Leverage a Packer Script executed on a Linux Server to deploy a Generalized Linux (Ubuntu) Managed Image for future VM deployments leveraging Terraform or manual procedures. Packer will configured the Managed Image to have Nginx installed as well as leverage the Ansible Provisioner to install Ansible Roles defined within the ansible directory. |

## Azure Monitor Workbooks
| Script | Description |
| --------------- | --------------- |
| [Azure Arc for Servers](https://github.com/ElanShudnow/AzureCode/tree/main/Workbooks/Azure%20Arc%20for%20Servers) | This Azure Arc for Servers Workbook provides much information around Azure Arc for Server Virtual Machines that includes Overview, Server Health, Extension Health, Security, and ESU information. This is an updated Workbook which is a continuation of the Workbook that was documented in a Tech Community Blog Post I wrote here: [Tech Community Post](https://techcommunity.microsoft.com/t5/azure-arc-blog/azure-arc-for-servers-monitoring-workbook/ba-p/3298791). |
| [Azure Virtual Machine Volumes](https://github.com/ElanShudnow/AzureCode/tree/main/Workbooks/Azure%20Virtual%20Machine%20Volumes) | This Azure Virtual Machine Volumes provides information around Azure Virtual Machine Volumes and/or Azure Arc for Server Virtual Machine Volumes.  This does require Virtual Machines and Arc-Enabled Servers to be connected to Log Analytics.  The Workbook allows you to select between Server Performance Counters or VMInsights, with VMInsights providing additional data that is not collectable using Performance Counters. |