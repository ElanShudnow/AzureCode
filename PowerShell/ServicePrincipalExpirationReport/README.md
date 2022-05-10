# ServicePrincipalExpirationReport.ps1
## Description
Obtain a list of all Azure AD Application Service Principals and obtain a list of certificates and secrets associated and their expiration dates. This list will be created in an HTML Output where all expirations have color coded cells based on the following criteria:
- Secrets/Certificates expiring or already expired within the next 30 days will colored red
- Secrets/Certificates expiring between 30 and 90 days will colored yellow
- Secrets/Certificates expiring more than 90 days out will colored green

## PowerShell Versions Tested
- Windows PowerShell 5.1
- PowerShell 7.2.1

## Files Involved
- ServicePrincipalExpirationReport.ps1
- ServicePrincipalReport-\[Date].html (created after script execution)

## Instructions
1. ServicePrincipalExpirationReport.ps1
   
2. Open PowerShell, navigate to script directory, and connect to Azure leveraging Connect-AZAccount

    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)


3. Execute the script using .\ServicePrincipalExpirationReport.ps1. The script executes and outputs an HTML Output file. These HTML Output files are timestamped in the file name.

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

4. After opening our HTML Output File, we can see the table will include Service Principal information for each Azure AD Application:

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)



## How to leverage
There are several ways you can leverage this PowerShell Script, including but not limited to:

- Logic App to execute code, take the html response, insert into the body of an e-mail, and send to Administrator team to take necessary action
- Function App to run code, take the html response, and send e-mail to Administrator team to take necessary action
- Runbook to run code, take the html response, and send e-mail to Administrator team to take necessary action
- Etc...




