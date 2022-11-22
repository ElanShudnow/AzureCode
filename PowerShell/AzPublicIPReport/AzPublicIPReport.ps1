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

Function Set-CellColor
{ 
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position=0)]
        [string]$Property,
        [Parameter(Mandatory,Position=1)]
        [string]$Color,
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]$InputObject,
        [Parameter(Mandatory)]
        [string]$Filter,
        [switch]$Row
    )
    
    Begin {
        Write-Verbose "$(Get-Date): Function Set-CellColor begins"
        If ($Filter)
        {   If ($Filter.ToUpper().IndexOf($Property.ToUpper()) -ge 0)
            {   $Filter = $Filter.ToUpper().Replace($Property.ToUpper(),"`$Value")
                Try {
                    [scriptblock]$Filter = [scriptblock]::Create($Filter)
                }
                Catch {
                    Write-Warning "$(Get-Date): ""$Filter"" caused an error, stopping script!"
                    Write-Warning $Error[0]
                    Exit
                }
            }
            Else
            {   Write-Warning "Could not locate $Property in the Filter, which is required.  Filter: $Filter"
                Exit
            }
        }
    }
    
    Process {
        ForEach ($Line in $InputObject)
        {   If ($Line.IndexOf("<tr><th") -ge 0)
            {   Write-Verbose "$(Get-Date): Processing headers..."
                $Search = $Line | Select-String -Pattern '<th ?[a-z\-:;"=]*>(.*?)<\/th>' -AllMatches
                $Index = 0
                ForEach ($Match in $Search.Matches)
                {   If ($Match.Groups[1].Value -eq $Property)
                    {   Break
                    }
                    $Index ++
                }
                If ($Index -eq $Search.Matches.Count)
                {   Write-Warning "$(Get-Date): Unable to locate property: $Property in table header"
                    Exit
                }
                Write-Verbose "$(Get-Date): $Property column found at index: $Index"
            }
            If ($Line -match "<tr( style=""background-color:.+?"")?><td")
            {   $Search = $Line | Select-String -Pattern '<td ?[a-z\-:;"=]*>(.*?)<\/td>' -AllMatches
                $Value = $Search.Matches[$Index].Groups[1].Value -as [double]
                If (-not $Value)
                {   $Value = $Search.Matches[$Index].Groups[1].Value
                }
                If (Invoke-Command $Filter)
                {   If ($Row)
                    {   Write-Verbose "$(Get-Date): Criteria met!  Changing row to $Color..."
                        If ($Line -match "<tr style=""background-color:(.+?)"">")
                        {   $Line = $Line -replace "<tr style=""background-color:$($Matches[1])","<tr style=""background-color:$Color"
                        }
                        Else
                        {   $Line = $Line.Replace("<tr>","<tr style=""background-color:$Color"">")
                        }
                    }
                    Else
                    {   Write-Verbose "$(Get-Date): Criteria met!  Changing cell to $Color..."
                        $Line = $Line.Replace($Search.Matches[$Index].Value,"<td style=""background-color:$Color"">$Value</td>")
                    }
                }
            }
            Write-Output $Line
        }
    }
    
    End {
        Write-Verbose "$(Get-Date): Function Set-CellColor completed"
    }
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
        $IPConfiguration = $AZPublicIP.IpConfiguration.Id

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
            $PublicIPReport | Add-Member -type NoteProperty -name 'Assignment' -Value $(if ($IPConfiguration) {$IPConfiguration} else { 'Orphaned'})

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
            $PublicIPReport | Add-Member -type NoteProperty -name 'Assignment' -Value $(if ($IPConfiguration) {$IPConfiguration} else { 'Orphaned'})
    
            $CustomPublicIPReport += $PublicIPReport        
        }
        
    }

     $CustomPublicIPReportHTML = $CustomPublicIPReport | Convertto-HTML
     $CustomPublicIPReportHTML = $CustomPublicIPReportHTML | Set-CellColor Assignment red -Filter "Assignment -eq 'Orphaned'"

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