# AzResourceMoveSupport.ps1
## Description
This script will take an Azure Usage Report csv file and provide new columns as to whether each resource supports migration to another Resource Group, to another Subscription, or to another Region.

## PowerShell Versions Tested
- PowerShell 7.4.0

## Files to Download
- AzResourceMoveSupport.ps1

## Instructions
1. Download AzResourceMoveSupport.ps1

2. Download a copy of your Azure Usage Details Report by going to the Azure Portal, Cost Management + Billing, clicking on your Billing Scope, and selecting your Billing Scope.  Download the latest copy of your Usage Details Report.  This will provide you a CSV download of all Azure resources that fall within that Billing Scope including much information about each resource including the Resource Type, Cost, Subscription, and much more.
   
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

3. Execute the AzResourceMoveSupport.ps1 script.  Upon execution, the script will prompt you to select the Azure Usage Details csv file.  

    The command we execute will be:
      ```PowerShell
    .\AzResourceMoveSupport.ps1
    ```

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)
   
   
 4. Review Script Execution.

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

    Take note of the following:

    - The script will download the move-support-resources-with-regions.csv file that contains all the same information included in the [Move operation support for resources
](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-support-resources) Azure documentation. In fact, in this article, if you scroll down to the very bottom, you will see a link to this csv file. 

5. The script will then take the Azure Usage Details report and for each resource, it will do a check against the move-support-resources-with-regions.csv to check if each resource supports eith a resource move to another Resource Group, Subscription, or Region.  A new CSV will be generated that contains all the same data from the Azure Usage Details csv and will generate a new CSV with three new columns:

     - Supports Resource Group Move
     - Supports Subscription Move
     - Supports Region Move

    The value for each column will contain either a 0 or 1.  0 means not supported.  1 means supported.
   
6. Read the ResourcesOutput.csv output file.  Again, all original columns in the Usage Report Details csv are maintained with this script adding the 3 additional cumns for Resource Group, Subscription, and Region move support.  Here is an example of a tiny portion of the CSV displaying the new data.

      ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

## Column Information
Here is a list of every column provided in the ResourcesOutput.csv:
- BillingAccountId
- BillingAccountName
- BillingPeriodStartDate
- BillingPeriodEndDate
- BillingProfileId
- AccountOwnerId
- AccountName
- SubscriptionId
- SubscriptionName
- Date
- Product
- PartNumber
- MeterId
- ServiceFamily
- MeterCategory
- MeterSubcategory
- MeterRegion
- MeterName
- Quantity
- EffectivePrice
- Cost
- UnitPrice
- BillingCurrency
- ResourceLocation
- AvailabilityZone
- ConsumedService
- ResourceId
- ResourceName
- ResourceType
- Supports Resource Group Move
- Supports Subscription Move
- Supports Region Move
- ServiceInfo1
- ServiceInfo2
- AdditionalInfo
- Tags
- InvoiceSectionId
- InvoiceSection
- CostCenter
- UnitOfMeasure
- ResourceGroup
- ReservationId
- ReservationName
- ProductOrderId
- ProductOrderName
- OfferId
- IsAzureCreditEligible
- Term
- PublisherName
- PlanName
- ChargeType
- Frequency
- PublisherType
- PricingModel
- PayGPrice
- InvoiceID
