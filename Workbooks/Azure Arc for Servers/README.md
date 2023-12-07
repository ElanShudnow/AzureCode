# Azure Arc for Servers.workbook
## Description
This Azure Arc for Servers Workbook provides much information around Azure Arc for Server Virtual Machines that includes Overview, Server Health, Extension Health, Security, and ESU information. This is an updated Workbook which is a continuation of the Workbook that was documented in a Tech Community Blog Post I wrote here: [Tech Community Post](https://techcommunity.microsoft.com/t5/azure-arc-blog/azure-arc-for-servers-monitoring-workbook/ba-p/3298791).

## Files Involved
- Azure Arc for Servers.workbook

## Installation Instructions
1. Download Azure Arc for Servers.workbook

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
- **Subscriptions** - The Subscriptions parameter allows you to filter on Azure Arc Servers in specific Subscription(s). The Subscriptions Parameter has been configured to only show Subscriptions that contain Azure Arc for Server resources.  If you have 1000 Subscriptions but only 5 have Azure Arc for Server resources, only 5 Subscriptions will appear in the dropdown.
- **LogAnalytics** - The LogAnalytics parameter allows you to filter on Azure arc Servers in specific Log Analytics Workspaces.  The LogAnalytics Parameter has been configured to only show Log Analytics Workspace that belong to the Subscriptions you are filtering on.  
- **TimeRange** - The TimeRange parameter allows you to filter results for Log Analytics Workspace queries for up to a specified time range.
   
There are 5 tabs that allow you to filter the data you care about:

  ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

The Tabs include the following data:

- Overview
  - Server List
  - Operating System Breakdown
  - Server Status Breakdown
  - World Map by Country
  - Server List running in other Cloud Providers
  - Installed Extension List with filtering for specific Installed Extensions
  - ADDS Domain / Workbrook Breakdown
- Server Health
  - Unhealthy Server List
  - Servers with SQL not using Arc-enabled SQL
  - 50 Volumes with the Lowest Disk Space in the last x amount of days where x is the value of the TimeRange parameter. This data requires the Azure Arc Server(s) to be reporting performance counters into Log Analytics
  - Arc-Enabled Servers with a newer agent available
- Extension Health
  - Failed Extensions
  - Extensions automatically upgraded in the last x amount of days where x is the value of the TimeRange parameter.
  - Extensions with Automatic Upgrades Disabled
- Security
  - Azure Advisor Security Recommendations filterable on High, Medium, and Low
- Extended Security Updates
  - All Windows 2012 and Windows 2012 R2 Servers and their ESU status which includes:
    - License Assignment State
    - ESU Eligibility
    - ESU Key State

Below is an example of each report.

### Overview Tab Examples

**Server List**

  ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

**Operating System Breakdown**

  ![Alt text](./DemoScreenshots/demo7.jpg?raw=true)

**Server Status Breakdown**

  ![Alt text](./DemoScreenshots/demo8.jpg?raw=true)

**Map by Country**

  ![Alt text](./DemoScreenshots/demo9.jpg?raw=true)

**Arc Servers running in other Cloud Providers**

  ![Alt text](./DemoScreenshots/demo10.jpg?raw=true)

**Installed Extensions**

  ![Alt text](./DemoScreenshots/demo11.jpg?raw=true)

**ADDS Domain / Workgroup breakdown**

  ![Alt text](./DemoScreenshots/demo12.jpg?raw=true)


### Server Health Examples

**Unhealthy Servers**

  ![Alt text](./DemoScreenshots/demo13.jpg?raw=true)

**Servers with SQL not using Arc-enabled SQL**

  ![Alt text](./DemoScreenshots/demo14.jpg?raw=true)

**50 Volumes with the Lowest Disk Space in the last x amount of days where x is the value of the TimeRange parameter**

  ![Alt text](./DemoScreenshots/demo15.jpg?raw=true)

  > **_Note:_** Here is a previous example from when I first released an older version of this Workbook as documented on my Tech Community Post where I first released this Workbook here: [Tech Community Post](https://techcommunity.microsoft.com/t5/azure-arc-blog/azure-arc-for-servers-monitoring-workbook/ba-p/3298791) 

  ![Alt text](./DemoScreenshots/demo16.jpg?raw=true)

**Newer Agent Version Available**

  ![Alt text](./DemoScreenshots/demo17.jpg?raw=true)

### Extension Health Examples

**Failed Extensions**

  ![Alt text](./DemoScreenshots/demo18.jpg?raw=true)

**Extensions with Automatic Upgrades Disabled**

  ![Alt text](./DemoScreenshots/demo19.jpg?raw=true)

### Security Examples

**Advisor Security Recommendations**

  ![Alt text](./DemoScreenshots/demo20.jpg?raw=true)

### Extended Security Updates Examples

**Extended Security Update Status**


  > **_Note:_** I will provide an updates ESU example once I can get this Workbook deployed into an environment with a mix of 2012 and 2012 R2 Servers that have both been assigned licenses and not assigned licenses.


  ![Alt text](./DemoScreenshots/demo21.jpg?raw=true)


