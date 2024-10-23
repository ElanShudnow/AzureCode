<#
.SYNOPSIS
    This PowerShell Script takes a list of Azure Subscriptions you have selected in Grid View and cycles through each subscription and obtains information about the Logical to Physical Zone Mapping.  Information is collected and outputted to an output.csv in the same folder the script was executed in.

.PARAMETER Region
    Specify the Region in which you would like to discover the logical to physical Availability Zone Mapping.

.EXAMPLE
    PS C:\> .\Get-AvailabilityZoneMapping -Region eastus

.NOTES
    AUTHOR: ELAN SHUDNOW - PRINCIPAL CLOUD SOLUTION ARCHITECT | Azure Infrastructure | Microsoft
    PERMISSIONS: Minimum Permissions Required are Reader

.LINK
    https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/AvailabilityZoneMapping
    Please note that while being developed by a Microsoft employee, Get-AvailabilityZoneMapping.ps1 is not a Microsoft service or product. Get-AvailabilityZoneMapping.ps1 is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.

    #>

[CmdletBinding()]
Param
(
  [Parameter(Mandatory = $true)]
  [string]
  $Region 
)

# Check Current Directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptFolder = Split-Path $scriptPath -Parent
$ExportFile = $scriptFolder + '\' + 'output.csv'

$SubscriptionIDs = (Get-AzSubscription | Out-GridView -Title 'Azure Subscription Selection' -PassThru).subscriptionId

$AvailabilityPeerReport = @()
foreach ($SubscriptionId in $SubscriptionIDs) {

  $SubscriptionName = (Get-AzSubscription -SubscriptionID $SubscriptionId).Name

  $AvailablityZoneMapping = Invoke-AzRestMethod -Path "/subscriptions/$SubscriptionId/locations?api-version=2022-12-01" -Method GET
  $AvailablityZoneMappingContent = $AvailablityZoneMapping.Content
  $AvailabilityZoneMappingContentObject = ($AvailablityZoneMappingContent | ConvertFrom-Json).Value
  $AvailabilityZoneMappingContentObjectRegionCheckRegion = ($AvailabilityZoneMappingContentObject | Where-Object {$_.Name -eq $Region})
  $AvailabilityZoneMappingContentObjectRegionCheckRegionZones = $AvailabilityZoneMappingContentObjectRegionCheckRegion.availabilityZoneMappings
  $AvailablityZoneMappingStatusCode = $AvailablityZoneMapping.StatusCode

  if (-not($AvailabilityZoneMappingContentObjectRegionCheckRegion))
  {
    Write-Host "The Region Specified, $Region, does not exist.  Please specify a Region that exists.  Use the following command to find a list of all Available Regions:" -ForegroundColor Red
    Write-Host "`nGet-AzLocation | FL Name" -ForegroundColor Red
    Write-Host "`nTerminating Script..." -ForegroundColor Red
    exit
  }
  if (-not($AvailabilityZoneMappingContentObjectRegionCheckRegionZones))
  {
    Write-Host "The Region Specified, $Region, does not support Availability Zones.  Please specify a Region that supports AvailabilityZones." -ForegroundColor Red
    Write-Host "`nPlease see the following link for what Regions support Availability Zones: https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support#azure-regions-with-availability-zone-support" -ForegroundColor Red
    Write-Host "`nTerminating Script..." -ForegroundColor Red
    exit
  }

  Write-Host "`nObtaining Availability Zone Logical to Physical Zone Mapping for $SubscriptionName in the $Region Region." -ForegroundColor Yellow
  if ($AvailablityZoneMappingStatusCode -eq 200) 
  {
    Write-Host "`n    - Success: Successful lookup for the $SubscriptionName Subscription." -ForegroundColor Green

    $AvailablityZoneMappingConvertedContent = ($AvailablityZoneMappingContent | ConvertFrom-Json).value
    $AvailablityZoneMappingConvertedContentRegionMatch = $AvailablityZoneMappingConvertedContent | Where-Object {$_.Name -eq $Region}
    $RegionName = $AvailablityZoneMappingConvertedContentRegionMatch.name
    $RegionalDisplayName = $AvailablityZoneMappingConvertedContentRegionMatch.RegionalDisplayName
    $availabilityZoneMappings = $AvailablityZoneMappingConvertedContentRegionMatch.availabilityZoneMappings
  
    foreach ($AvailablityZoneMapping in $availabilityZoneMappings)
    {
      $AvailabilityPeerObject = New-Object PSObject
      $AvailabilityPeerObject | Add-Member -type NoteProperty -name SubscriptionId -Value $SubscriptionId
      $AvailabilityPeerObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
      $AvailabilityPeerObject | Add-Member -type NoteProperty -name PhysicalZone -Value $AvailablityZoneMapping.physicalZone[-1]
      $AvailabilityPeerObject | Add-Member -type NoteProperty -name LogicalZone -Value $AvailablityZoneMapping.logicalZone
      $AvailabilityPeerObject | Add-Member -type NoteProperty -name Region -Value $RegionName
      $AvailabilityPeerObject | Add-Member -type NoteProperty -name RegionDisplayName -Value $RegionalDisplayName
      $AvailabilityPeerReport += $AvailabilityPeerObject
    }
  }
  else
  {
    Write-Host "`n    - ERROR: Unknown Error: $AvailablityZoneMappingContent.Error" -ForegroundColor Red
    $ErrorOccured = "yes"
  }
}

if ($AvailabilityPeerReport -ne $null)
{
  $AvailabilityPeerReport | Export-Csv -Path $ExportFile -NoTypeInformation
  Write-Host "`nOutput CSV generated at the following location: $ExportFile" -ForegroundColor Yellow
}
elseif ($ErrorOccured -eq "yes")
{
  Write-Host "`nNo Output CSV generated as no Subscriptions had a successful lookup." -ForegroundColor Yellow
}
else {
  Write-Host "`nNo Output CSV generated as the specified Region does not support Availability Zones." -ForegroundColor Yellow
}



