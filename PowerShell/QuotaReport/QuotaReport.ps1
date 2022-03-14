# Import JSON Settings
try
{
    # Check Current Directory
    $Invocation = (Get-Variable MyInvocation).Value
    $DirectoryPath = Split-Path $invocation.MyCommand.Path
    $ConfigSettingsPath = $Directorypath + '\Settings.json'

    # Pull Config File from Current Directory
    $Config = Get-Content -Path $ConfigSettingsPath -Raw -ErrorAction Stop
    $Config = $Config | ConvertFrom-Json
}
Catch
{
    Write-Error -Message "Settings.json file not found in directory.  Script will terminate."
    exit
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
Function Get-AZQuotaUsageHTML 
{
    [CmdletBinding()]

    Param(
		[Parameter(Mandatory=$True)]
		$Location
	)

$Body = @"
<h1>Quota Report</h1>
<h2>Region Location: $Location</h2>
"@

    # Get Azure VM Usage Quota information
    $VMRedThresholdPercentage = $Config.VMQuota.Threshold.Red
    $VMYellowThresholdPercentage = $Config.VMQuota.Threshold.Yellow
    $VMRedThreshold = $VMRedThresholdPercentage.replace('%','')
    $VMYellowThreshold = $VMYellowThresholdPercentage.replace('%','')
    $AZVMUsage = Get-AzVMUsage -Location $Location | Select-Object @{Name = 'Name';Expression = {"$($_.Name.LocalizedValue)"}},CurrentValue,Limit,@{Name = 'PercentUsed';Expression = {"{0:P2}" -f ($_.CurrentValue / $_.Limit)}}  | sort-object  { [INT]($_.percentused -replace '%')  } -descending                        

    $AZVMUsageHTML = $AZVMUsage | ConvertTo-Html | Set-CellColor percentused yellow -Filter "percentused -ge $VMYellowThreshold"
    $AZVMUsageHTML = $AZVMUsageHTML | Set-CellColor percentused red -Filter "percentused -ge $VMRedThreshold"
    $AZVMUsageHTML = $AZVMUsageHTML | Set-CellColor percentused green -Filter "percentused -lt $VMYellowThreshold"

    # Combine HTML elements for output
    $Body + $AZVMUsageHTML

}
Function Get-AZAvailableHostsPerSubnet
{
$Body = @"
<h1>Subnet Host Availability Report</h1>
"@
   
    #Get all VNETs
    $AZVNETs = Get-AzVirtualNetwork
    $CustomSubnetAvailReport = @()

    ForEach ($VNET in $AZVNETs) {

        #Get All Subnets in this VNET
        $AZSubnets = Get-AzVirtualNetwork -Name $VNET.Name | Get-AzVirtualNetworkSubnetConfig
        ForEach ($Subnet in $AZSubnets) {
            #Used for counting later
            $SubnetConfigured = $Subnet.IPConfigurations
            #Gets the mask from the IP configuration (I.e 10.0.0.0/24, turns to just "24")
            $AddressPrefix = $Subnet.AddressPrefix
            $Mask = $AddressPrefix.substring($AddressPrefix.Length - 2,2)
            
            #Depends on the mask, sets how many available IP's we have - Add more if required
            switch ($Mask) {
                '29' { $AvailableAddresses = "3" }
                '28' { $AvailableAddresses = "11" }
                '27' { $AvailableAddresses = "27" }
                '26' { $AvailableAddresses = "59" }
                '25' { $AvailableAddresses = "123" }
                '24' { $AvailableAddresses = "251" }
                '23' { $AvailableAddresses = "507" }
            }
            $AddressPrefixOutput = $Subnet.AddressPrefix
            $AddressPrefixOutputSubnet = $AddressPrefixOutput.split("/")[0]
            $AddressPrefixOutputCIDR = $AddressPrefixOutput.split("/")[1]

            $CombinedAddressSpace = $AddressPrefixOutputSubnet + "/" + $AddressPrefixOutputCIDR

            $IPsLeft = $AvailableAddresses - $SubnetConfigured.Count
            $PercentIPsUsed = "{0:P2}" -f ($SubnetConfigured.Count / $AvailableAddresses)
            
            $SubnetAvailReport = New-Object PSObject
            $SubnetAvailReport | Add-Member -type NoteProperty -name VNET -Value $vnet.name
            $SubnetAvailReport | Add-Member -type NoteProperty -name Name -Value $subnet.name
            $SubnetAvailReport | Add-Member -type NoteProperty -name AddressPrefix -Value $CombinedAddressSpace
            $SubnetAvailReport | Add-Member -type NoteProperty -name IPsConfigured -Value $subnetconfigured.count
            $SubnetAvailReport | Add-Member -type NoteProperty -name IPsLeft -Value $IPsLeft
            $SubnetAvailReport | Add-Member -type NoteProperty -name PercentUsed -Value $PercentIPsUsed
            $CustomSubnetAvailReport += $SubnetAvailReport
        }
    }

    $SubnetRedThresholdPercentage = $Config.Subnet.Threshold.Red
    $SubnetYellowThresholdPercentage = $Config.Subnet.Threshold.Yellow
    $SubnetRedThreshold = $SubnetRedThresholdPercentage.replace('%','')
    $SubnetYellowThreshold = $SubnetYellowThresholdPercentage.replace('%','')

    $CustomSubnetAvailReportFinal = $CustomSubnetAvailReport | sort-object { [INT]($_.percentused -replace '%')  } -descending
    $AZSubnetAvailabilityInfoHTML = $CustomSubnetAvailReportFinal | Convertto-HTML
    $AZSubnetAvailabilityInfoHTML = $AZSubnetAvailabilityInfoHTML | Set-CellColor PercentUsed yellow -Filter "PercentUsed -ge $SubnetYellowThreshold"
    $AZSubnetAvailabilityInfoHTML = $AZSubnetAvailabilityInfoHTML | Set-CellColor percentused red -Filter "percentused -ge $SubnetRedThreshold"
    $AZSubnetAvailabilityInfoHTML = $AZSubnetAvailabilityInfoHTML | Set-CellColor percentused green -Filter "percentused -lt $SubnetYellowThreshold"
    $Body + $AZSubnetAvailabilityInfoHTML
}


# Cycle through subscriptions defined in Settings.json and build report per subscription
$Subscriptions = $Config.Subscriptions
foreach ($Subscription in $Subscriptions)
{
    $SubscriptionName = (Get-AzSubscription -SubscriptionId $Subscription -WarningAction SilentlyContinue).name
    Select-AZSubscription -SubscriptionID $Subscription -WarningAction SilentlyContinue | Out-Null

    Write-Host "Collecting Data within the following Subscription: $Subscription" -ForegroundColor Green
    Write-Host " "

    # Pull quota report for each region defined in Settings.json
    $AllLocations = $Config.VMQuota.Regions
    $AZQuotaHTML = $null
    foreach ($Location in $AllLocations)
    {
        Write-Host "- Capturing Virtual Machine Quota Information for the $Location Region." -ForegroundColor Yellow
        Write-Host " "
        $AZQuotaHTML += Get-AZQuotaUsageHTML -Location $Location
    }

    $AZSubnetAvailabilityHTML = $null
    Write-Host "- Capturing VNet Subnet Availability Information. " -ForegroundColor Yellow
    Write-Host " "
    $AZSubnetAvailabilityHTML = Get-AZAvailableHostsPerSubnet # Pull report for Subnet availability

    # HTML Title
    $SubscriptionTitle = $SubscriptionName + " (" + $Subscription + ")"
    $Title = @"
<title>Azure Report</title>
<h1>Subscription: $SubscriptionTitle</h1>
<p>The following report was run on $(Get-Date)</p>
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

    # Combine HTML Reports
    $FinalHTML = $Title + $Header + $AZQuotaHTML + $AZSubnetAvailabilityHTML

    # Export HTML Report
    $MonthlyReportFileName = "\QuotaReport-" + "{0:yyyyMMdd-HHmm}" -f (Get-Date) + "-" + $Subscription + ".html"
    $MonthlyReportFilePath = $DirectoryPath + $MonthlyReportFileName
    $FinalHTML | Out-File -FilePath $MonthlyReportFilePath
    Write-Host "Monthly Reported Created @ $MonthlyReportFilePath" -ForegroundColor Yellow
    Write-Host " "
}