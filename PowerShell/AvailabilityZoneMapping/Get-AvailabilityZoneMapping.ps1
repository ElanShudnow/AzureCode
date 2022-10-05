<#
.SYNOPSIS
    This PowerShell Script takes a list of Azure Subscriptions you have selected in Grid View and cycles through each subscription and obtains information about the Logical to Physical Zone Mapping.  Information is collected and outputted to an output.csv in the same folder the script was executed in.

.PARAMETER Region
    Specify the Region in which you would like to discover the logical to physical Availability Zone Mapping.

.EXAMPLE
    PS C:\> .\Get-AvailabilityZoneMapping -Region eastus

.NOTES
    AUTHOR: ELAN SHUDNOW - SR CLOUD SOLUTION ARCHITECT | Azure Core | Microsoft
    PERMISSIONS: Minimum Permissions Required are Reader

.LINK
    https://github.com/ElanShudnow/AzureCode/tree/main/PowerShell/AvailabilityZoneMapping
    Please note that while being developed by a Microsoft employee, Get-AvailabilityZoneMapping.ps1 is not a Microsoft service or product. Get-AvailabilityZoneMapping.ps1 is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true)]
    [string]
    $Region 
)

# Check Current Directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptFolder = Split-Path $scriptPath -Parent
$ExportFile = $scriptFolder + '\' + 'output.csv'

$SubscriptionIDs = (Get-AzSubscription | Out-GridView -Title 'Azure Subscription Selection' -PassThru).subscriptionId

$AvailabilityPeerReport = @()
foreach ($SubscriptionId in $SubscriptionIDs)
{
  $Body = @{
    location = $Region
    subscriptionIds = @("subscriptions/$SubscriptionId)")
  }
  
  $json = $Body | ConvertTo-Json

  $SubscriptionName = (Get-AzSubscription -SubscriptionID $SubscriptionId).Name
  Write-Host "`nObtaining Availability Zone Logical to Physical Zone Mapping for $SubscriptionName in the $Region Region." -ForegroundColor Green
  
  $AvailablityZoneMapping = Invoke-AzRestMethod -Path "/subscriptions/$SubscriptionId/providers/Microsoft.Resources/checkZonePeers/?api-version=2020-01-01" -Method POST -Payload $json
  $AvailablityZoneMappingContent = $AvailablityZoneMapping.Content
  $AvailablityZoneMappingConvertedContent = $AvailablityZoneMappingContent | ConvertFrom-Json
  
  $AvailabilityZonePeers = $AvailablityZoneMappingConvertedContent.availabilityZonePeers

  foreach ($AvailabilityZonePeer in $AvailabilityZonePeers)
  {
    $AvailabilityPeerObject = New-Object PSObject
    $AvailabilityPeerObject | Add-Member -type NoteProperty -name SubscriptionId -Value $SubscriptionId
    $AvailabilityPeerObject | Add-Member -type NoteProperty -name SubscriptionName -Value $SubscriptionName
    $AvailabilityPeerObject | Add-Member -type NoteProperty -name PhysicalZone -Value $AvailabilityZonePeer.availabilityZone
    $AvailabilityPeerObject | Add-Member -type NoteProperty -name LogicalZone -Value $AvailabilityZonePeer.peers.availabilityZone
    $AvailabilityPeerObject | Add-Member -type NoteProperty -name Region -Value $Region
    $AvailabilityPeerReport += $AvailabilityPeerObject
  }
}

$AvailabilityPeerReport | Export-Csv -Path $ExportFile -NoTypeInformation
Write-Host "`nOutput CSV generated at the following location: $ExportFile" -ForegroundColor Yellow


