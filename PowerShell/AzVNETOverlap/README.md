# AzVNETOverlap.ps1
## Description
This script creates will output any VNET that overlaps with another VNET. 

## PowerShell Versions Tested
- PowerShell 7.3.4

## AZ PowerShell Module Version Tested
- [9.7.1](https://github.com/Azure/azure-powershell/releases)

## Files Involved
- AzVNETOverlap.ps1

## Instructions
1. Download AzVNETOverlap.ps1
   
2. Execute according to the various specified in the script which include.  In this example, we'll run the script using the parameter -SubscriptionID All -SingleHTMLOutput $true.

    The command we execute will be:
      ```PowerShell
    .\AzVNETOverlap.ps1 -SubscriptionID All
    ```
   
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)