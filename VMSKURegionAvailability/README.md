# Get-RegionAvailability.ps1
## Description
This PowerShell Script was to take a list of Virtual Machine SKUs and Regions from a CSV and get a list of what Virtual Machine SKUs are supported in the specified Regions.  This script will provide output of the results in both the PowerShell Console as well as a CSV output in the same directory the script is executed from. 

## PowerShell Versions Tested
- Windows PowerShell 5.1
- PowerShell 7.2.1

## Files Involved
- Get-VMRegionAvailability.ps1
- VMSKUs.csv
- output.csv (created after script execution)

## Instructions after downloading Get-VMRegionAvailability.ps1 and VMSKUs.csv
1. Open PowerShell
2. Connect-AZAccount and authenticate
3. Get-AZSubscription to obtain a list of all Subscriptions
4. Select-AZSubscription -SubscriptionID \<SubscriptionID\>
5. Navigate to Script Directory that contains Get-VMRegionAvailability.ps1 and VMSKUs.csv
6. Edit the CSV to include the list of VMSKUs you want the script to check
7. Edit the PS1 script to include the Regions you want to check
8. ./Get-VMRegionAvailability.ps1

## Instructions
1. Edit VMSKUs.csv to include the Virtual Machine SKUs you want to test.
   
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

2. Edit Get-VMRegionAvailability.ps1 to include the Regions you want to test Virtual Machine SKU availability against.
   
   ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)
   
3. Open PowerShell, navigate to script directory, and connect to Azure leveraging Connect-AZAccount

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

4. If wanting to select a different subscription, run Get-AZSubscription and then Select-AZSubscription to change Subscription.

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

5. Execute the script using .\Get-VMRegionAvailability.ps1.  A Windows File Dialog filtering on CSV appears in the same folder the script was executed from.  Choose the CSV containing the list of Virtual Machine SKUs.

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

6. The results are provided in the PowerShell Console. 

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

7. An output CSV is also generated and stored in the same folder the script was executed from. The location is specified at the bottom of the PowerShell Console. 
   
   ![Alt text](./DemoScreenshots/demo7.jpg?raw=true)