# AzSubnetAvailability.ps1
## Description
This script creates an HTML Report on Subnet Availability across a single or all subscriptions.  This will help in the decision making process if VNET sizes need to be increased and potentially additional subnets need to be created.

## PowerShell Versions Tested
- Windows PowerShell 5.1
- PowerShell 7.2.6

## Files Involved
- AzSubnetAvailability.ps1

## Instructions
1. Download AzSubnetAvailability.ps1
   
2. Execute according to the various specified in the script which include.  In this example, we'll run the script using the parameter -SubscriptionID All -SingleHTMLOutput $true.

    The command we execute will be:
      ```PowerShell
    .\AzSubnetAvailability.ps1 -SubscriptionID All -SingleHTMLOutput $true
    ```
   
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

   Open the html file that was generated in the same folder. The file is timestamped to allow the script to be run again without overwriting the original file to maintain a history.

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

   Verify the information reported.

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

    > **Note**: The columns, by default, are sorted by PercentUsed. To change the sorting behavior, you can specify -SortColumn VNET. 

3. To create a separate HTML Outputs for each Azure Subscription, leverage -SingleHTMLOutput $false.  

     The command we execute will be:
    ```PowerShell
    .\AzSubnetAvailability.ps1 -SubscriptionID All -SingleHTMLOutput $false
    ```

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

    This will generate a new folder called AzSubnetAvailability:

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

    Within the AzSubnetAvailability Folder will be a timestamped folder.  This allows the script to be run again without overwriting the original output files from this execution.

    ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

    Within our timestamped folder, there will be a separate file named after each Subscription that was processed:

    ![Alt text](./DemoScreenshots/demo7.jpg?raw=true)

    Verify the information reported. It will only contain VNET & Subnet data for the given subscription.

    ![Alt text](./DemoScreenshots/demo8.jpg?raw=true)

    > **Note**: As stated earlier, the columns, by default, are sorted by PercentUsed. To change the sorting behavior, you can specify -SortColumn VNET. 


## Thresholds
As can be seen in the HTML Outputs, PercentUsed is has some color coding.  The script by default will color Subnet Percent Used based on the following critera:
   * Below 50% used: Green
   * Between 50% and 80% used: Yellow
   * Greater than or equal to 80%: Red

These thresholds can be adjused using the following two parameters:
   * RedThreshold
   * YellowThreshold
   
> **Important**: Ensure that RedThreshold is always a higher percentage than YellowThreshold.

For example, based on my usage in my lab environment, let's take a look at if I mark these two parameters with the following percentage values:
* RedThreshold = 3%
* YellowThreshold 0.7%

The command we execute will be:
```PowerShell
.\AzSubnetAvailability.ps1 -SubscriptionID All -SingleHTMLOutput $false -RedThreshold 3% -YellowThreshold 0.7%
```

The coloring of the cells changed based on the thresholds we defined.

![Alt text](./DemoScreenshots/demo9.jpg?raw=true)



