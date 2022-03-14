# HRWRemoteCodeExecution.ps1
## Description
This PowerShell Script enables a Hybrid Runbook Worker (in or outside Azure) and executes a remote PowerShell Script against servers specified within a PowerShell Array.  The script leverages a Run-As Account with API Permissions against an Azure Key Vault to retrieve password for an ADDS Service Account that is used to execute the remote code.

The following provides the operations of the Runbook in regards to the Run-As Account vs ADDS Service Account:
1. Run-As Account Connects to Azure Key Vault to retrieve ADDS Service Account password.
2. Runbook initiates a Connect-AZAccount using the Run-As Account.  This requires the Run-As Account Certificate to be installed locally on the Hybrid Runbook Worker Server.  The Runbook includes code to do this.
3. The Hybrid Runbook Worker Server initiates a Remote PowerShell Session to the Destination Servers specified in the $Servers array and leverages the ADDS Service Account credentials to initiate the Remote PowerShell Session.  Therefore, the ADDS Service Account must be given permissions on the Destination Server such as Local Administrator.

## PowerShell Versions Tested
- Windows PowerShell 5.1

## Files Involved
- HRWRemoteCodeExecution.ps1

## Instructions
1. Download HRWRemoteCodeExecution.ps1
   
2. Create Resource Group and Automation Account
   
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

3. Disable Managed Identity during Automation Account creation.  We will be instead leveraging an Automation Account.  The reason for this is our Run-As account will need Azure AD API Permissions to Azure Key Vault to retrieve the Service Account password.  Managed Identities do not show up in the Azure Portal when viewing App Registrations whereas Run-As accounts do.  Managed Identities can work but require PowerShell to manage API Permissions to Azure AD.

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

4. Create a Run-As Account for our Automation Account.

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

5. In Azure AD, give our Run-As Account Delegated Permissions to Azure Key Vault.  Go to Azure Active Directory > App Registrations > All applications > find our Run-As Account.

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

6. Click our Run-As Account > API Permissions > Add a permission

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)

7. Click APIs my organization uses and search for Azure Key Vault.  

    ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

8. Click on Azure Key Vault and assign user_impersonation.

    ![Alt text](./DemoScreenshots/demo7.jpg?raw=true)

9. Create a new Standard Key Vault (Premium works too if you plan on leveraging this Key Vault for other uses and need HSM Backed Keys). Make sure to add a new Access Policy permission granting permission for your Run-As account to Get secrets.

    ![Alt text](./DemoScreenshots/demo8.jpg?raw=true)

10. Create a Service Account in Active Directory Domain Services (ADDS) which has Local Administrator priveldges on the Servers in which Remote Code Execution will occur against. Allow the Service Account to replicate to Azure Active Directory (AAD) which by default replicates every 30 minutes.

11. Store the Service Account password as a secret in your Azure Key Vault. 

12. In PowerShell, connect to Azure leveraging Connect-AZAccount, select the appropriate Subscription leveraging Select-AZSubscription, and then create your Key Vault Secret.

    ```PowerShell
    $secretvalue = ConvertTo-SecureString "ServiceAccountPasswordHere" -AsPlainText -Force
    $secret = Set-AzKeyVaultSecret -VaultName "KeyVaultName" -Name "SecretName" -SecretValue $secretvalue
    ```

    For purposes of my lab, I'm going to use my Domain Admin Account, Shudnow\eshudnow. I'm also going to name the Secret, HRWRemoteCodeExecutionKVSecret.

    ![Alt text](./DemoScreenshots/demo9.jpg?raw=true)

13. Verify the Key Vault Secret has been created.

    ![Alt text](./DemoScreenshots/demo10.jpg?raw=true)

14. In our Automation Account, create a User hybrid worker group

    ![Alt text](./DemoScreenshots/demo11.jpg?raw=true)

15. ASsign a name and leave 'Use run as credentials" to No.
    
    ![Alt text](./DemoScreenshots/demo12.jpg?raw=true)

16. Add an Azure Virtual Machine as the Hybrid Runbook Worker.  If you'd alternatively want an on-premises server to act as the Hybrid Runbook Worker, you will need to first ARC-Enable this VM.  For information on how to do that, please click [here](https://docs.microsoft.com/en-us/azure/azure-arc/servers/onboard-portal).

    ![Alt text](./DemoScreenshots/demo13.jpg?raw=true)

17. Create a Runbook in our Automation Account.  We're using PowerShell 5.1 as the Runtime as PowerShell 7.1 is in preview.

    ![Alt text](./DemoScreenshots/demo14.jpg?raw=true)

18. Copy the code into the Runbook and modify the following:
    - **$Servers** - Servers you want the Hybrid Runbook Worker to execute remote code against.
    - **$userName** - Username of the Service Account you will leverage to execute remote code against the servers defined in the $servers variable.
    - **$KeyVaultName** - Name of the Key Vault which holds the Secret containing the password for the Service Account that will be used to execute remote code.
    - **$KeyVaultSecretName** - Name of the Secret stored in Key Vault which contains the password for the Service Account that will be used to execute remote code. 

    ![Alt text](./DemoScreenshots/demo15.jpg?raw=true)

    **Note:** You will also want to modify line 70 to specify the PowerShell Script you will want to execute remotely against the servers defined in the $Servers array. 

    For Line 70, we specify to execute the Script, "C:\PowerShell\Script.ps1" against the servers specified in the $servers array.  This script lives on the target servers, not on the Hybrid Runbook Worker server.

    ```PowerShell
    Invoke-Command -Session $s -Command {C:\PowerShell\Script.ps1}
    ```
    
    In the Script, we have a single server specified in the $Servers array.  This server is, vmdc01.  On vmdc01, we have a PowerShell script in C:\PowerShell\Script.ps1 as specified above. 

    ![Alt text](./DemoScreenshots/demo16.jpg?raw=true)

    As you can see, this is the only file in the folder.  The code within this script is simple.  Obtain a list of files in C:\Temp and create a log file with the list of files found.  This is to demonstrate that the Hybrid Runbook Worker is successfully executing the PowerShell Script Remotely.

    ```PowerShell
    $FolderContent = Get-ChildItem -Path "C:\Temp" -Recurse
    Add-Content -Value $FolderContent -Path C:\PowerShell\log.log
    ```

19. RDP to the Hybrid Runbook Worker Server and install the AZ PowerShell Module by running the following command in an Administrator launched PowerShell 5.1 Session:
    
    ```PowerShell
    Install-Module Az
    ```

    You will be prompted to install the NuGet provider and trust the repository.  Select the options as specified in the following screenshot.

    ![Alt text](./DemoScreenshots/demo17.jpg?raw=true)

    It will take several minutes after selecting these options (sometimes even 10 minutes or so) for the the Az PowerShell Modules install to begin installing. In the meantime, it may look like the script is hanging.  Be patient, they'll eventually begin and complete installation.  

20. Execute the Runbook against the Hybrid Runbook Worker.
    
    ![Alt text](./DemoScreenshots/demo18.jpg?raw=true)

    ![Alt text](./DemoScreenshots/demo19.jpg?raw=true)

21. Verify results by ensuring the Runbook Worker shows as Completed 
    
    ![Alt text](./DemoScreenshots/demo20.jpg?raw=true)

22. RDP onto the Remote Server to verify the log file has been generated indicating the Hybrid Runbook Worker successfully executed the PowerShell Script remotely.

    ![Alt text](./DemoScreenshots/demo21.jpg?raw=true)