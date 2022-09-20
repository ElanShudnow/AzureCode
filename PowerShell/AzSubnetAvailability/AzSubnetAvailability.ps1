<#
.SYNOPSIS
    This script creates an HTML Report on Subnet Availability across a single or all subscriptions.  This will help in the decision making process if VNET sizes need to be increased and potentially additional subnets need to be created.

.PARAMETER SubscriptionID (Default: All)
    Options:
        All
        <SubscriptionID>

    Specify a specific SubscriptionID to get subnet availability information for all subnets within a specific subscription.  Or specify All to get all subnet availability information for all subnets across all subscriptions.
    
.PARAMETER SingleHTMLOutput (Default: $true)
    Options:
        $true
        $false

    All Subscriptions Subnet Availability Information should be combined into a single HTML file. Default is $true.  Specify $false to create individual HTML Output Files for each subscription.

.PARAMETER RedThreshold (Default: 80%)
    Above a certain percentage threshold of available subnet IP Addresses available/used, the cell will be marked red for easy visibility into subnets that are approaching the limit on amount of IP Addresses used.  Default is 80%. It is important to note if you specify this RedThreshold parameter, it should be a higher amount than YellowThreshold.

.PARAMETER YellowThreshold (Default: 50%)
    Above a certain percentage threshold of available subnet IP Addresses available/used, the cell will be marked yellow (until the red theshold is met) for easy visibility into subnets that are approaching the limit on amount of IP Addresses used.  Default is 50%.  Below this threshold, cells will be marked green. It is important to note if you specify this YellowThreshold parameter, it should be a lower amount than RedThreshold.

.PARAMETER SortColumn (Default: PercentUsed)
    Options:
        PercentUsed
        VNET

    Sort the columns by either PercentUsed or the name of the VNET.


.EXAMPLE
    PS C:\> .\AzSubnetAvailability.ps1 -SubscriptionID <SubscriptionID>

    PS C:\> .\AzSubnetAvailability.ps1 -SubscriptionID All

    PS C:\> .\AzSubnetAvailability.ps1 -SingleHTMLOutput $true

    PS C:\> .\AzSubnetAvailability.ps1 -SingleHTMLOutput $false

    PS C:\> .\AzSubnetAvailability.ps1 -RedThreshold 90% -YellowThreshold 75%

    PS C:\> .\AzSubnetAvailability.ps1 -SortColumn PercentUsed

    PS C:\> .\AzSubnetAvailability.ps1 -SortColumn VNET

.NOTES
    AUTHOR: ELAN SHUDNOW - SR CLOUD SOLUTION ARCHITECT | Azure Core | Microsoft
    PERMISSIONS: Minimum Permissions Required are Network Reader obtain VNET/Subnet data.

.LINK
    https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/AzSubnetAvailability
    Please note that while being developed by a Microsoft employee, AzSubnetAvailability is not a Microsoft service or product. AzSubnetAvailability is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

[CmdletBinding()]
Param
(
    [string]
    $SubscriptionID = 'All',

    [Parameter(Mandatory = $false,
    ParameterSetName = 'Thresholds')]
    [string]
    $RedThreshold = '80%',

    [Parameter(Mandatory = $false,
    ParameterSetName = 'Thresholds')]
    [string]
    $YellowThreshold = '50%',

    [bool]
    $SingleHTMLOutput = $true,

    [string]
    $SortColumn = 'PercentUsed'
    
)

# Check Current Directory
$Invocation = (Get-Variable MyInvocation).Value
$DirectoryPath = Split-Path $invocation.MyCommand.Path

