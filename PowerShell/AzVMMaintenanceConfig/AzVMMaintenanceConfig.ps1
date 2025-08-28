<#
.SYNOPSIS
    This script creates assigns a Maintenance Configuration to all Virtual Machines, both Windows and Linux, in a given Subscription or a Management Group Scope in a recursive or non-recursive manner.  This script will also enable Customer Managed Schedules. 

.PARAMETER ManagementGroupID
    Specify a specific ManagementGroupID to get a list of all Virtual Machines from all Subscriptions within this ManagementGroupID
    
.PARAMETER Recurse (Default: $false)
    Options:
        $true
        $false

    Obtain a list of all Virtual Machines to target at the Management Group Scope using the ManagementGroupID specified and recurse through all Child Management Groups within.

.PARAMETER Mode (Default: Add)
    Options:
        Add
        Remove

    Add Option adds Virtual Machine Maintenance Configuration to all Virtual Machines in the specified Management Group or Subscription.
    Remove Option removes Virtual Machine Maintenance Configuration from all Virtual Machines in the specified Management Group or Subscription.

.PARAMETER MaintenanceConfigID
    Specify a the resource ID of the Maintenance Configuration resource

.EXAMPLE
    PS C:\> .\AzVMMaintenanceConfig.ps1 -ManagementGroupID <ManagementGroupID> -Mode Add -MaintenanceConfigID '/subscriptions/6eg8be2d-dj8d-4adb-a467-78250953235d/resourcegroups/mc/providers/Microsoft.Maintenance/maintenanceConfigurations/mc1'

    PS C:\> .\AzVMMaintenanceConfig.ps1 -ManagementGroupID <ManagementGroupID> -Mode Remove

    PS C:\> .\AzVMMaintenanceConfig.ps1 -ManagementGroupID <ManagementGroupID> -Recurse $true -Mode Add -MaintenanceConfigID '/subscriptions/6eg8be2d-dj8d-4adb-a467-78250953235d/resourcegroups/mc/providers/Microsoft.Maintenance/maintenanceConfigurations/mc1'

    PS C:\> .\AzVMMaintenanceConfig.ps1 -ManagementGroupID <ManagementGroupID> -Recurse $true -Mode Remove

    PS C:\> .\AzVMMaintenanceConfig.ps1 -SubscriptionID <SubscriptionID> -Mode Add -MaintenanceConfigID '/subscriptions/6eg8be2d-dj8d-4adb-a467-78250953235d/resourcegroups/mc/providers/Microsoft.Maintenance/maintenanceConfigurations/mc1'

.NOTES
    AUTHOR: ELAN SHUDNOW - PRINCIPAL SOLUTION ENGINEER | Microsoft
    PERMISSIONS: Minimum Permissions Required are Virtual Machine Contributor.

.LINK
    https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/AzVMMaintenanceConfig
    Please note that while being developed by a Microsoft employee, AzVMMaintenanceConfig is not a Microsoft service or product. AzVMMaintenanceConfig is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

[CmdletBinding()]
Param
(
    [parameter(mandatory = $false, ParameterSetName = 'Add')]
    [parameter(mandatory = $false, ParameterSetName = 'Remove')]
    [string]$ManagementGroupID,

    [parameter(mandatory = $false, ParameterSetName = 'Add')]
    [parameter(mandatory = $false, ParameterSetName = 'Remove')]
    [bool]$Recurse = $false,

    [parameter(mandatory = $false, ParameterSetName = 'Add')]
    [parameter(mandatory = $false, ParameterSetName = 'Remove')]
    [string]$SubscriptionID,  

    [parameter(mandatory = $true, ParameterSetName = 'Add')]
    [string]$Mode = "Add",

    [string]$MaintenanceConfigID
)

# Unicode Characters
$redFG = 31

Write-Host "`nStarting AzVMMaintenanceConfig Script in the following modes..." -ForegroundColor Cyan
if ($ManagementGroupID) {
    if (-not($Recurse)) {
        Write-Host "    - Management Group Mode Enabled: $ManagementGroupID" -ForegroundColor Yellow
        Write-Host "    - Recursion is disabled." -ForegroundColor Yellow
    }
    else {
        Write-Host "    - Management Group Mode Enabled: $ManagementGroupID" -ForegroundColor Yellow
        Write-Host "    - Recursion is enabled. Fetching all Subscriptions for all Management Groups within $ManagementGroupID Management Group. " -ForegroundColor Yellow
    }
}
elseif ($SubscriptionID) {
    Write-Host "    - Subscription Mode Enabled: $SubscriptionID" -ForegroundColor Yellow

}

