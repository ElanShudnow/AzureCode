# AzMMARemoval.ps1
## Description
This script will cycle through Virtual Machines that have the MMA agent installed and if that VM also has the AMA agent installed, MMA will get removed.  The intention of this script is to provide an easy mechanism to decomission MMA once AMA has been rolled out to your fleet of VMs. The script allows you to target an individual Subscription or Subscriptions within a Management Group optionally allowing you to recurse through child Management Groups and their Subscriptions.

## PowerShell Versions Tested
- PowerShell 7.4.3

## AZ PowerShell Module Version Tested
- [11.6.0](https://github.com/Azure/azure-powershell/releases)
- [12.1.0](https://github.com/Azure/azure-powershell/releases)

## Files Involved
- AzMMARemoval.ps1

## Instructions
There we will be two separate instructional sections:
1. Logging Mode
2. Removal Mode

### Logging Mode
1. Download AzMMARemoval.ps1
      
2. Execute according to the various specified in the script which include.  In this example, we'll run the script using the parameter -LoggingMode $true against a Management Group and to recurse against all child management groups and their directly associated subscriptions.

    Looking at our Management Group Hiearchy, our script will executed to target our Parent Management Group and its subscription, and will the -Recurse option set to $true, will also target our Child Management Group and its subscription.

    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

    The command we execute will be:
      ```PowerShell
    .\AzMMARemoval.ps1 -ManagementGroupID Parent -Recurse $true -LoggingOnly $true
    ```
3. Analyze the PowerShell Output.  The following data will be displayed:
    * Script Mode
      * We are executing the script in Management Group Mode because we specified -ManagementGroupID, rather than targetting a specific Subscription via -SubscriptionID.
      * Recursion Mode is enabled.  
      * Logging Only mode is enabled.  The script will not initiate MMA Extension Removal on any VMs.
    * Connection to the Subscriptions that fall into the parent Management Group and child management groups due to Recursion being enabled
    * Script will then pull all subscriptions that have MMA on them.  The script will then check each VM whether it has AMA.  The results are provided as well as a status as to what WOULD happen if the script was not run in logging only mode.  If a Subscription has no VMs with MMA, it will provide this information.
    * Location to a timestamped CSV file that contains the results of this data.

![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

  Here is an example of executing the script against a single subscription with LoggingOnly mode enabled and the resulting PowerShell output.
  ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

4. Analyze CSV file

    Open the CSV file based on the location provided at the end of the PowerShell Output. This will be in the same folder the script was executed in.  The script will provide the same data that was provided in the PowerShell Output in spreadsheet format.

      ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)


### Removal Mode
1. Download AzMMARemoval.ps1
      
2. Execute according to the various specified in the script which include.  In this example, we'll run the script using the parameter -LoggingMode $false against a Management Group and to recurse against all child management groups and their directly associated subscriptions.

    Looking at our Management Group Hiearchy, our script will executed to target our Parent Management Group and its subscription, and will the -Recurse option set to $true, will also target our Child Management Group and its subscription.

    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

    The command we execute will be:
      ```PowerShell
    .\AzMMARemoval.ps1 -ManagementGroupID Parent -Recurse $true -LoggingOnly $false
    ```
3. As this is a destructive change (uninstalling MMA), the script, after run will inform you what Script Mode the script is executing (with red text informing you logging only mode is disabled and the script will remove MMA on VMs that also have AMA) and require confirmation input that will only accept the responses Yes or No (default is No).

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

4. Analyze the PowerShell Output.  The following data will be displayed:
    * Script Mode
      * We are executing the script in Management Group Mode because we specified -ManagementGroupID, rather than targetting a specific Subscription via -SubscriptionID.
      * Recursion Mode is enabled.  
      * Logging Only mode is disabled.  The script will initiate MMA Extension Removal on any VMs that have both MMA and AMA installed.
    * Results of the Confirmation 
    * Connection to the Subscriptions that fall into the parent Management Group and child management groups due to Recursion being enabled
    * Script will then pull all subscriptions that have MMA on them.  The script will then check each VM whether it has AMA.  The results are provided as well as a status informing you what VMs are running through the MMA removal process as well as a follow up status whether the removal was successful or unsuccessful for the given VM.  If a Subscription has no VMs with MMA, it will provide this information.
    * Location to a timestamped CSV file that contains the results of this data.

![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

  Here is an example of executing the script against a single subscription with LoggingOnly mode disabled and the resulting PowerShell output.
  ![Alt text](./DemoScreenshots/demo7.jpg?raw=true)

5. Analyze CSV file

    Open the CSV file based on the location provided at the end of the PowerShell Output. This will be in the same folder the script was executed in.  The script will provide the same data that was provided in the PowerShell Output in spreadsheet format.  

      ![Alt text](./DemoScreenshots/demo8.jpg?raw=true)