# Create new root Directory
$FolderName = "AzSubnetAvailability"
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
Function Get-AZAvailableHostsPerSubnet
{
$Body = @"
<h2>Subnet Host Availability Report</h2>
"@
   
    #Get all VNETs
    $AZVNETs = Get-AzVirtualNetwork
    $CustomSubnetAvailReport = @()

    ForEach ($VNET in $AZVNETs) {
        $VNETName = $VNET.Name

        #Get All Subnets in this VNET
        $AZSubnets = Get-AzVirtualNetwork -Name $VNET.Name | Get-AzVirtualNetworkSubnetConfig

        ForEach ($Subnet in $AZSubnets) {
            #Used for counting later
            $SubnetConfigured = $Subnet.IPConfigurations
            $SubnetConfiguredCount = $SubnetConfigured.count

            # Gets the mask from the IP configuration (I.e 10.0.0.0/24, turns to just "24")
            $AddressPrefix = $Subnet.AddressPrefix
            $Mask = $AddressPrefix.substring($AddressPrefix.Length - 2,2)
            
            # Amount of available IP Addresses minus the 5 IPs that Azure consumes
            switch ($Mask) {
                '30' { $AvailableAddresses = [Math]::Pow(2,2) - 5 }
                '29' { $AvailableAddresses = [Math]::Pow(2,3) - 5 }
                '28' { $AvailableAddresses = [Math]::Pow(2,4) - 5 }
                '27' { $AvailableAddresses = [Math]::Pow(2,5) - 5 }
                '26' { $AvailableAddresses = [Math]::Pow(2,6) - 5 }
                '25' { $AvailableAddresses = [Math]::Pow(2,7) - 5 }
                '24' { $AvailableAddresses = [Math]::Pow(2,8) - 5 }
                '23' { $AvailableAddresses = [Math]::Pow(2,9) - 5 }
                '22' { $AvailableAddresses = [Math]::Pow(2,10) - 5 }
                '21' { $AvailableAddresses = [Math]::Pow(2,11) - 5 }
                '20' { $AvailableAddresses = [Math]::Pow(2,12) - 5 }
                '19' { $AvailableAddresses = [Math]::Pow(2,13) - 5 }
                '18' { $AvailableAddresses = [Math]::Pow(2,14) - 5 }
                '17' { $AvailableAddresses = [Math]::Pow(2,15) - 5 }
                '16' { $AvailableAddresses = [Math]::Pow(2,16) - 5 }
                '15' { $AvailableAddresses = [Math]::Pow(2,17) - 5 }
                '14' { $AvailableAddresses = [Math]::Pow(2,18) - 5 }
                '13' { $AvailableAddresses = [Math]::Pow(2,19) - 5 }
                '12' { $AvailableAddresses = [Math]::Pow(2,20) - 5 }
                '11' { $AvailableAddresses = [Math]::Pow(2,21) - 5 }
                '10' { $AvailableAddresses = [Math]::Pow(2,22) - 5 }
                '9' { $AvailableAddresses = [Math]::Pow(2,23) - 5 }
                '8' { $AvailableAddresses = [Math]::Pow(2,24) - 5 }
            }

            $AddressPrefixOutput = $Subnet.AddressPrefix
            $AddressPrefixOutputSubnet = $AddressPrefixOutput.split("/")[0]
            $AddressPrefixOutputCIDR = $AddressPrefixOutput.split("/")[1]

            $CombinedAddressSpace = $AddressPrefixOutputSubnet + "/" + $AddressPrefixOutputCIDR

            $IPsLeft = $AvailableAddresses - $SubnetConfiguredCount

            $PercentIPsUsed = "{0:P2}" -f ($SubnetConfiguredCount / $AvailableAddresses)
            
            $SubnetAvailReport = New-Object PSObject
            $SubnetAvailReport | Add-Member -type NoteProperty -name VNET -Value $vnet.name
            $SubnetAvailReport | Add-Member -type NoteProperty -name SubnetName -Value $subnet.name
            $SubnetAvailReport | Add-Member -type NoteProperty -name SubnetAddressPrefix -Value $CombinedAddressSpace
            $SubnetAvailReport | Add-Member -type NoteProperty -name IPsUsed -Value $subnetconfigured.count
            $SubnetAvailReport | Add-Member -type NoteProperty -name IPsRemaining -Value $IPsLeft
            $SubnetAvailReport | Add-Member -type NoteProperty -name PercentUsed -Value $PercentIPsUsed
            $CustomSubnetAvailReport += $SubnetAvailReport
        }
    }

    $SubnetRedThresholdPercentage = $RedThreshold
    $SubnetYellowThresholdPercentage = $YellowThreshold
    $SubnetRedThreshold = $SubnetRedThresholdPercentage.replace('%','')
    $SubnetYellowThreshold = $SubnetYellowThresholdPercentage.replace('%','')

    if ($SortColumn -eq 'PercentUsed')
    {
        $CustomSubnetAvailReportFinal = $CustomSubnetAvailReport | sort-object { [INT]($_.percentused -replace '%')  } -descending
    }
    elseif ($SortColumn -eq 'VNET')
    {
        $CustomSubnetAvailReportFinal = $CustomSubnetAvailReport | sort-object { [String]($_.VNET)  } -descending
    }
    $AZSubnetAvailabilityInfoHTML = $CustomSubnetAvailReportFinal | Convertto-HTML
    $AZSubnetAvailabilityInfoHTML = $AZSubnetAvailabilityInfoHTML | Set-CellColor PercentUsed yellow -Filter "PercentUsed -ge $SubnetYellowThreshold"
    $AZSubnetAvailabilityInfoHTML = $AZSubnetAvailabilityInfoHTML | Set-CellColor percentused red -Filter "percentused -ge $SubnetRedThreshold"
    $AZSubnetAvailabilityInfoHTML = $AZSubnetAvailabilityInfoHTML | Set-CellColor percentused green -Filter "percentused -lt $SubnetYellowThreshold"
    if (-not($VNETName)) 
    { 
        return $Body + '<b><p style="color:red">No VNETs detected in subscription.</p></b>'
    }
    else {
        return $Body + $AZSubnetAvailabilityInfoHTML
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

    Write-Host "- Capturing VNet Subnet Availability Information. " -ForegroundColor Yellow
    Write-Host " "
    $AZSubnetAvailabilityHTML = Get-AZAvailableHostsPerSubnet # Pull report for Subnet availability

    # HTML Title
    $SubscriptionTitle = $SubscriptionName + " (" + $Subscription + ")"
    $Title = @"
<title>Azure VNET Subnet Availability Report</title>
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
        $FinalHTML = $ReportDate + $Title + $Header + $AZSubnetAvailabilityHTML

        # Export HTML Report
        $SubnetAvailabilityReportFileName = "$Subscription.html"
        $SubnetAvailabilityReportFilePath = $OutputFolderPath + '\' + $SubnetAvailabilityReportFileName
        
        $FinalHTML | Out-File -FilePath $SubnetAvailabilityReportFilePath
        Write-Host "Subnet Availability Reported Created @ $SubnetAvailabilityReportFilePath" -ForegroundColor Green
        Write-Host " "
    }
    else {
      # Combine HTML Reports
      $InterimHTML += $Title + $Header + $AZSubnetAvailabilityHTML + '<br>'
      $FinalHTML = $ReportDate + $InterimHTML 
    }
}
if ($SingleHTMLOutput -eq $true)
{
    # Export HTML Report
    $SubnetAvailabilityReportFileName = "\SubnetAvailabilityReport-" + "{0:yyyyMMdd-HHmm}" -f (Get-Date) + ".html"
    $SubnetAvailabilityReportFilePath = $DirectoryPath + $SubnetAvailabilityReportFileName
    $FinalHTML | Out-File -FilePath $SubnetAvailabilityReportFilePath
    Write-Host "Subnet Availability Reported Created @ $SubnetAvailabilityReportFilePath" -ForegroundColor Green
    Write-Host " "
}