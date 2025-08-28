# AzVMMaintenanceConfig.ps1
## Description
This script creates assigns a Maintenance Configuration to all Virtual Machines, both Windows and Linux, in a given Subscription or a Management Group Scope in a recursive or non-recursive manner.  This script will also enable Customer Managed Schedules. 

## PowerShell Versions Tested
- PowerShell 7.5.2

## AZ PowerShell Module Version Tested
- [13.3.0](https://github.com/Azure/azure-powershell/releases)

## Files Involved
- AzVMMaintenanceConfig.ps1

## Instructions to Add Maintenance Configurations to Virtual Machines
1. Download AzVMMaintenanceConfig.ps1

2. For purposes of this demonstration, as can be seen, our Maintenance Configuration currently has no VM resources assigned.

    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)
      
2. Execute according to the various specified in the script which include.  In this example, we'll run the script using the parameter -ManagementGroupID Parent1, specify the ResourceID of our Maintenance Configuration, and set the mode to Add.

    The command we execute will be:
      ```PowerShell
    .\AzVMMaintenanceConfig.ps1 -ManagementGroupID Parent1 -Mode Add -MaintenanceConfigID '/subscriptions/6eg8be2d-dj8d-4adb-a467-78250953235d/resourcegroups/mc/providers/Microsoft.Maintenance/maintenanceConfigurations/mc1'
    ```

    > **Note**: Alternatively, instead of using -ManagementGroupID, you can instead leverage -SubscriptionID.

   
    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

3. The script initiates and provides some general information as to what the script will do.  As we are running in Add mode, the script will run through 2 stages:
    * Stage 1
      * Retrieving information about the Maintenance Configuration by changing to the Subscription that contains the Maintenance Configuration Resource (obtained from the ResourceID).
    * Stage 2
      * Enable Customer Managed Schedule on the Virtual Machine
      * Assign the Maintenance Configuration to the Virtual Machine.

  
    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

4. By going back into the Maintenance Configuration in the Azure Portal, we can validate that the 2 Virtual Machines contained within the Management Group specified have been assigned as resources to the Maintenance Configuration.

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

## Instructions to Remove Maintenance Configurations from Virtual Machines

Now that we have two Virtual Machines assigned to the mc1 Maintenance Configuration based on the steps followed above, let's run the script in Remove Mode to remove the Virtual Machines from the Maintenance Configuration. 

1. Execute according to the various specified in the script which include.  In this example, we'll run the script using the parameter -ManagementGroupID Parent1, specify the ResourceID of our Maintenance Configuration, and set the mode to Add.

    The command we execute will be:
      ```PowerShell
    .\AzVMMaintenanceConfig.ps1 -ManagementGroupID Parent1 -Mode Remove
    ```
   
    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

2. The script initiates and provides some general information as to what the script will do. As we are running in Remove mode, the script will run through 1 stage which is cycling through the Virtual Machines within the Management Group or Subscription specified.

    ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)


## Recursion
In order to obtain Cost Advisor Recommendations for all subscriptions within the ManagmentGroupID specified and recurse through all child Management Groups and their subscriptions, add the -Recurse $true.

1. Change your command to also include -Recurse $true

    The command we execute will be:
      ```PowerShell
    .\AzCostAdvisorMGScope.ps1 -ManagementGroupID Parent1 -Recurse $true
    ```

    As we can see in the following execution, additional subscriptions have been scanned for Azure Advisor results.

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)
