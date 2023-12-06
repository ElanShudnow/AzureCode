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

$filename = Get-SHDOpenFileDialog -Title "Select the CSV file" -InitialDirectory $scriptFolder -Filter "CSV Files (*.csv)| *.csv"

# Do not modify below this line
Write-Host "Beginning Script Run..." -ForegroundColor Green
Write-Host " "

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$FilePath = "https://raw.githubusercontent.com/tfitzmac/resource-capabilities/main/move-support-resources-with-regions.csv"
$localPath = $ScriptDir + "\move-support-resources-with-regions.csv"

Write-Host "   # Downloading move-support-resources-with-regions.csv from $filepath" -ForegroundColor Yellow
Write-Host " "
$wc = New-Object System.Net.Webclient
$wc.DownloadFile($FilePath, $localPath)


# Build a Table from move-support-resources-with-regions.csv.  This table will later be used to compare an existing Resource's ResourceType against the table to verify whether the resource is supported for Subscription Move.
$rgtable = @{}
Import-Csv $localPath | ForEach-Object {
  $rgtable[$_.Resource] = $_.'Move Resource Group'
}

$subtable = @{}
Import-Csv $localPath | ForEach-Object {
  $subtable[$_.Resource] = $_.'Move Subscription'
}

$regiontable = @{}
Import-Csv $localPath | ForEach-Object {
  $regiontable[$_.Resource] = $_.'Move Region'
}

Write-Host "   # Analyzing CSV Information" -ForegroundColor Yellow
$AzureResources = Import-Csv $filename

# Create Empty Array to insert the Resource Information Into
$report = @()

foreach ($AzureResource in $AzureResources)
{
  $InstanceID = $AzureResource.'ResourceID'

  $InstanceID = $InstanceID.substring(1).split("/").trim()
  $InstanceCount = $InstanceID.count

  for ($counter=0; $counter -lt $InstanceCount; $counter++)
  {
    $InstanceString = $InstanceID[$counter]
    if ($InstanceString -like ("Microsoft.*"))
    {
      $Value = $InstanceString
      $CurrentCounter = $counter
      break
    }
  }

  $FinalCounter = $CurrentCounter + 1
  $AzureResourceType = $Value + "/" + $InstanceID[$FinalCounter]
  $AzureResourcetypeString = $AzureResourceType.tostring()

  $SupportsMoveRG = $rgtable[$AzureResourcetypeString]
  $SupportsMoveSub = $subtable[$AzureResourcetypeString]
  $SupportsMoveRegion = $regiontable[$AzureResourcetypeString]
  
  $PSCustomObject = New-Object PSObject
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name BillingAccountId -Value $AzureResource.BillingAccountId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name BillingAccountName -Value $AzureResource.BillingAccountName
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name BillingPeriodStartDate -Value $AzureResource.BillingPeriodStartDate
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name BillingPeriodEndDate -Value $AzureResource.BillingPeriodEndDate
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name BillingProfileId -Value $AzureResource.BillingProfileId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name AccountOwnerId -Value $AzureResource.AccountOwnerId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name AccountName -Value $AzureResource.AccountName
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name SubscriptionId -Value $AzureResource.SubscriptionId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name SubscriptionName -Value $AzureResource.SubscriptionName
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name Date -Value $AzureResource.Date
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name Product -Value $AzureResource.Product
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name PartNumber -Value $AzureResource.PartNumber
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name MeterId -Value $AzureResource.MeterId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ServiceFamily -Value $AzureResource.ServiceFamily
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name MeterCategory -Value $AzureResource.MeterCategory
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name MeterSubcategory -Value $AzureResource.MeterSubcategory
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name MeterRegion -Value $AzureResource.MeterRegion
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name MeterName -Value $AzureResource.MeterName
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name Quantity -Value $AzureResource.Quantity
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name EffectivePrice -Value $AzureResource.EffectivePrice
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name Cost -Value $AzureResource.Cost
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name UnitPrice -Value $AzureResource.UnitPrice
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name BillingCurrency -Value $AzureResource.BillingCurrency
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ResourceLocation -Value $AzureResource.ResourceLocation
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name AvailabilityZone -Value $AzureResource.AvailabilityZone
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ConsumedService -Value $AzureResource.ConsumedService
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ResourceId -Value $AzureResource.ResourceId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ResourceName -Value $AzureResource.ResourceName
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ResourceType -Value $AzureResourceType
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name 'Supports Resource Group Move' -Value $SupportsMoveRG
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name 'Supports Subscription Move' -Value $SupportsMoveSub
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name 'Supports Region Move' -Value $SupportsMoveRegion
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ServiceInfo1 -Value $AzureResource.ServiceInfo1
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ServiceInfo2 -Value $AzureResource.ServiceInfo2
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name AdditionalInfo -Value $AzureResource.AdditionalInfo
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name Tags -Value $AzureResource.Tags
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name InvoiceSectionId -Value $AzureResource.InvoiceSectionId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name InvoiceSection -Value $AzureResource.InvoiceSection
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name CostCenter -Value $AzureResource.CostCenter
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name UnitOfMeasure -Value $AzureResource.UnitOfMeasure
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ResourceGroup -Value $AzureResource.ResourceGroup
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ReservationId -Value $AzureResource.ReservationId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ReservationName -Value $AzureResource.ReservationName
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ProductOrderId -Value $AzureResource.ProductOrderId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ProductOrderName -Value $AzureResource.ProductOrderName
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name OfferId -Value $AzureResource.OfferId
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name IsAzureCreditEligible -Value $AzureResource.IsAzureCreditEligible
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name Term -Value $AzureResource.Term
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name PublisherName -Value $AzureResource.PublisherName
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name PlanName -Value $AzureResource.PlanName
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name ChargeType -Value $AzureResource.ChargeType
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name Frequency -Value $AzureResource.Frequency
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name PublisherType -Value $AzureResource.PublisherType
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name PricingModel -Value $AzureResource.PricingModel
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name PayGPrice -Value $AzureResource.PayGPrice
  $PSCustomObject | Add-Member -MemberType NoteProperty -Name InvoiceID -Value $AzureResource.InvoiceID

  #Add the object to the report
  $report = $report += $PSCustomObject
  }


$OutputPath = $ScriptDir + "\ResourcesOutput" + ".csv"
$report | Export-CSV -Path $OutputPath -NoTypeInformation

Write-Host " "
Write-Host "Completing Script Run..." -ForegroundColor Green

Write-Host " "
Write-Host "Output Stored at: $OutputPath"
#>
