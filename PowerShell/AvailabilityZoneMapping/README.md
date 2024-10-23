# Get-AvailabilityZoneMapping
## Description
This PowerShell Script takes a list of Azure Subscriptions you have selected in Grid View and cycles through each subscription and obtains information about the Logical to Physical Zone Mapping.  Information is collected and outputted to an output.csv in the same folder the script was executed in.

## PowerShell Versions Tested
- Windows PowerShell 5.1
- PowerShell 7.2.1

## Files Involved
- Get-AvailabilityZoneMapping.ps1
- output.csv (created after script execution)

## Instructions
1. Download Get-AvailabilityZoneMapping.ps1
      
2. Open PowerShell, navigate to script directory, and connect to Azure leveraging Connect-AZAccount.  There is no need to connect to a specific subscription as we will be leveraging Rest API via Invoke-AzRestMethod.

    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

3. Execute the script using .\Get-AvailabilityZoneMapping -Region \<Region>.  

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)
   
4. A grid view of all Subscriptions in your environment appears.  Select or Multi-Select the Subscriptions you want to collect Logical to Physical Availability Zone Information for.

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

5. The status of the collection process as well as the output location are provided in the PowerShell Console. 

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

6. In the output CSV that is generated, you will see details around the Subscriptions and Physical to Logical Availability Zone Mapping. 
   
   ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

## 10/23/2024 Script Update - Checking for Valid Regions and Zonal Existance.
In the script update pushed on 10/23/2024, I have added two new capabilities to the script:
- Checking for the existance of the Region specified.  If the Region does not exist as typed, the script will terminate with information on how to capture the correct Region Name
- If the Region exists as typed, the script will check if the Region contains Availability Zones.  If not, the script will terminate with the reason being the Region does not contain Availability Zones and provide documentation link to what Regions support Availability Zones.

### Region Does Not Exist:
![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

### Availability Zone Does Not Exist for Region:
![Alt text](./DemoScreenshots/demo7.jpg?raw=true)

