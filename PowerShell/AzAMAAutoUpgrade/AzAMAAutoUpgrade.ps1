<#
.SYNOPSIS
    This script will cycle through Virtual Machines that have the AMA agent installed and if that VM also has the AMA agent installed, that VM's AMA Extension will be configured for auto-upgrade.  
    The script allows you to target an individual Subscription or Subscriptions within a Management Group optionally allowing you to recurse through child Management Groups and their Subscriptions.

    # Check for exsiting AMA Versions here: https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-extension-versions

.PARAMETER ManagementGroupID
    Specify a specific ManagementGroupID to configure the AMA extension from all VMs that have the AMA extension installed from Subscriptions within this ManagementGroupID.

    Note: -ManagementGroupID cannot be run in conjuction with -SubscriptionID
    
.PARAMETER Recurse (Default: $false)
    Options:
        $true
        $false

    Obtain Subscriptions at the Management Group Scope using the ManagementGroupID specified and recurse through all Child Management Groups within and include their Subscriptions.

.PARAMETER SubscriptionID
    Specify a specific SubscriptionID to execute the script against. 

    Note: -SubscriptionID cannot be run in conjuction with -ManagementGroupID

.PARAMETER LoggingOnly (Default: $true) - Required
    Specify whether the script should conduct an assessment on the subscriptions specified whether by specifying an individual subscription or through Management Group Mode.  Logging Only Mode will output
    results to the PowerShell Screen as well as output a CSV with results. No AMA Changes will occur in LoggingOnly mode.  Additionally, when LoggingOnly mode is set to $false, an extra check will be performed 
    to ensure the user wants to proceed with AMA Configuration.

    Options:
        $true
        $false

.EXAMPLE
    PS C:\> .\AzAMAAutoUpgrade.ps1 -ManagementGroupID <ManagementGroupID> -LoggingOnly [$true|$false]

    PS C:\> .\AzAMAAutoUpgrade.ps1 -ManagementGroupID <ManagementGroupID> -Recurse $true -LoggingOnly [$true|$false]

    PS C:\> .\AzAMAAutoUpgrade.ps1 -SubscriptionID <SubscriptionID> -LoggingOnly [$true|$false]

.NOTES
    AUTHOR: ELAN SHUDNOW - PRINCIPAL CLOUD SOLUTION ARCHITECT | Azure Infrastructure | Microsoft
    PERMISSIONS: Minimum Permissions Required are Reader and Virtual Machine Contributor.

    Updates:
    2025-04-21 - Initial Release

.LINK
    https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/AZAMAAutoUpgrade
    Please note that while being developed by a Microsoft employee, AZAMAUpgrade is not a Microsoft service or product. AzAMAAutoUpgrade is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

[CmdletBinding()]
Param
(
    [parameter(mandatory = $true, ParameterSetName = 'ManagementGroup')]
    [string]$ManagementGroupID,

    [parameter(mandatory = $false, ParameterSetName = 'ManagementGroup')]
    [bool]$Recurse = $false,

    [parameter(mandatory = $true, ParameterSetName = 'Subscription')]
    [string]$SubscriptionID,  

    [parameter(mandatory = $true, ParameterSetName = 'ManagementGroup')]
    [parameter(mandatory = $true, ParameterSetName = 'Subscription')]
    [bool]$LoggingOnly = $true
)

# Unicode Characters
$cyanFG = 96
$redFG = 31

# Array Instantiation
$CustomAMAReport = @()

Write-Host "Script Mode:" -ForegroundColor Cyan
if ($ManagementGroupID) {
    if (-not($Recurse)) {
        Write-Host "    - Management Group Mode Enabled: $ManagementGroupID" -ForegroundColor Yellow
        Write-Host "    - Recursion is disabled." -ForegroundColor Yellow
    }
    else {
        Write-Host "    - Management Group Mode Enabled: $ManagementGroupID" -ForegroundColor Yellow
        Write-Host "    - Recursion is enabled." -ForegroundColor Yellow
    }
}
elseif ($SubscriptionID) {
    Write-Host "    - Subscription Mode Enabled: $SubscriptionID" -ForegroundColor Yellow

}

if (-not($LoggingOnly)) {
    Write-Host "    - `e[${redFG}mLogging Only is disabled.  Script will initiate AMA Auto-Upgrade Configuration Changes on VMs that have AMA installed.`e[0m" -ForegroundColor Yellow

    $title = 'Confirm'
    $question = 'Logging Only is disabled.  The Script will configure AMA extension.  Are you sure you want to continue?'
    $choices = '&Yes', '&No'

    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'Your choice is Yes.  The Script will configure AMA extension for auto-upgrade.'
        Write-Host " "
    }
    else {
        Write-Host 'Your choice is No. Terminating Script'
        exit
    }
}
else {
    Write-Host "    - Logging Only Enabled.  Script will NOT configure AMA extension.`n" -ForegroundColor Yellow
}

