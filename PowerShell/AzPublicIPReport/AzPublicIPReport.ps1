<#
.SYNOPSIS
    This script creates an HTML Report on what Public IP Addresses exist across a single or all subscriptions.  This will also include information on the recently announced Public IP DDOS Protection feature.

.PARAMETER SubscriptionID (Default: All)
    Options:
        All
        <SubscriptionID>

    Specify a specific SubscriptionID to get Public IP information  within a specific subscription.  Or specify All to get Public IP information across all subscriptions.
    
.PARAMETER SingleHTMLOutput (Default: $true)
    Options:
        $true
        $false

    All Subscription's Public IP information should be combined into a single HTML file. Default is $true.  Specify $false to create individual HTML Output Files for each subscription.


.EXAMPLE
    PS C:\> .\AzPublicIPReport.ps1 -SubscriptionID <SubscriptionID>

    PS C:\> .\AzPublicIPReport.ps1 -SubscriptionID All

    PS C:\> .\AzPublicIPReport.ps1 -SingleHTMLOutput $true

    PS C:\> .\AzPublicIPReport.ps1 -SingleHTMLOutput $false

.NOTES
    AUTHOR: ELAN SHUDNOW - SR CLOUD SOLUTION ARCHITECT | Azure Core | Microsoft
    PERMISSIONS: Minimum Permissions Required are Network Reader obtain VNET data.

.LINK
    https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/AzPublicIPReport
    Please note that while being developed by a Microsoft employee, AzPublicIPReport is not a Microsoft service or product. AzPublicIPReport is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
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
$FolderName = "AzPublicIPReport"
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

Function Get-AZPublicIPInformation
{
$Body = @"
<h2>DDOS Public IP Report</h2>
"@
   
    #Get all VNETs
    $AZPublicIPs = Get-AzPublicIPAddress
    $CustomPublicIPReport = @()

    ForEach ($AZPublicIP in $AZPublicIPs) 
    {
        $PublicIPName = $AZPublicIp.Name
        $PublicIPAddress = $AZPublicIp.IpAddress
        $PublicIPVersion = $AZPublicIP.PublicIpAddressVersion
        $PublicIPRG = $AZPublicIP.ResourceGroupName
        $PublicIPRegion = $AZPublicIP.Location
        $PublicIPSKU = $AZPublicIP.Sku.Name
        $PublicIPDDOSEnabled = $AZPublicIP.DdosSettings.ProtectionMode

        if ($PublicIPDDOSEnabled -eq 'Enabled')
        {   
            $PublicIPReport = New-Object PSObject
            $PublicIPReport | Add-Member -type NoteProperty -name Name -Value $PublicIPName
            $PublicIPReport | Add-Member -type NoteProperty -name 'IP Address' -Value $PublicIPAddress
            $PublicIPReport | Add-Member -type NoteProperty -name 'IP Version' -Value $PublicIPVersion
            $PublicIPReport | Add-Member -type NoteProperty -name 'Resource Group' -Value $PublicIPRG
            $PublicIPReport | Add-Member -type NoteProperty -name Region -Value $PublicIPRegion
            $PublicIPReport | Add-Member -type NoteProperty -name SKU -Value $PublicIPSKU
            $PublicIPReport | Add-Member -type NoteProperty -name 'DDOS Protection' -Value $PublicIPDDOSEnabled

            $CustomPublicIPReport += $PublicIPReport
        }
        else 
        {
            $PublicIPReport = New-Object PSObject
            $PublicIPReport | Add-Member -type NoteProperty -name Name -Value $PublicIPName
            $PublicIPReport | Add-Member -type NoteProperty -name 'IP Address' -Value $PublicIPAddress
            $PublicIPReport | Add-Member -type NoteProperty -name 'IP Version' -Value $PublicIPVersion
            $PublicIPReport | Add-Member -type NoteProperty -name 'Resource Group' -Value $PublicIPRG
            $PublicIPReport | Add-Member -type NoteProperty -name Region -Value $PublicIPRegion
            $PublicIPReport | Add-Member -type NoteProperty -name SKU -Value $PublicIPSKU
            $PublicIPReport | Add-Member -type NoteProperty -name 'DDOS Protection' -Value $null
    
            $CustomPublicIPReport += $PublicIPReport        
        }
        
    }

     $CustomPublicIPReportHTML = $CustomPublicIPReport | Convertto-HTML

    if (-not($PublicIPName)) 
    { 
        return $Body + '<b><p style="color:red">No Public IP Addresses detected in subscription.</p></b>'
    }
    else {
        return $Body + $CustomPublicIPReportHTML
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

    Write-Host "- Capturing Public IP Information. " -ForegroundColor Yellow
    Write-Host " "
    $AZPublicIPHTML = Get-AZPublicIPInformation # Pull report for Public IP information

    # HTML Title
    $SubscriptionTitle = $SubscriptionName + " (" + $Subscription + ")"
    $Title = @"
<title>Azure Public IP Report</title>
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
        $FinalHTML = $ReportDate + $Title + $Header + $AZPublicIPHTML

        # Export HTML Report
        $AZPublicIPReportFileName = "$Subscription.html"
        $AZPublicIPReportFilePath = $OutputFolderPath + '\' + $AZPublicIPReportFileName
        
        $FinalHTML | Out-File -FilePath $AZPublicIPReportFilePath
        Write-Host "Azure Public IP Reported Created @ $AZPublicIPReportFilePath" -ForegroundColor Green
        Write-Host " "
    }
    else {
      # Combine HTML Reports
      $InterimHTML += $Title + $Header + $AZPublicIPHTML + '<br>'
      $FinalHTML = $ReportDate + $InterimHTML 
    }
}
if ($SingleHTMLOutput -eq $true)
{
    # Export HTML Report
    $AZPublicIPReportHTMLFileName = "AzPublicIPReport.html"
    $AZPublicIPReportHTMLFilePath = $OutputFolderPath + '\' + $AZPublicIPReportHTMLFileName
    $FinalHTML | Out-File -FilePath $AZPublicIPReportHTMLFilePath
    Write-Host "Azure Public IP Reported Created @ $AZPublicIPReportHTMLFileName" -ForegroundColor Green
    Write-Host " "
}