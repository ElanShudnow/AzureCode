# QuotaReport.ps1
## Description
Imports a Settings.json that defines Subscriptions, Regions, and Percentage Thresholds and retreives CPU Quotas and Subnet Usage Information and outputs results to an HTML. Based on thresholds defined in Settings.json, the percentage column will be color coded (green, yellow, or red) accordingly.

## PowerShell Versions Tested
- Windows PowerShell 5.1
- PowerShell 7.2.1

## Files Involved
- QuotaReport.ps1
- Settings.json
- QuotaReport-\[Date]-[SubscriptionID].html (created after script execution)

## Instructions
1. Download QuotaReport.ps1 and Settings.json
   
2. Edit Settings.json.csv to define Subscriptions, Regions, and thresholds for color coding.
   
    ``` json
    {
        "Subscriptions": [
            "SubscriptionID1",
            "SubscriptionID2"
        ],
        "VMQuota": {
            "Regions": [
                "centralus"
            ],
            "Threshold": {
                "Red": "80%",
                "Yellow": "50%"
            }
        },
        "Subnet": {
            "Threshold": {
                "Red": "80%",
                "Yellow": "50%"
            }
        }
    }
    ```

    > **Note**: If wanting to specify a single subscription, define as below:

    ``` json
    "Subscriptions": [
        "SubscriptionID",
    ],
    ```

3. Open PowerShell, navigate to script directory, and connect to Azure leveraging Connect-AZAccount

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)


4. Execute the script using .\QuotaReport.ps1. The script executes, cycles through all subscriptions you have defined, and outputs an HTML Output file per Subscription. These HTML Output files are timestamped and have the SubscriptionID in the file name as well.

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

5. After opening our HTML Output File for our first subscription, we can see the first table will include CPU Quota for each region defined:

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

6. Scrolling down in our HTML Output file, we will see similar Subnet Availability Information also color coded based on thresholds defined in Settings.json.

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

7. Taking a look at our HTML Output File for our second subscription which is more limited on CPU Quota, we can see the first table will include CPU Quota for each region defined:

    ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

8. I created a new Virtual Machine in our second subscription which would put the CPU Quota for that SKU at the red threshold and re-ran the script.  Opening our new HTML Output File for this second subscription and we see the new table displaying that CPU Quota as Red.

    ![Alt text](./DemoScreenshots/demo7.jpg?raw=true)


