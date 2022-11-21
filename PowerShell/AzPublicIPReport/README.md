# AzPublicIPReport.ps1
## Description
This script creates an HTML Report on Public IP Information across a single or all subscriptions. This includes the new Public Preview for Public IP DDOS Protection. 

## PowerShell Versions Tested
- Windows PowerShell 5.1
- PowerShell 7.2.7

## AZ PowerShell Module Version Tested
- [9.1.1](https://github.com/Azure/azure-powershell/releases)

## Files Involved
- AzPublicIPReport.ps1

## Instructions
1. Download AzPublicIPReport.ps1
   
2. Execute according to the various specified in the script which include.  In this example, we'll run the script using the parameter -SubscriptionID All -SingleHTMLOutput $true.

    The command we execute will be:
      ```PowerShell
    .\AzPublicIPReport.ps1 -SubscriptionID All -SingleHTMLOutput $true
    ```
   
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

   This will generate a new folder called AzPublicIPReport:

   ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

   Open the AzPublicIPReport folder and open the timestamped folder within that contains the single html file that was generated. The folder under the AzPublicIPReport folder is timestamped to allow the script to be run again without overwriting the original file to maintain a history.

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

   Verify the information reported.

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)


3. To create a separate HTML Outputs for each Azure Subscription, leverage -SingleHTMLOutput $false.  

     The command we execute will be:
    ```PowerShell
    .\AzPublicIPReport.ps1 -SubscriptionID All -SingleHTMLOutput $false
    ```

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)


    Within the AzPublicIPReport Folder, just as before, there will be a new timestamped folder.  

    ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

    Within our timestamped folder, there will be a separate file named after each Subscription that was processed:

    ![Alt text](./DemoScreenshots/demo7.jpg?raw=true)

    Verify the information reported. It will contain Public IP Information for each subscription.

    ![Alt text](./DemoScreenshots/demo8.jpg?raw=true)
