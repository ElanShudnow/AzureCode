<#
.SYNOPSIS
    This script checks all VNETs across a single or all subscriptions for any VNETs that have an overlapping address space.  This includes VNETs that have multiple network prefixes.

.PARAMETER SubscriptionID (Default: All)
    Options:
        All
        <SubscriptionID>

    Specify a specific SubscriptionID to get check VNETs that have overlapping address spaces within a specific subscription.  Or specify All to check for VNETs with overlapping address spaces across all subscriptions.
    
.EXAMPLE
    PS C:\> .\AzVNETOverlap.ps1 -SubscriptionID <SubscriptionID>

    PS C:\> .\AzVNETOverlap.ps1 -SubscriptionID All

.NOTES
    AUTHOR: ELAN SHUDNOW - SR CLOUD SOLUTION ARCHITECT | Azure Core | Microsoft
    PERMISSIONS: Minimum Permissions Required are Network Reader obtain VNET data.

.LINK
    https://github.com/ElanShudnow/AzurePS/tree/main/PowerShell/AzVNETOverlap
    Please note that while being developed by a Microsoft employee, AzVNETOverlap is not a Microsoft service or product. AzVNETOverlap is a personal/community driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

[CmdletBinding()]
Param
(
    [string]
    $SubscriptionID = 'All'
)

if ($SubscriptionID -eq "All")
{
    $Subscriptions = Get-AzSubscription
}
else 
{
    $Subscriptions = Get-AzSubscription -SubscriptionId $SubscriptionID
}

$Subscriptions = Get-AzSubscription

$VNETS = @()

function Get-VNETS {

    [CmdletBinding()]
    Param
    (
        [string]
        $SubscriptionID,

        [string]
        $SubscriptionName
    )

    $VNETObjReturn = @()

    $SubscriptionVNETs = Get-AZVirtualNetwork

    foreach ($VNET in $SubscriptionVNETs) 
    {

        foreach ($VNETAddressPrefix in $VNET.AddressSpace.AddressPrefixes)
        {
            $VNETObj = New-Object PSObject
            $VNETObj | Add-Member -MemberType NoteProperty -Name "Name" -Value $VNET.Name
            $VNETObj | Add-Member -MemberType NoteProperty -Name "SubnetID" -Value ([IPAddress]($VNETAddressPrefix.split('/')[0]))
            $VNETObj | Add-Member -MemberType NoteProperty -Name "MaskBits" -Value ([int](($VNETAddressPrefix -split "/")[1]))
            $VNETObj | Add-Member -MemberType NoteProperty -Name "SubnetMask" -Value ([IPAddress]"$([system.convert]::ToInt64(("1"*[int](($VNETAddressPrefix -split "/")[1])).PadRight(32,"0"),2))")
            $VNETObj | Add-Member -MemberType NoteProperty -Name "SubscriptionName" -Value $SubscriptionName
            $VNETObj | Add-Member -MemberType NoteProperty -Name "SubscriptionID" -Value $SubscriptionID
            $VNETObjReturn += $VNETObj
        }
    }
    return $VNETObjReturn
}

foreach ($Subscription in $Subscriptions) 
{
    $SubscriptionName = (Get-AzSubscription -SubscriptionId $Subscription.SubscriptionID -WarningAction SilentlyContinue).name
    Select-AZSubscription -SubscriptionID $Subscription -WarningAction SilentlyContinue | Out-Null

    Write-Host "Collecting Data within the following Subscription: $($Subscription.Name)" -ForegroundColor Green
    Write-Host " "

    Write-Host "- Capturing VNet Information. " -ForegroundColor Yellow
    Write-Host " "

    $SubscriptionVNETs = Get-VNETS -SubscriptionID $Subscription.SubscriptionID -SubscriptionName $SubscriptionName
    $VNETS += $SubscriptionVNETs
}

Write-Host "_______________________________________________________________"
Write-Host " "
Write-Host "Results: " -ForegroundColor Green
Write-Host " "

foreach ($VNETObj in $VNETS) 
{
    $SmallVNETS = $VNETS | Where-Object { $_.MaskBits -gt $VNETObj.MaskBits }
    foreach ($SmallVNET in $SmallVNETS ) 
    {
        if (($SmallVNET.SubnetID.Address -band $VNETObj.SubnetMask.Address) -eq $VNETObj.SubnetID.Address) 
        {
            [PSCustomObject]@{
                VNET            = $VNETObj.Name
                VNETSubscriptionName = $VNETObj.SubscriptionName
                VNETSubscriptionID = $VNETObj.SubscriptionID
                OverlappingVNET = $SmallVNET.Name
                OverlappingVNETSubscriptionName = $SmallVNET.SubscriptionName
                OverlappingVNETSubscriptionID = $SmallVNET.SubscriptionID
            }
        }
    }
}