<#
.SYNOPSIS
    This script will cycle through Virtual Machines that have the MMA agent installed and if that VM also has the AMA agent installed, MMA will get removed.  
    The intention of this script is to provide an easy mechanism to decomission MMA once AMA has been rolled out to your fleet of VMs. 
    The script allows you to target an individual Subscription or Subscriptions within a Management Group optionally allowing you to recurse through child Management Groups and their Subscriptions.

.PARAMETER ManagementGroupID
    Specify a specific ManagementGroupID to remove the MMA extension from all VMs that have the AMA extension installed from Subscriptions within this ManagementGroupID.

    Note: -ManagementGroupID cannot be run in conjuction with -SubscriptionID
    
.PARAMETER Recurse (Default: $false)
    Options:
        $true
        $false

    Obtain Subscriptions at the Management Group Scope using the ManagementGroupID specified and recurse through all Child Management Groups within and include their Subscriptions.

.PARAMETER SubscriptionID
    Specify a specific SubscriptionID to remove the MMA extension from all VMs that have the AMA extension installed from the specified SubscriptionID.

    Note: -SubscriptionID cannot be run in conjuction with -ManagementGroupID

.PARAMETER LoggingOnly (Default: $true) - Required
    Specify whether the script should conduct an assessment on the subscriptions specified whether by specifying an individual subscription or through Management Group Mode.  Logging Only Mode will output
    results to the PowerShell Screen as well as output a CSV with results. No MMA Removal will occur in LoggingOnly mode.  Additionally, when LoggingOnly mode is set to $false, an extra check will be performed 
    to ensure the user wants to proceed with MMA Removal.

    Options:
        $true
        $false

.EXAMPLE
    PS C:\> .\AzMMARemoval.ps1 -ManagementGroupID <ManagementGroupID> -LoggingOnly [$true|$false]

    PS C:\> .\AzMMARemoval.ps1 -ManagementGroupID <ManagementGroupID> -Recurse $true -LoggingOnly [$true|$false]

    PS C:\> .\AzMMARemoval.ps1 -SubscriptionID <SubscriptionID> -LoggingOnly [$true|$false]

.NOTES
    AUTHOR: ELAN SHUDNOW - PRINCIPAL CLOUD SOLUTION ARCHITECT | Azure Infrastructure | Microsoft
    PERMISSIONS: Minimum Permissions Required are Reader and Virtual Machine Contributor.

.LINK
    https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/AzMMARemoval
    Please note that while being developed by a Microsoft employee, AzMMARemoval is not a Microsoft service or product. AzMMARemoval is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

 [CmdletBinding()]
Param
(
    [parameter(mandatory=$true, ParameterSetName = 'ManagementGroup')]
    [string]$ManagementGroupID,

    [parameter(mandatory=$false, ParameterSetName = 'ManagementGroup')]
    [bool]$Recurse = $false,

    [parameter(mandatory=$true, ParameterSetName = 'Subscription')]
    [string]$SubscriptionID,  

    [parameter(mandatory=$true, ParameterSetName = 'ManagementGroup')]
    [parameter(mandatory=$true, ParameterSetName = 'Subscription')]
    [bool]$LoggingOnly = $true
)

# Unicode Characters
$cyanFG = 96
$redFG = 31

$CustomMMARemovalReport = @()

Write-Host "Script Mode:" -ForegroundColor Cyan
if ($ManagementGroupID)
{
    if (-not($Recurse))
    {
        Write-Host "    - Management Group Mode Enabled: $ManagementGroupID" -ForegroundColor Yellow
        Write-Host "    - Recursion is disabled." -ForegroundColor Yellow
    }
    else 
    {
        Write-Host "    - Management Group Mode Enabled: $ManagementGroupID" -ForegroundColor Yellow
        Write-Host "    - Recursion is enabled." -ForegroundColor Yellow
    }
}
elseif ($SubscriptionID)
{
    Write-Host "    - Subscription Mode Enabled: $SubscriptionID" -ForegroundColor Yellow

}

if (-not($LoggingOnly))
{
    Write-Host "    - `e[${redFG}mLogging Only is disabled.  Script will initiate MMA Removal on VMs that have AMA installed.`e[0m" -ForegroundColor Yellow

    $title = 'Confirm'
    $question = 'Logging Only is disabled.  The Script will remove MMA extension on VMs that also have AMA.  Are you sure you want to continue?'
    $choices = '&Yes', '&No'

    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'Your choice is Yes.  The Script will remove MMA extension on VMs that also have AMA.'
        Write-Host " "
    }
    else {
        Write-Host 'Your choice is No. Terminating Script'
        exit
    }
}
else 
{
    Write-Host "    - Logging Only Enabled.  Script will NOT initiate MMA Removal on VMs that have AMA installed.`n" -ForegroundColor Yellow
}

