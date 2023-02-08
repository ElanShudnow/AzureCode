<#
.SYNOPSIS
    This script creates a report for Azure Advisor Cost Recommendations at the Management Group Scope in a recursive or non-recursive manner.

.PARAMETER ManagementGroupID
    Specify a specific ManagementGroupID to get Azure Cost Recommendations for all Subscriptions within this ManagementGroupID
    
.PARAMETER Recurse (Default: $false)
    Options:
        $true
        $false

    Obtain Azure Advisor Cost Recommendations at the Management Group Scope using the ManagementGroupID specified and recurse through all Child Management Groups within.


.EXAMPLE
    PS C:\> .\AzCostAvdisorMGScope.ps1 ManagementGroupID <ManagementGroupID>

    PS C:\> .\AzCostAvdisorMGScope.ps1 ManagementGroupID <ManagementGroupID> -Recurse $true

.NOTES
    AUTHOR: ELAN SHUDNOW - SR CLOUD SOLUTION ARCHITECT | Azure Core | Microsoft
    PERMISSIONS: Minimum Permissions Required are Network Reader obtain VNET data.

.LINK
    https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/AzCostAdvisorMGScope
    Please note that while being developed by a Microsoft employee, AzCostAdvisorMGScope is not a Microsoft service or product. AzCostAdvisorMGScope is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

[CmdletBinding()]
Param
(
    [parameter(mandatory=$true )]
    [string]
    $ManagementGroupID,

    [parameter(mandatory=$false )]
    [bool]
    $Recurse = $false
)

# Check Current Directory
$Invocation = (Get-Variable MyInvocation).Value
$DirectoryPath = Split-Path $invocation.MyCommand.Path

# Create new root Directory
$FolderName = "AzCostAdvisorMGScope"
$FolderPath = $DirectoryPath + '\' + $FolderName
If(!(test-path -PathType container $FolderPath))
{
      New-Item -ItemType Directory -Path $FolderPath | Out-Null
}

# Create new timestamped Directory for outputs
$OutputFolderName = "{0:yyyyMMdd-HHmm}" -f (Get-Date)
$OutputFolderPath = $FolderPath + '\' + $OutputFolderName
If(!(test-path -PathType container $OutputFolderPath))
{
    New-Item -ItemType Directory -Path $OutputFolderPath | Out-Null
}

$CustomAzAdvisorReport = @()

#Get all Subscriptions under Management Group
$Subscriptions = Get-AzManagementGroupSubscription -GroupID $ManagementGroupID -WarningAction SilentlyContinue

$AzSubscriptions = @()
if (-not($Recurse))
{
    Write-Host "Recursion is disabled.  Obtaining Subscriptions for Management Group: $ManagementGroupID`n" -ForegroundColor Yellow
}
else 
{
    Write-Host "Recursion is enabled.  Obtaining Subscriptions for all Management Groups within: $ManagementGroupID`n" -ForegroundColor Yellow
}
foreach ($Subscription in $Subscriptions)
{
    $SubscriptionID = $Subscription.Id
    $AzSubscription = New-Object PSObject
    $AzSubscription | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
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
            $SubscriptionID = $Subscription.Id
            $AzSubscription = New-Object PSObject
            $AzSubscription | Add-Member -type NoteProperty -name SubscriptionID -Value $SubscriptionID
            $AzSubscription | Add-Member -type NoteProperty -name ManagementGroupID -Value $ManagementGroupIDRecursed


            $AzSubscriptions += $AzSubscription
        }
    }
}

ForEach ($Subscription in $AzSubscriptions) 
{
    $SubscriptionIDArray = $Subscription.SubscriptionId.split("/")
    $SubscriptionIDArrayCount = [int]$SubscriptionIDArray.Count - 1
    $SubscriptionID = $SubscriptionIDArray[$SubscriptionIDArrayCount]

    $SubscriptionName = (Get-AzSubscription -SubscriptionID $SubscriptionID).Name
    $ManagementGroupIDVar = $Subscription.ManagementGroupID

    $SubscriptionHeader = $SubscriptionName + " (" + $SubscriptionID + ")"

    Write-Host "  - Obtaining Azure Advisor Cost Information for Subscription: $SubscriptionHeader`n" -ForegroundColor Green

    $AzAdvisorRecommendations = Get-AzAdvisorRecommendation -filter "Category eq 'Cost'" -SubscriptionId $SubscriptionID -WarningAction SilentlyContinue

    foreach ($AzAdvisorRecommendation in $AzAdvisorRecommendations)
    {
        $AzAdvisorCategory = $AzAdvisorRecommendation.Category
        $AzAdvisorSubscriptionID = $SubscriptionID
        $AzAdvisorImpactedField = $AzAdvisorRecommendation.ImpactedField
        $AzAdvisorImpactedValue = $AzAdvisorRecommendation.ImpactedValue
        $AzAdvisorSeverity = $AzAdvisorRecommendation.Impact
        $AzAdvisorRG = $AzAdvisorRecommendation.ResourceGroupName
        $AzAdvisorLastUpdated= $AzAdvisorRecommendation.LastUpdated
        $AzAdvisorShortDescriptionProblem = $AzAdvisorRecommendation.ShortDescriptionProblem
        $AzAdvisorShortDescriptionSolution = $AzAdvisorRecommendation.ShortDescriptionSolution


        $AZAdvisorReport = New-Object PSObject
        $AZAdvisorReport | Add-Member -type NoteProperty -name Category -Value $AzAdvisorCategory
        $AZAdvisorReport | Add-Member -type NoteProperty -name SubscriptionID -Value $AzAdvisorSubscriptionID
        $AZAdvisorReport | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
        $AZAdvisorReport | Add-Member -type NoteProperty -name ManagementGroupID -Value $ManagementGroupIDVar
        $AZAdvisorReport | Add-Member -type NoteProperty -name Resourcetype -Value $AzAdvisorImpactedField
        $AZAdvisorReport | Add-Member -type NoteProperty -name Resource -Value $AzAdvisorImpactedValue
        $AZAdvisorReport | Add-Member -type NoteProperty -name ResourceGroup -Value $AzAdvisorRG
        $AZAdvisorReport | Add-Member -type NoteProperty -name Severity -Value $AzAdvisorSeverity
        $AZAdvisorReport | Add-Member -type NoteProperty -name LastUpdated -Value $AzAdvisorLastUpdated
        $AZAdvisorReport | Add-Member -type NoteProperty -name Description -Value $AzAdvisorShortDescriptionProblem

        $CustomAzAdvisorReport += $AZAdvisorReport
    }
}

# Export CSV Report
$AZAdvisorReportFileName = "AzCostAdvisor.csv"
$AZAdvisorReportFilePath = $OutputFolderPath + '\' + $AZAdvisorReportFileName
$CustomAzAdvisorReport | Export-CSV -Path $AZAdvisorReportFilePath -NoTypeInformation
Write-Host "Azure Advisor Report Reported Created @ $AZAdvisorReportFilePath" -ForegroundColor Yellow
Write-Host " "