# Azure Virtual Machine Volumes.workbook
## Description
This Azure Virtual Machine Volumes provides information around Azure Virtual Machine Volumes and/or Azure Arc for Server Virtual Machine Volumes.  This does require Virtual Machines and Arc-Enabled Servers to be connected to Log Analytics.  The Workbook allows you to select between Server Performance Counters or VMInsights, with VMInsights providing additional data that is not collectable using Performance Counters.

## Files Involved
- Azure Virtual Machine Volumes.workbook

## Installation Instructions
1. Azure Virtual Machine Volumes.workbook

2. Install by going to Azure Monitor > Workbooks > click New.

    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

3. Click the edit icon on the Workbook toolbar

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

4. Copy the contents of the downloaded Workbook into the Editor by fully replacing all the existing content in the Workbook

    ![Alt text](./DemoScreenshots/demo3.gif?raw=true)

## Workbook Features

### Parameters and Tab View Filtering
There are three parameters that dictate the data that appears in the rest of the Workbook.  

  ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

These parameters include:
- **Subscriptions** - The Subscriptions parameter filters on Subscriptions that contain both Azure Virtual Machines and Azure Arc Servers in specific Subscription(s). If you have 1000 Subscriptions but only 5 have Azure Arc for Server and only 10 Subscriptions have Azure Virtual Machine resources, only 15 Subscriptions will appear in the dropdown.
- **LogAnalytics** - The LogAnalytics parameter allows you to filter on Azure Virtual Machines and/or Azure Arc Servers in specific Log Analytics Workspaces.  The LogAnalytics Parameter has been configured to only show Log Analytics Workspace that belong to the Subscriptions you are filtering on.  
- **TimeRange** - The TimeRange parameter allows you to filter results for Log Analytics Workspace queries for up to a specified time range.
- **Method** - The Method parameter allows you to show Volume results from Servers that are pushing Volume Free Space Performance Counters or Servers that are connected to Virtual Machine Insights.  Virtual Machine Insights option will show additional data that is not collected via Performance Metrics.
- **Quantity** - The Quantity parameter allows you to show only the specified amount of Volumes, ordered by the least amount of free space available.

If presenting the data via Performance Counters, you will be provided a table that looks as such:

  ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

If presenting the data via Virtual Machine Insights, you will be provided a similar table with additional results including FreeSpaceGB and volumeSizeGB:

  ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)