if ($ManagementGroupID)
{
    #Get all Subscriptions under Management Group
    $Subscriptions = Get-AzManagementGroupSubscription -GroupID $ManagementGroupID -WarningAction SilentlyContinue

    $AzSubscriptions = @()

    Write-Host "Obtaining Subscriptions for all Management Groups within: $ManagementGroupID`n" -ForegroundColor Cyan

    foreach ($Subscription in $Subscriptions)
    {
        $SubID = $Subscription.Id
        $AzSubscription = New-Object PSObject
        $AzSubscription | Add-Member -type NoteProperty -name SubID -Value $SubID
        $AzSubscription | Add-Member -type NoteProperty -name ManagementGroupID -Value $ManagementGroupID

        $AzSubscriptions += $AzSubscription
    }

    if ($Recurse)
    {
        $ManagementGroupChildIDs = @()
        $ManagementGroupChildren = (Get-AzManagementGroup -GroupId $ManagementGroupID -Expand -Recurse -WarningAction SilentlyContinue).Children | Where-Object {$_.Type -eq 'Microsoft.Management/managementGroups'}

        foreach ($ManagementGroupChild in $ManagementGroupChildren)
        {
            $ManagementGroupChildIDArray = $ManagementGroupChild.Id.split("/")
            $ManagementGroupChildIDArrayCount = [int]$ManagementGroupChildIDArray.Count - 1
            $ManagementGroupChildID = $ManagementGroupChildIDArray[$ManagementGroupChildIDArrayCount]

            $ChildManagementGroups = New-Object PSObject
            $ChildManagementGroups | Add-Member -type NoteProperty -name ManagementGroupIDRecursed -Value $ManagementGroupChildID
        
            $ManagementGroupChildIDs += $ChildManagementGroups
        }

        foreach ($ManagementGroupChildID in $ManagementGroupChildIDs)
        {
            $ManagementGroupIDRecursed = $ManagementGroupChildID.ManagementGroupIDRecursed

            $Subscriptions = Get-AzManagementGroupSubscription -GroupID $ManagementGroupIDRecursed -WarningAction SilentlyContinue

            foreach ($Subscription in $Subscriptions)
            {
                $SubID = $Subscription.Id
                $AzSubscription = New-Object PSObject
                $AzSubscription | Add-Member -type NoteProperty -name SubID -Value $SubID
                $AzSubscription | Add-Member -type NoteProperty -name ManagementGroupID -Value $ManagementGroupIDRecursed

                $AzSubscriptions += $AzSubscription
            }
        }
    }
}
elseif ($SubscriptionID)
{
    $AzSubscriptions = @()

    $AzSubscription = New-Object PSObject
    $AzSubscription | Add-Member -type NoteProperty -name SubID -Value $SubscriptionID

    $AzSubscriptions += $AzSubscription
}

