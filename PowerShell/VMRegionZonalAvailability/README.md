# Get-VMRegionZonalAvailability.ps1
## Description
This PowerShell Script takes a list of Virtual Machine SKUs from a CSV and Regions specified as an array in script and gets a list of what Virtual Machine SKUs are supported in the specified Regions as well as what Availability Zones these VM SKUs are available in.  The script will leverage the List Locations API to also output the Logical to Physical Zone Mapping.  This script will provide output of the results in both the PowerShell Console as well as a CSV output in the same directory the script is executed from. 

## PowerShell Versions Tested
- Windows PowerShell 5.1
- PowerShell 7.2.1

## Files Involved
- Get-VMRegionZonalAvailability.ps1
- VMSKUs.csv
- output.csv (created after script execution)

## Instructions
1. Download Get-VMRegionAvailability.ps1 and VMSKUs.csv
   
2. Edit VMSKUs.csv to include the Virtual Machine SKUs you want to test.
   
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

3. Edit Get-VMRegionZonalAvailability.ps1 to include the Regions you want to test Virtual Machine SKU availability against.
   
   ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)
   
4. Open PowerShell, navigate to script directory, and connect to Azure leveraging Connect-AZAccount

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

5. If wanting to select a different subscription, run Get-AZSubscription and then Select-AZSubscription to change Subscription.

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

6. Execute the script using .\Get-VMRegionZonalAvailability.ps1.  A Windows File Dialog filtering on CSV appears in the same folder the script was executed from.  Choose the CSV containing the list of Virtual Machine SKUs.

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

7. The results are provided in the PowerShell Console. 

    If a successful List Locations API lookup was performed, the PowerShell output will contain information about the SKU's availability in both Logical Availability Zones and Physical Availability Zones.

    ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

    If an unsuccessful List Locations API lookup was performed, the output will only contain information about the Logical Availability Zones.

    ![Alt text](./DemoScreenshots/demo8.jpg?raw=true)

8. An output CSV is also generated and stored in the same folder the script was executed from. The location is specified at the bottom of the PowerShell Console. 

    If a successful List Locations API lookup was performed, the output will contain information about the Logical Availability Zone to Physical Availability Zone Mapping in greater detail than the PowerShell Output
   
   ![Alt text](./DemoScreenshots/demo7.jpg?raw=true)

    If an unsuccessful List Locations API lookup was performed, the output will contain information only about the Logical Availability Zones.
   
   ![Alt text](./DemoScreenshots/demo9.jpg?raw=true)