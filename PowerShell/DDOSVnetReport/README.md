# DDOSVnetReport.ps1
## Description
This script creates an HTML Report on DDOS Standard Virtual Network Assignment across a single or all subscriptions.  This will help determine what Virtual Networks have DDOS Standard Plans assigned to Virtual Networks and which do not.

## PowerShell Versions Tested
- Windows PowerShell 5.1
- PowerShell 7.2.7

## Files Involved
- DDOSVnetReport.ps1

## Instructions
1. Download DDOSVnetReport.ps1
   
2. Execute according to the various specified in the script which include.  In this example, we'll run the script using the parameter -SubscriptionID All -SingleHTMLOutput $true.

    The command we execute will be:
      ```PowerShell
    .\DDOSVnetReport.ps1 -SubscriptionID All -SingleHTMLOutput $true
    ```
   
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

   This will generate a new folder called DDOSVnetReport:

   ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

   Open the DDOSVnetReport folder and open the timestamped folder within that contains the single html file that was generated. The folder under the DDOSVnetReport folder is timestamped to allow the script to be run again without overwriting the original file to maintain a history.

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

   Verify the information reported.

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)


3. To create a separate HTML Outputs for each Azure Subscription, leverage -SingleHTMLOutput $false.  

     The command we execute will be:
    ```PowerShell
    .\DDOSVnetReport.ps1 -SubscriptionID All -SingleHTMLOutput $false
    ```

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)


    Within the DDOSVnetReport Folder, just as before, there will be a new timestamped folder.  

    ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

    Within our timestamped folder, there will be a separate file named after each Subscription that was processed:

    ![Alt text](./DemoScreenshots/demo7.jpg?raw=true)

    Verify the information reported. It will  contain VNET & DDOS Standard Plan data for the each subscription.

    ![Alt text](./DemoScreenshots/demo8.jpg?raw=true)