if ($ManagementGroupID) {
    #Get all Subscriptions under Management Group
    $Subscriptions = Get-AzManagementGroupSubscription -GroupID $ManagementGroupID -WarningAction SilentlyContinue

    $AzSubscriptions = @()

    Write-Host "Obtaining Subscriptions for all Management Groups within: $ManagementGroupID`n" -ForegroundColor Cyan

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


ForEach ($Subscription in $AzSubscriptions) {
    $SubscriptionIDArray = $Subscription.SubID.split("/")
    $SubscriptionIDArrayCount = [int]$SubscriptionIDArray.Count - 1
    $SubID = $SubscriptionIDArray[$SubscriptionIDArrayCount]

    $SubscriptionName = (Get-AzSubscription -SubscriptionID $SubID).Name

    $SubscriptionHeader = $SubscriptionName + " (" + $SubID + ")"
    Write-Host "Connecting to Azure Subscription: $SubscriptionHeader" -ForegroundColor Yellow
    try {
        Select-AzSubscription -SubscriptionID $SubID -ErrorAction Stop | Out-Null
        Write-Host "Successfully connected to Azure Subscription: $SubscriptionHeader" -ForegroundColor Green
    }
    catch {
        Write-Host "Error: Unsuccessful connection attempt to Azure Subscription: $SubscriptionHeader.  Moving to next Subscription" -ForegroundColor Red
        continue
    }
    Write-Host "`n    - Checking for existence of AMA on VMs" 
    $VMs = Get-AzVM | Get-AzVMExtension | Where-Object { $_.Name -eq "AzureMonitorWindowsAgent" -or $_.Name -eq "AzureMonitorLinuxAgent" } | Select-Object VMName, ResourceGroupName, ExtensionType, EnableAutomaticUpgrade -Unique
    if (-not($VMs)) {
        Write-Host "        - No VMs with AMA Extension found in Subscription: $SubscriptionHeader" -ForegroundColor Yellow
        Write-Host " "
        continue
    }

    foreach ($vm in $VMs) {
        if ($LoggingOnly) {
            $VMName = $VM.VMName
            $VMRG = $VM.ResourceGroupName
            $extensionType = $vm.ExtensionType
            $EnableAutomaticUpgrade = $VM.EnableAutomaticUpgrade

            if ($EnableAutomaticUpgrade -eq $true ) 
            {
                Write-Host "        - `e[${cyanFG}mVM:`e[0m $VMName | `e[${cyanFG}mAMA:`e[0m`u{2705} | `e[${cyanFG}mAuto-Upgrade:`e[0m`u{2705} | `e[${cyanFG}mStatus:`e[0m AMA already configured for auto-upgrade..."      

                $AMAPSObject = New-Object PSObject
                $AMAPSObject | Add-Member -type NoteProperty -name VMName -Value $VMName
                $AMAPSObject | Add-Member -type NoteProperty -name ResourceGroupName -Value $VMRG
                $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
                $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
                $AMAPSObject | Add-Member -type NoteProperty -name AMAInstalled -Value $true
                $AMAPSObject | Add-Member -type NoteProperty -name Type -Value $extensionType
                $AMAPSObject | Add-Member -type NoteProperty -name AutoUpgrade -Value 'True'               
                $CustomAMAReport += $AMAPSObject     
            }
            else 
            {
                Write-Host "        - `e[${cyanFG}mVM:`e[0m $VMName | `e[${cyanFG}mAMA:`e[0m`u{2705} | `e[${cyanFG}mAuto-Upgrade:`e[0m`u{2716}  | `e[${cyanFG}mStatus:`e[0m AMA will be configured for auto-upgrade..."        
                
                $AMAPSObject = New-Object PSObject
                $AMAPSObject | Add-Member -type NoteProperty -name VMName -Value $VMName
                $AMAPSObject | Add-Member -type NoteProperty -name ResourceGroupName -Value $VMRG
                $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
                $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
                $AMAPSObject | Add-Member -type NoteProperty -name AMAInstalled -Value $true
                $AMAPSObject | Add-Member -type NoteProperty -name Type -Value $extensionType
                $AMAPSObject | Add-Member -type NoteProperty -name AutoUpgrade -Value 'False'               
                $CustomAMAReport += $AMAPSObject     
            }
        }
        else 
        {
            $VMName = $VM.VMName
            $VMRG = $VM.ResourceGroupName
            $extensionType = $vm.ExtensionType
            $EnableAutomaticUpgrade = $VM.EnableAutomaticUpgrade
            
            if ($VM.EnableAutomaticUpgrade -eq $false)
            {
                try 
                {
                    Write-Host "        - `e[${cyanFG}mVM:`e[0m $VMName | `e[${cyanFG}mAMA:`e[0m`u{2705} | `e[${cyanFG}mAuto-Upgrade:`e[0m`u{2716}  | `e[${cyanFG}mStatus:`e[0m Initiating AMA Auto-Upgrade Configuration..."
                    $AMAAutoUpgrade = Set-AzVMExtension -ResourceGroupName $VMRG -VMName $vmName -Name $extensionType -ExtensionType $extensionType -Publisher 'Microsoft.Azure.Monitor' -EnableAutomaticUpgrade $true -ErrorAction Stop
                    $AMAAutoUpgradeEnablement = "Successful"
                    Write-Host "            - Successful AMA Auto-Upgrade Configuration from VM: $VMName" -ForegroundColor Green
    
                    $AMAPSObject = New-Object PSObject
                    $AMAPSObject | Add-Member -type NoteProperty -name VMName -Value $VMName
                    $AMAPSObject | Add-Member -type NoteProperty -name ResourceGroupName -Value $VMRG
                    $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
                    $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
                    $AMAPSObject | Add-Member -type NoteProperty -name AMAInstalled -Value $true
                    $AMAPSObject | Add-Member -type NoteProperty -name Type -Value $extensionType
                    $AMAPSObject | Add-Member -type NoteProperty -name AMAAutoConfigEnablement -Value $AMAAutoUpgradeEnablement
                    $AMAPSObject | Add-Member -type NoteProperty -name AMAAutoConfigEnablement_ErrorMessage -Value 'n/a'             
                    $CustomAMAReport += $AMAPSObject   
                }
                catch 
                {
                    $ErrorMessage = $_.Exception.Message
                    $AMAAutoConfigEnablement = "Unsuccessful"
                    Write-Host "            - AMA Auto-Upgrade Configuration from VM: $VMName.  Error Msg: $ErrorMessage" -ForegroundColor Red
    
                    $AMAPSObject = New-Object PSObject
                    $AMAPSObject | Add-Member -type NoteProperty -name VMName -Value $VMName
                    $AMAPSObject | Add-Member -type NoteProperty -name ResourceGroupName -Value $VMRG
                    $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
                    $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
                    $AMAPSObject | Add-Member -type NoteProperty -name AMAInstalled -Value $true
                    $AMAPSObject | Add-Member -type NoteProperty -name Type -Value $extensionType
                    $AMAPSObject | Add-Member -type NoteProperty -name AMAAutoConfigEnablement -Value $AMAAutoConfigEnablement
                    $AMAPSObject | Add-Member -type NoteProperty -name AMAAutoConfigEnablement_ErrorMessage -Value $ErrorMessage          
                    $CustomAMAReport += $AMAPSObject   
                }
            }
            else 
            {
                Write-Host "        - `e[${cyanFG}mVM:`e[0m $VMName | `e[${cyanFG}mAMA:`e[0m`u{2705} | `e[${cyanFG}mAuto-Upgrade:`e[0m`u{2705}  | `e[${cyanFG}mStatus:`e[0m Skipping AMA Auto-Upgrade Configuration..."            
            
                $AMAPSObject = New-Object PSObject
                $AMAPSObject | Add-Member -type NoteProperty -name VMName -Value $VMName
                $AMAPSObject | Add-Member -type NoteProperty -name ResourceGroupName -Value $VMRG
                $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
                $AMAPSObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
                $AMAPSObject | Add-Member -type NoteProperty -name AMAInstalled -Value $true
                $AMAPSObject | Add-Member -type NoteProperty -name Type -Value $extensionType
                $AMAPSObject | Add-Member -type NoteProperty -name AMAAutoConfigEnablement -Value 'n/a'
                $AMAPSObject | Add-Member -type NoteProperty -name AMAAutoConfigEnablement_ErrorMessage -Value 'n/a'          
                $CustomAMAReport += $AMAPSObject   
            }
        }
    } 
}

# Check Current Directory and create a timestamped CSV Output File
$AMAAutoUpgrade = "AMAAutoUpgrade.csv"
$scriptPath = $MyInvocation.MyCommand.Path
$scriptFolder = Split-Path $scriptPath -Parent
$TimeStamp = "{0:yyyyMMdd-HHmm}" -f (Get-Date)
$AMAAutoUpgradeFilePath = $scriptFolder + '\' +  $TimeStamp + '-' + $AMAAutoUpgrade
$CustomAMAReport | Export-CSV -Path $AMAAutoUpgradeFilePath -NoTypeInformation
Write-Host "AMA Auto Upgrade Reported Created @ $AMAAutoUpgradeFilePath" -ForegroundColor Yellow
Write-Host " "