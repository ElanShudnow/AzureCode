# AzCostAdvisorMGScope.ps1
## Description
This script creates a report for Azure Advisor Cost Recommendations at the Management Group Scope in a recursive or non-recursive manner.

## PowerShell Versions Tested
- Windows PowerShell 5.1
- PowerShell 7.3.2

## AZ PowerShell Module Version Tested
- [9.3.0](https://github.com/Azure/azure-powershell/releases)

## Files Involved
- AzCostAdvisorMGScope.ps1

## Instructions
1. Download AzCostAdvisorMGScope.ps1
      
2. Execute according to the various specified in the script which include.  In this example, we'll run the script using the parameter -ManagementGroupID Parent1

    The command we execute will be:
      ```PowerShell
    .\AzCostAdvisorMGScope.ps1 -ManagementGroupID Parent1
    ```
   
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

   This will generate a new folder called AzPublicIPReport:

   ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

  3.  Open the AzCostAdvisorMGScope folder and open the timestamped folder within that contains the single csv file that was generated. The folder under the AzPublicIPReport folder is timestamped to allow the script to be run again without overwriting the original file to maintain a history.

      ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

  4. Verify the information reported. As you will see, the report will include the following pieces of information about the Cost Recommendations, such as:

       * Category
       * SubscriptionID
       * SubscriptionName
       * ManagementGroupID
       * Resource
       * ResourceGroup
       * Severity
       * LastUpdated
       * Description
     
       <br/>

      ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)


## Recursion
In order to obtain Cost Advisor Recommendations for all subscriptions within the ManagmentGroupID specified and recurse through all child Management Groups and their subscriptions, add the -Recurse $true.

1. Change your command to also include -Recurse $true

    The command we execute will be:
      ```PowerShell
    .\AzCostAdvisorMGScope.ps1 -ManagementGroupID Parent1 -Recurse $true
    ```

    As we can see in the following execution, additional subscriptions have been scanned for Azure Advisor results.

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)
