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
    } else {
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

foreach ($Region in $Regions)
{
    Write-Host "`nChecking for VM SKU Availability in $Region"
    $RegionData = Get-AzComputeResourceSKU -Location $Region | Where-Object {$_.ResourceType -eq 'VirtualMachines' -and $_.Restrictions.ReasonCode -ne 'NotAvailableForSubscription'}

    foreach ($VMSku in $VMSKUsCSV)
    {
        $exportObj = New-Object PSObject
        if ($RegionData.Name -contains $VMSku.Name)
        {
            Write-Host "$($VMSku.Name) Available in $Region" -ForegroundColor Green
            $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
            $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
            $exportObj | Add-Member NoteProperty -Name "Available" -Value 'Yes'
        }
        else 
        {
            Write-Host "$($VMSku.Name) Not available in $Region" -ForegroundColor Red
            $exportObj | Add-Member NoteProperty -Name "Region" -Value $Region
            $exportObj | Add-Member NoteProperty -Name "SKU" -Value $VMSku.Name
            $exportObj | Add-Member NoteProperty -Name "Available" -Value 'No'
        }
        $exportData = $exportData += $exportObj
    }
}
$exportData | Export-Csv -Path $ExportFile -NoTypeInformation
Write-Host "`nOutput CSV generated at the following location: $ExportFile" -ForegroundColor Yellow