ForEach ($Subscription in $AzSubscriptions) 
{
    $SubscriptionIDArray = $Subscription.SubID.split("/")
    $SubscriptionIDArrayCount = [int]$SubscriptionIDArray.Count - 1
    $SubID = $SubscriptionIDArray[$SubscriptionIDArrayCount]

    $SubscriptionName = (Get-AzSubscription -SubscriptionID $SubID).Name

    $SubscriptionHeader = $SubscriptionName + " (" + $SubID + ")"
    Write-Host "Connecting to Azure Subscription: $SubscriptionHeader" -ForegroundColor Yellow
    try
    {
        Select-AzSubscription -SubscriptionID $SubID -ErrorAction Stop | Out-Null
        Write-Host "Successfully connected to Azure Subscription: $SubscriptionHeader" -ForegroundColor Green
    }
    catch
    {
        Write-Host "Error: Unsucessful connection attempt to Azure Subscription: $SubscriptionHeader.  Moving to next Subscription" -ForegroundColor Red
        continue
    }
    Write-Host "`n    - Checking for existence of AMA on VMs with MMA installed" 
    $VMs = Get-AzVM | Get-AzVMExtension | Where-Object {$_.Name -eq "MicrosoftMonitoringAgent"} | Select-Object VMName,ResourceGroupName -Unique
    if (-not($VMs))
    {
        Write-Host "        - No VMs with MMA Extension found in Subscription: $SubscriptionHeader" -ForegroundColor Yellow
        Write-Host " "
        continue
    }

    foreach ($VM in $VMs)
    {
        if ($LoggingOnly)
        {
            $VMName = $VM.VMName
            $VMRG = $VM.ResourceGroupName
            $CheckAMA = Get-AzVM -Name $VMName -ResourceGroupName $VMRG | Get-AzVMExtension | Where-Object {$_.Name -eq "AzureMonitorWindowsAgent" -or $_.Name -eq "AzureMonitorLinuxAgent"}
            if ($CheckAMA)
            {
                Write-Host "        - `e[${cyanFG}mVM:`e[0m $VMName | `e[${cyanFG}mMMA:`e[0m`u{2705} | `e[${cyanFG}mAMA:`e[0m`u{2705}  | `e[${cyanFG}mStatus:`e[0m MMA will be removed in Removal Mode..."

                $MMARemovalPSObject = New-Object PSObject
                $MMARemovalPSObject | Add-Member -type NoteProperty -name VMName -Value $VMName
                $MMARemovalPSObject | Add-Member -type NoteProperty -name ResourceGroupName -Value $VMRG
                $MMARemovalPSObject | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
                $MMARemovalPSObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
                $MMARemovalPSObject | Add-Member -type NoteProperty -name MMAInstalled -Value $true
                $MMARemovalPSObject | Add-Member -type NoteProperty -name AMAInstalled -Value $true
                $CustomMMARemovalReport += $MMARemovalPSObject
            }
            else
            {
                Write-Host "        - `e[${cyanFG}mVM:`e[0m $VMName | `e[${cyanFG}mMMA:`e[0m`u{2705} | `e[${cyanFG}mAMA:`e[0m`u{2716}  | `e[${cyanFG}mStatus:`e[0m MMA will NOT be removed in Removal Mode..."
                
                $MMARemovalPSObject = New-Object PSObject
                $MMARemovalPSObject | Add-Member -type NoteProperty -name VMName -Value $VMName
                $MMARemovalPSObject | Add-Member -type NoteProperty -name ResourceGroupName -Value $VMRG
                $MMARemovalPSObject | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
                $MMARemovalPSObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
                $MMARemovalPSObject | Add-Member -type NoteProperty -name MMAInstalled -Value $true
                $MMARemovalPSObject | Add-Member -type NoteProperty -name AMAInstalled -Value $false
                $CustomMMARemovalReport += $MMARemovalPSObject
            }  
        }
        else
        {
            $VMName = $VM.VMName
            $VMRG = $VM.ResourceGroupName
            $CheckAMA = Get-AzVM -Name $VMName -ResourceGroupName $VMRG | Get-AzVMExtension | Where-Object {$_.Name -eq "AzureMonitorWindowsAgent" -or $_.Name -eq "AzureMonitorLinuxAgent"}
            if ($CheckAMA)
            {
                Write-Host "        - `e[${cyanFG}mVM:`e[0m $VMName | `e[${cyanFG}mMMA:`e[0m`u{2705} | `e[${cyanFG}mAMA:`e[0m`u{2705} | `e[${cyanFG}mStatus:`e[0m Initiating removal of MMA Extension..."

                try
                {
                    $MMARemoval = Remove-AzVMExtension -ResourceGroupName $VMRG -VMName $VMName -Name MicrosoftMonitoringAgent -Force -ErrorAction Stop
                    $MMARemoval = "Successful"
                    Write-Host "            - Successful MMA Removal from VM: $VMName" -ForegroundColor Green
                }
                catch
                {
                    $MMARemoval = "Unsuccessful"
                    Write-Host "            - ERROR: Unsuccessful MMA Removal from VM $VMName" -ForegroundColor Red
                }

                $MMARemovalPSObject = New-Object PSObject
                $MMARemovalPSObject | Add-Member -type NoteProperty -name VMName -Value $VMName
                $MMARemovalPSObject | Add-Member -type NoteProperty -name ResourceGroupName -Value $VMRG
                $MMARemovalPSObject | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
                $MMARemovalPSObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
                $MMARemovalPSObject | Add-Member -type NoteProperty -name MMAInstalled -Value $true
                $MMARemovalPSObject | Add-Member -type NoteProperty -name AMAInstalled -Value $true
                $MMARemovalPSObject | Add-Member -type NoteProperty -name MMARemoval -Value $MMARemoval
                $CustomMMARemovalReport += $MMARemovalPSObject
            }
            else
            {
                Write-Host "        - `e[${cyanFG}mVM:`e[0m $VMName | `e[${cyanFG}mMMA:`e[0m`u{2705} | `e[${cyanFG}mAMA:`e[0m`u{2716}  | `e[${cyanFG}mStatus:`e[0m Skipping MMA Removal..."
                
                $MMARemovalPSObject = New-Object PSObject
                $MMARemovalPSObject | Add-Member -type NoteProperty -name VMName -Value $VMName
                $MMARemovalPSObject | Add-Member -type NoteProperty -name ResourceGroupName -Value $VMRG
                $MMARemovalPSObject | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
                $MMARemovalPSObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
                $MMARemovalPSObject | Add-Member -type NoteProperty -name MMAInstalled -Value $true
                $MMARemovalPSObject | Add-Member -type NoteProperty -name AMAInstalled -Value $false
                $MMARemovalPSObject | Add-Member -type NoteProperty -name MMARemoval -Value 'n/a'
                $CustomMMARemovalReport += $MMARemovalPSObject
            }            
        }
    }
    Write-Host " "
}

# Check Current Directory and create a timestamped CSV Output File
$MMARemoval = "MMARemoval.csv"
$scriptPath = $MyInvocation.MyCommand.Path
$scriptFolder = Split-Path $scriptPath -Parent
$TimeStamp = "{0:yyyyMMdd-HHmm}" -f (Get-Date)
$MMARemovalFilePath = $scriptFolder + '\' +  $TimeStamp + '-' + $MMARemoval
$CustomMMARemovalReport | Export-CSV -Path $MMARemovalFilePath -NoTypeInformation
Write-Host "MMA Removal Report Reported Created @ $MMARemovalFilePath" -ForegroundColor Yellow
Write-Host " "