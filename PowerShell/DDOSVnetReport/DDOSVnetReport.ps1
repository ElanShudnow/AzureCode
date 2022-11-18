<#
.SYNOPSIS
    This script creates an HTML Report on what Virtual Networks have DDOS Standard enabled across a single or all subscriptions.  This will help in the decision making process if DDOS Standard is unintentionally missing on certain Virtual Networks.

.PARAMETER SubscriptionID (Default: All)
    Options:
        All
        <SubscriptionID>

    Specify a specific SubscriptionID to get DDOS Standard assignment information for all Virtual Networks for all Virtual Networks within a specific subscription.  Or specify All to get all DDOS Standard assignment information for all Virtual Networks across all subscriptions.
    
.PARAMETER SingleHTMLOutput (Default: $true)
    Options:
        $true
        $false

    All Subscriptions Virtual Network DDOS Standard assignment information should be combined into a single HTML file. Default is $true.  Specify $false to create individual HTML Output Files for each subscription.

.EXAMPLE
    PS C:\> .\DDOSVnetReport.ps1 -SubscriptionID <SubscriptionID>

    PS C:\> .\DDOSVnetReport.ps1 -SubscriptionID All

    PS C:\> .\DDOSVnetReport.ps1 -SingleHTMLOutput $true

    PS C:\> .\DDOSVnetReport.ps1 -SingleHTMLOutput $false

.NOTES
    AUTHOR: ELAN SHUDNOW - SR CLOUD SOLUTION ARCHITECT | Azure Core | Microsoft
    PERMISSIONS: Minimum Permissions Required are Network Reader obtain VNET data.

.LINK
    https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/DDOSVnetReport
    Please note that while being developed by a Microsoft employee, DDOSVnetReport is not a Microsoft service or product. DDOSVnetReport is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

[CmdletBinding()]
Param
(
    [string]
    $SubscriptionID = 'All',

    [bool]
    $SingleHTMLOutput = $true
)

# Check Current Directory
$Invocation = (Get-Variable MyInvocation).Value
$DirectoryPath = Split-Path $invocation.MyCommand.Path

# Create new root Directory
$FolderName = "DDOSVnetReport"
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

Function Get-AZDDOSPerVNET
{
$Body = @"
<h2>DDOS VNET Report</h2>
"@
   
    #Get all VNETs
    $AZVNETs = Get-AzVirtualNetwork
    $CustomDDOSReport = @()

    ForEach ($VNET in $AZVNETs) 
    {
        $VNETName = $VNET.Name
        $EnableDdosProtection = $VNET.EnableDdosProtection
        if ($EnableDdosProtection -eq $true)
        {
            $DDOSPlanStatus = 'Enabled'
            $DDOSProtectionPlan = $VNET.DdosProtectionPlan.Id

            $DDOSVNETObj = New-Object PSObject
            $DDOSVNETObj | Add-Member -type NoteProperty -name VNET -Value $VNETName
            $DDOSVNETObj | Add-Member -type NoteProperty -name 'DDOS Standard' -Value $DDOSPlanStatus
            $DDOSVNETObj | Add-Member -type NoteProperty -name 'DDOS Plan (ResourceID)' -Value $DDOSProtectionPlan
    
            $CustomDDOSReport += $DDOSVNETObj
        }
        else 
        {
            $DDOSVNETObj = New-Object PSObject
            $DDOSVNETObj | Add-Member -type NoteProperty -name VNET -Value $VNETName
            $DDOSVNETObj | Add-Member -type NoteProperty -name 'DDOS Standard' -Value $null
            $DDOSVNETObj | Add-Member -type NoteProperty -name 'DDOS Plan (ResourceID)' -Value $null
    
            $CustomDDOSReport += $DDOSVNETObj        
        }
        
    }

     $CustomDDOSReportHTML = $CustomDDOSReport | Convertto-HTML

    if (-not($VNETName)) 
    { 
        return $Body + '<b><p style="color:red">No VNETs detected in subscription.</p></b>'
    }
    else {
        return $Body + $CustomDDOSReportHTML
    }
}



if ($SubscriptionID -eq "All")
{
    $Subscriptions = Get-AzSubscription
}
else {
    $Subscriptions = Get-AzSubscription -SubscriptionId $SubscriptionID
}

# Cycle through subscriptions defined in Settings.json and build report per subscription
foreach ($Subscription in $Subscriptions)
{
    $SubscriptionName = (Get-AzSubscription -SubscriptionId $Subscription.SubscriptionID -WarningAction SilentlyContinue).name
    Select-AZSubscription -SubscriptionID $Subscription -WarningAction SilentlyContinue | Out-Null

    Write-Host "Collecting Data within the following Subscription: $($Subscription.Name)" -ForegroundColor Green
    Write-Host " "

    Write-Host "- Capturing VNet DDOS Information. " -ForegroundColor Yellow
    Write-Host " "
    $AZVNETDDOSHTML = Get-AZDDOSPerVNET # Pull report for VNET DDOS assignment

    # HTML Title
    $SubscriptionTitle = $SubscriptionName + " (" + $Subscription + ")"
    $Title = @"
<title>Azure VNET DDOS Assignment Report</title>
<h1>Subscription: $SubscriptionTitle</h1>
"@

    $ReportDate = @"
The following report was run on:<br>
Date/Time: $(Get-Date)<br>
Timezone: $((Get-TimeZone).DisplayName)
"@

    # HTML Header
    $Header = @"
<style>
BODY {font-family:verdana;}
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; padding: 5px; background-color: #d1c3cd;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black; padding: 5px}
</style>
"@

    #    # Individual HTML Outputs per Subscription

    if ($SingleHTMLOutput -ne $true)
    # Individual HTML Outputs per Subscription
    {
        # Combine HTML Reports
        $FinalHTML = $ReportDate + $Title + $Header + $AZVNETDDOSHTML

        # Export HTML Report
        $VnetDDOSReportFileName = "$Subscription.html"
        $VnetDDOSReportFilePath = $OutputFolderPath + '\' + $VnetDDOSReportFileName
        
        $FinalHTML | Out-File -FilePath $VnetDDOSReportFilePath
        Write-Host "Vnet DDOS Reported Created @ $VnetDDOSReportFilePath" -ForegroundColor Green
        Write-Host " "
    }
    else {
      # Combine HTML Reports
      $InterimHTML += $Title + $Header + $AZVNETDDOSHTML + '<br>'
      $FinalHTML = $ReportDate + $InterimHTML 
    }
}
if ($SingleHTMLOutput -eq $true)
{
    # Export HTML Report
    $VnetDDOSReportFileName = "DDOSVnetReport.html"
    $VnetDDOSReportFilePath = $OutputFolderPath + '\' + $VnetDDOSReportFileName
    $FinalHTML | Out-File -FilePath $VnetDDOSReportFilePath
    Write-Host "Vnet DDOS Reported Created @ $VnetDDOSReportFilePath" -ForegroundColor Green
    Write-Host " "
}