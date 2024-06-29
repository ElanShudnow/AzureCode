<#
.SYNOPSIS
    This PowerShell Script takes a list of Virtual Machine SKUs from a CSV and Regions specified as an array in script and gets a list of what Virtual Machine SKUs are supported in the specified Regions as well as what Availability Zones these VM SKUs are available in. This script will provide output of the results in both the PowerShell Console as well as a CSV output in the same directory the script is executed from.

.EXAMPLE
    PS C:\> .\Get-VMRegionZonalAvailability

.NOTES
    AUTHOR: ELAN SHUDNOW - PRINCIPAL CLOUD SOLUTION ARCHITECT | Azure Infrastructure | Microsoft
    PERMISSIONS: Minimum Permissions Required are Reader

.LINK
    https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/VMRegionZonalAvailability
    Please note that while being developed by a Microsoft employee, Get-VMRegionZonalAvailability is not a Microsoft service or product. Get-VMRegionZonalAvailability is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

# Replace $Region Array with the following if you want to check all regions: $Regions = (Get-AzLocation).Location
$Regions = @(
    'NorthCentralUS',
    'SouthCentralUS'
)

# Do not modify below this line
function Get-SHDOpenFileDialog {
    [cmdletbinding()]
    param (
        [string]$InitialDirectory = "$Env:USERPROFILE",
        [string]$Title = "Please Select A file",
        [string]$Filter = "All files (*.*)| *.*",
        [switch]$MultiSelect
    )
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog 
    $FileBrowser.InitialDirectory = "$InitialDirectory"
    $FileBrowser.Filter = "$Filter"
    $FileBrowser.Title = "$Title"
    if ($MultiSelect) {
        $FileBrowser.Multiselect = $true
    }
    else {
        $FileBrowser.Multiselect = $false
    }
 
    $FileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true })) | Out-Null
    $FileBrowser.Filenames
    $FileBrowser.dispose()
}

$scriptPath = $MyInvocation.MyCommand.Path
$scriptFolder = Split-Path $scriptPath -Parent
$ExportFile = $scriptFolder + '\' + 'output.csv'

$filename = Get-SHDOpenFileDialog -Title "Select the CSV file" -InitialDirectory $scriptFolder -Filter "CSV Files (*.csv)| *.csv"
$VMSKUsCSV = Import-Csv $filename

$exportData = @()

$AzContext = Get-AzContext
$ExistingSubscriptionID = $AzContext.Subscription.ID
$ExistingSubscriptionName = $AzContext.Subscription.Name

Write-Host " "
Write-Host "Processing Script in the current subscription: $ExistingSubscriptionID ($ExistingSubscriptionName)" -ForegroundColor Yellow

Write-Host "`nAttempting to contact List Locations API for Logical to Physical Availability Zone Mapping..." -ForegroundColor Yellow
$AvailablityZoneMapping = Invoke-AzRestMethod -Path "/subscriptions/$ExistingSubscriptionID/locations?api-version=2022-12-01" -Method GET
$AvailablityZoneMappingContent = $AvailablityZoneMapping.Content
$AvailablityZoneMappingStatusCode = $AvailablityZoneMapping.StatusCode