if ($ManagementGroupID) {
    #Get all Subscriptions under Management Group
    try 
    {
        $Subscriptions = Get-AzManagementGroupSubscription -GroupID $ManagementGroupID -WarningAction SilentlyContinue -ErrorAction Stop
    }
    catch 
    {
        Write-Host "`nFailed to retrieve subscriptions for Management Group $ManagementGroupID. Terminating Script." -ForegroundColor Red
        exit
    }

    $AzSubscriptions = @()

    foreach ($Subscription in $Subscriptions) {
        $SubID = $Subscription.Id
        $AzSubscription = New-Object PSObject
        $AzSubscription | Add-Member -type NoteProperty -name SubID -Value $SubID
        $AzSubscription | Add-Member -type NoteProperty -name ManagementGroupID -Value $ManagementGroupID

        $AzSubscriptions += $AzSubscription
    }

    if ($Recurse) {
        $ManagementGroupChildIDs = @()
        $ManagementGroupChildren = (Get-AzManagementGroup -GroupId $ManagementGroupID -Expand -Recurse -WarningAction SilentlyContinue).Children | Where-Object { $_.Type -eq 'Microsoft.Management/managementGroups' }

        foreach ($ManagementGroupChild in $ManagementGroupChildren) {
            $ManagementGroupChildIDArray = $ManagementGroupChild.Id.split("/")
            $ManagementGroupChildIDArrayCount = [int]$ManagementGroupChildIDArray.Count - 1
            $ManagementGroupChildID = $ManagementGroupChildIDArray[$ManagementGroupChildIDArrayCount]

            $ChildManagementGroups = New-Object PSObject
            $ChildManagementGroups | Add-Member -type NoteProperty -name ManagementGroupIDRecursed -Value $ManagementGroupChildID
        
            $ManagementGroupChildIDs += $ChildManagementGroups
        }

        foreach ($ManagementGroupChildID in $ManagementGroupChildIDs) {
            $ManagementGroupIDRecursed = $ManagementGroupChildID.ManagementGroupIDRecursed

            $Subscriptions = Get-AzManagementGroupSubscription -GroupID $ManagementGroupIDRecursed -WarningAction SilentlyContinue

            foreach ($Subscription in $Subscriptions) {
                $SubID = $Subscription.Id
                $AzSubscription = New-Object PSObject
                $AzSubscription | Add-Member -type NoteProperty -name SubID -Value $SubID
                $AzSubscription | Add-Member -type NoteProperty -name ManagementGroupID -Value $ManagementGroupIDRecursed

                $AzSubscriptions += $AzSubscription
            }
        }
    }
}
elseif ($SubscriptionID) {
    $AzSubscriptions = @()

    $AzSubscription = New-Object PSObject
    $AzSubscription | Add-Member -type NoteProperty -name SubID -Value $SubscriptionID

    $AzSubscriptions += $AzSubscription
}

if ($Mode -eq "Add") {
    Write-Host "    - `e[${redFG}mMode is Add.  Script will configure VMs with the Maintenance Configuration.`e[0m" -ForegroundColor Cyan

    Write-Host "`nStage 1: Starting Maintenance Configuration Retrieval..." -ForegroundColor Cyan
    # Define the Subscription the maintenance configuration belongs to
    $MaintenanceConfigSub = $MaintenanceConfigID.split("/")[2]
    $MaintenanceConfigRG = $MaintenanceConfigID.split("/")[4]
    $MaintenanceConfigName = $MaintenanceConfigID.split("/")[8]
    try {
        Write-Host "Connecting to Azure Subscription for maintenance configuration..." -ForegroundColor Yellow
        Select-AZSubscription -SubscriptionID $MaintenanceConfigSub -ErrorAction Stop | Out-Null
        Write-Host "Successfully selected the subscription for maintenance configuration.`n" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Failed to select the subscription for maintenance configuration. Terminating Script." -ForegroundColor Red
        exit
    }

    # Define the maintenance configuration ID
    try {
        Write-Host "Retrieving the maintenance configuration." -ForegroundColor Yellow
        $MaintenanceConfig = Get-AZMaintenanceConfiguration -Name $MaintenanceConfigName -ResourceGroupName $MaintenanceConfigRG -ErrorAction Stop
        Write-Host "Successfully retrieved the maintenance configuration.`n" -ForegroundColor Green
    }
    catch {
        <#Do this if a terminating exception happens#>
        $ErrorMessage = $_.Exception.Message
        Write-Host "ERROR: Failed to retrieve the maintenance configuration. Termininating Script. Error Message: $ErrorMessage" -ForegroundColor Red
        exit
    }
}
elseif ($Mode -eq "Remove") {
    Write-Host "    - `e[${redFG}mMode is Remove.  Script will remove the Maintenance Configuration from VMs.`e[0m" -ForegroundColor Cyan
}