if ($AvailablityZoneMappingStatusCode -eq 200) {
    Write-Host "Successful lookup. Will include Logical to Physical Availability Zone Mapping in data output." -ForegroundColor Green
    $AvailablityZoneMappingConvertedContent = ($AvailablityZoneMappingContent | ConvertFrom-Json).value
    $availabilityZoneMappings = $AvailablityZoneMappingConvertedContentRegionMatch.availabilityZoneMappings

    foreach ($Region in $Regions) 
    {
        Write-Host "`nChecking for VM SKU Availability in $Region"
        $AvailablityZoneMappingConvertedContentRegionMatch = $AvailablityZoneMappingConvertedContent | Where-Object { $_.Name -eq $Region }
        $availabilityZoneMappings = $AvailablityZoneMappingConvertedContentRegionMatch.availabilityZoneMappings
        $RegionalDisplayName = $AvailablityZoneMappingConvertedContentRegionMatch.RegionalDisplayName
        $RegionData = Get-AzComputeResourceSKU -Location $Region | Where-Object { $_.ResourceType -eq 'VirtualMachines' -and $_.Restrictions.ReasonCode -ne 'NotAvailableForSubscription' }
  
        foreach ($VMSku in $VMSKUsCSV) {
            if ($RegionData.Name -contains $VMSku.Name) {
                $LogicalZones = $($RegionData | Where-Object { $_.Name -eq $VMSKU.Name }).LocationInfo.Zones
                $SortedLogicalZones = $LogicalZones -join ","
                if ($LogicalZones -ne $null) {
                    foreach ($LogicalZone in $LogicalZones) {
                        $Zones = $null
                        $SortedZones = $null

                        $PhysicalZone = ($availabilityZoneMappings | Where-Object { $_.logicalZone -eq $LogicalZone }).physicalZone[-1]
                        $PhysicalZones += $PhysicalZone
                        $exportObj = New-Object PSObject
                        $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
                        $exportObj | Add-Member NoteProperty -name "RegionDisplayName" -Value $RegionalDisplayName
                        $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
                        $exportObj | Add-Member NoteProperty -Name "Available" -Value 'Yes'
                        $exportObj | Add-Member NoteProperty -Name "PhysicalZone" -Value $PhysicalZone
                        $exportObj | Add-Member NoteProperty -Name "LogicalZone" -Value $LogicalZone
                        $exportData = $exportData += $exportObj

                        $Zones = $null
                        $SortedZones = $null
                    }
                    $SortedPhysicalZones = $PhysicalZones -replace '.(?!$)', '$0,'
                    Write-Host "$($VMSku.Name) Available in $Region in the following Logical Zones: $SortedLogicalZones and Physical Zones: $SortedPhysicalZones" -ForegroundColor Green
                    $PhysicalZones = $null
                    $SortedPhysicalZones = $null
                }
                else {
                    $Zones = $null
                    $SortedZones = $null
                    Write-Host "$($VMSku.Name) Available in $Region with no Zonal support." -ForegroundColor Green
                    $exportObj = New-Object PSObject
                    $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
                    $exportObj | Add-Member NoteProperty -name "RegionDisplayName" -Value $RegionalDisplayName
                    $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
                    $exportObj | Add-Member NoteProperty -Name "Available" -Value 'Yes'
                    $exportObj | Add-Member NoteProperty -Name "PhysicalZone" -Value $PhysicalZone
                    $exportObj | Add-Member NoteProperty -Name "LogicalZone" -Value $LogicalZone
                    $exportData = $exportData += $exportObj
                    $Zones = $null
                    $SortedZones = $null
                }
                  
            }
            else {
                Write-Host "$($VMSku.Name) Not available in $Region" -ForegroundColor Red
                $exportObj = New-Object PSObject
                $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
                $exportObj | Add-Member NoteProperty -name "RegionDisplayName" -Value $RegionalDisplayName
                $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
                $exportObj | Add-Member NoteProperty -Name "Available" -Value 'No'
                $exportObj | Add-Member NoteProperty -Name "PhysicalZone" -Value ''
                $exportObj | Add-Member NoteProperty -Name "LogicalZone" -Value ''
                $exportData = $exportData += $exportObj
            }
         
        }
    }
}
else 
{
    Write-Host "Unsuccessful lookup. Will only include Logical Zone information in data output." -ForegroundColor Red  
    foreach ($Region in $Regions) 
    {
        Write-Host "`nChecking for VM SKU Availability in $Region"
        $RegionData = Get-AzComputeResourceSKU -Location $Region | Where-Object { $_.ResourceType -eq 'VirtualMachines' -and $_.Restrictions.ReasonCode -ne 'NotAvailableForSubscription' }
  
        foreach ($VMSku in $VMSKUsCSV) {
            if ($RegionData.Name -contains $VMSku.Name) {
                $LogicalZones = $($RegionData | Where-Object { $_.Name -eq $VMSKU.Name }).LocationInfo.Zones
                $SortedLogicalZones = $LogicalZones -join ","
                if ($LogicalZones -ne $null) {
                    foreach ($LogicalZone in $LogicalZones) {
                        $Zones = $null
                        $SortedZones = $null

                        $exportObj = New-Object PSObject
                        $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
                        $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
                        $exportObj | Add-Member NoteProperty -Name "Available" -Value 'Yes'
                        $exportObj | Add-Member NoteProperty -Name "LogicalZone" -Value $LogicalZone
                        $exportData = $exportData += $exportObj

                        $Zones = $null
                        $SortedZones = $null
                    }
                    $SortedPhysicalZones = $PhysicalZones -replace '.(?!$)', '$0,'
                    Write-Host "$($VMSku.Name) Available in $Region in the following Logical Zones: $SortedLogicalZones" -ForegroundColor Green
                    $PhysicalZones = $null
                    $SortedPhysicalZones = $null
                }
                else {
                    $Zones = $null
                    $SortedZones = $null
                    Write-Host "$($VMSku.Name) Available in $Region with no Zonal support." -ForegroundColor Green
                    $exportObj = New-Object PSObject
                    $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
                    $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
                    $exportObj | Add-Member NoteProperty -Name "Available" -Value 'Yes'
                    $exportObj | Add-Member NoteProperty -Name "LogicalZone" -Value $LogicalZone
                    $exportData = $exportData += $exportObj
                    $Zones = $null
                    $SortedZones = $null
                }
                  
            }
            else {
                Write-Host "$($VMSku.Name) Not available in $Region" -ForegroundColor Red
                $exportObj = New-Object PSObject
                $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
                $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
                $exportObj | Add-Member NoteProperty -Name "Available" -Value 'No'
                $exportObj | Add-Member NoteProperty -Name "LogicalZone" -Value ''
                $exportData = $exportData += $exportObj
            }
         
        }
    } <# Action when all if and elseif conditions are false #>
}

$exportData | Export-Csv -Path $ExportFile -NoTypeInformation
Write-Host "`nOutput CSV generated at the following location: $ExportFile" -ForegroundColor Yellow