ForEach ($Subscription in $AzSubscriptions) {
    $SubscriptionIDArray = $Subscription.SubID.split("/")
    $SubscriptionIDArrayCount = [int]$SubscriptionIDArray.Count - 1
    $SubID = $SubscriptionIDArray[$SubscriptionIDArrayCount]

    $SubscriptionName = (Get-AzSubscription -SubscriptionID $SubID).Name

    $SubscriptionHeader = $SubscriptionName + " (" + $SubID + ")"
 

    if ($Mode -eq "Add") {
        Write-Host "`nStage 2: Starting VM Maintenance Configuration Assignment..." -ForegroundColor Cyan
        Write-Host "Connecting to Azure Subscription: $SubscriptionHeader" -ForegroundColor Yellow
        try {
            Select-AzSubscription -SubscriptionID $SubID -ErrorAction Stop | Out-Null
            Write-Host "Successfully connected to Azure Subscription: $SubscriptionHeader" -ForegroundColor Green
        }
        catch {
            Write-Host "Error: Unsuccessful connection attempt to Azure Subscription: $SubscriptionHeader.  Moving to next Subscription" -ForegroundColor Red
            continue
        }
    
        Write-Host "`nObtaining Running VMs in Subscription: $SubscriptionHeader..." -ForegroundColor Yellow
        try {
            $vms = Get-AZVM -Status | Where-Object { $_.PowerState -eq "VM running" } -ErrorAction Stop
            Write-Host "Successfully obtained $($vms.Count) Running VMs in Subscription: $SubscriptionHeader" -ForegroundColor Green
        }
        catch {
            Write-Host "ERROR: Failed to obtain running VMs in Subscription: $SubscriptionHeader. Error Message: $($_.Exception.Message)" -ForegroundColor Red
            continue
        }
        # Loop through each VM and assign the maintenance configuration
        foreach ($vm in $vms) {
            Write-Host "`nAssigning $($MaintenanceConfig.name) Maintenance Configuration on VM: $($vm.Name)..." -ForegroundColor Yellow
            # Enable Customer Managed Schedules for Windows or Linux VMs 
            # https://learn.microsoft.com/en-us/azure/update-manager/prerequsite-for-schedule-patching?tabs=new-prereq-powershell%2Cauto-portal#enable-scheduled-patching-on-azure-vms
            if ($vm.StorageProfile.OsDisk.OsType -eq "Windows") {
                Set-AzVMOperatingSystem -VM $vm -Windows -PatchMode "AutomaticByPlatform" | Out-Null
                $AutomaticByPlatformSettings = $vm.OSProfile.WindowsConfiguration.PatchSettings.AutomaticByPlatformSettings
        
                if ($null -eq $AutomaticByPlatformSettings) {
                    $vm.OSProfile.WindowsConfiguration.PatchSettings.AutomaticByPlatformSettings = New-Object -TypeName Microsoft.Azure.Management.Compute.Models.WindowsVMGuestPatchAutomaticByPlatformSettings -Property @{BypassPlatformSafetyChecksOnUserSchedule = $true }
                } 
                else {
                    $AutomaticByPlatformSettings.BypassPlatformSafetyChecksOnUserSchedule = $true
                }  
        
                try {
                    Update-AzVM -VM $vm -ResourceGroupName $vm.ResourceGroupName -ErrorAction Stop | Out-Null
                    Write-Host "Successfully enabled Customer Managed Schedule patching for VM: $($vm.Name)" -ForegroundColor Green
                }
                catch {
                    $ErrorMessage = $_.Exception.Message
                    Write-Host "ERROR: Failed to enable Customer Managed Schedule patching for VM: $($vm.Name) in Resource Group: $($vm.ResourceGroupName).  Error Message: $ErrorMessage" -ForegroundColor Red
                }
            }
            elseif ($vm.StorageProfile.OsDisk.OsType -eq "Linux") {
                Set-AzVMOperatingSystem -VM $vm -Linux -PatchMode "AutomaticByPlatform" | Out-Null
                $AutomaticByPlatformSettings = $vm.OSProfile.LinuxConfiguration.PatchSettings.AutomaticByPlatformSettings
        
                if ($null -eq $AutomaticByPlatformSettings) {
                    $vm.OSProfile.LinuxConfiguration.PatchSettings.AutomaticByPlatformSettings = New-Object -TypeName Microsoft.Azure.Management.Compute.Models.LinuxVMGuestPatchAutomaticByPlatformSettings -Property @{BypassPlatformSafetyChecksOnUserSchedule = $true }
                } 
                else {
                    $AutomaticByPlatformSettings.BypassPlatformSafetyChecksOnUserSchedule = $true
                }
        
                try {
                    Update-AzVM -VM $vm -ResourceGroupName $vm.ResourceGroup -ErrorAction Stop | Out-Null
                    Write-Host "Successfully enabled Customer Managed Schedule patching for VM: $($vm.Name)"
                }
                catch {
                    $ErrorMessage = $_.Exception.Message
                    Write-Host "ERROR: Failed to enable Customer Managed Schedule patching for VM: $($vm.Name) in Resource Group: $($vm.ResourceGroupName).  Error Message: $ErrorMessage" -ForegroundColor Red
                }
            }

            # Assign the maintenance configuration to the VM using PowerShell
            # https://docs.azure.cn/en-us/virtual-machines/maintenance-configurations-powershell
    
            try {       
                $ConfigAssignment = New-AzConfigurationAssignment `
                    -ResourceGroupName $vm.ResourceGroupName `
                    -Location $vm.Location `
                    -ResourceName $vm.name -ResourceType "VirtualMachines" `
                    -ProviderName "Microsoft.Compute" `
                    -ConfigurationAssignmentName $vm.name `
                    -MaintenanceConfigurationId $MaintenanceConfig.id `
                    -ErrorAction Stop
                Write-Host "Successfully assigned maintenance configuration to VM: $($vm.Name) in Resource Group: $($vm.ResourceGroupName)" -ForegroundColor Green
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host "ERROR: Failed to enable maintenance configuration to VM: $($vm.Name) in Resource Group: $($vm.ResourceGroupName).  Error Message: $ErrorMessage" -ForegroundColor Red
            }
        }
    }
    elseif ($Mode -eq "Remove") {

        Write-Host "`nStarting VM Maintenance Configuration Removal..." -ForegroundColor Cyan
        Write-Host "Connecting to Azure Subscription: $SubscriptionHeader" -ForegroundColor Yellow
        try {
            Select-AzSubscription -SubscriptionID $SubID -ErrorAction Stop | Out-Null
            Write-Host "Successfully connected to Azure Subscription: $SubscriptionHeader" -ForegroundColor Green
        }
        catch {
            Write-Host "Error: Unsuccessful connection attempt to Azure Subscription: $SubscriptionHeader.  Moving to next Subscription" -ForegroundColor Red
            continue
        }

        Write-Host "`nObtaining Running VMs in Subscription: $SubscriptionHeader..." -ForegroundColor Yellow
        try {
            $vms = Get-AZVM -Status | Where-Object { $_.PowerState -eq "VM running" } -ErrorAction Stop
            Write-Host "`nSuccessfully obtained $($vms.Count) Running VMs in Subscription: $SubscriptionHeader" -ForegroundColor Green
        }
        catch {
            Write-Host "ERROR: Failed to obtain running VMs in Subscription: $SubscriptionHeader. Error Message: $($_.Exception.Message)" -ForegroundColor Red
            continue
        }

        # Loop through each VM and assign the maintenance configuration
        foreach ($vm in $vms) {
            Write-Host "Beginning work on VM: $($vm.Name)..." -ForegroundColor Yellow
            $vmConfigurationAssignmentName = (Get-AzConfigurationAssignment -ResourceGroupName $vm.ResourceGroupName -ProviderName Microsoft.Compute -ResourceType virtualmachines -ResourceName $vm.Name).Name

            # Assign the maintenance configuration to the VM using PowerShell
            # https://docs.azure.cn/en-us/virtual-machines/maintenance-configurations-powershell
    
            try {       
                Remove-AzConfigurationAssignment `
                    -ResourceGroupName $vm.ResourceGroupName `
                    -ResourceName $vm.Name `
                    -ResourceType "VirtualMachines" `
                    -ProviderName "Microsoft.Compute" `
                    -ConfigurationAssignmentName $vmConfigurationAssignmentName `
                    -Force `
                    -ErrorAction Stop
                Write-Host "Successfully removed maintenance configuration for VM: $($vm.Name) in Resource Group: $($vm.ResourceGroupName)`n" -ForegroundColor Green
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host "ERROR: Failed to remove maintenance configuration for VM: $($vm.Name) in Resource Group: $($vm.ResourceGroupName)`n.  Error Message: $ErrorMessage" -ForegroundColor Red
            }
        }
    }
}