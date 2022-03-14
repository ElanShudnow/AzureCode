# Windows VM Managed Image
## Description
Leverage a Packer Script executed on a Linux Server to deploy a Generalized Windows Server 2022 Managed Image for future VM deployments leveraging Terraform or manual procedures. Packer will configured the Managed Image to have IIS installed.

## Packer AzureRM Version Tested
- 1.9

## Files Involved
- windows.pkr.hcl

## Instructions
1. Download windows.pkr.hcl

2. Open windows.pkr.hcl and modify variables according to your needs. The following variables exist with a description:

    | Variable | Description |
    | --------------- | --------------- |
    | azure-region | Azure Region in which the Managed Image will be created. |
    | azure-resource-group | The Azure Resource Group in which the Managed Image will be created. |
    | azure-vm-size | The Virtual Machine SKU Size that Packer will use when creating a Temporary VM to build your Managed Image. |
    | azure_client_id | The client AppID of the Azure Service Principal to use in order for Packer to authenticate to Azure. |
    | azure_client_secret | The client secret of the Azure Service Principal to use in order for Packer to authenticate to Azure. | 
    | azure_subscription_id | The Subscription ID that contains the Azure Service Principal to use in order for Packer to authenticate to Azure. |
    | azure_tenant_id | The Tenant ID that contains the Azure Service Principal to use in order for Packer to authenticate to Azure. |
   
3. Create a Service Principal for Packer to use when deploying resources.  We will leverage the Contributor Role for our Service Principal. 
   
    ```Bash
    az ad sp create-for-rbac --name="IAC" --role="Contributor" --scopes="/subscriptions/SubscriptionID"
    ```

    After running the command in Azure CLI, please record the following values:

    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)

4. The following Environmental Variables are set based on the JSON response information provided in the az ad sp command above. Having these Environmental Variables set allows Packer to know how to authenticate to Azure.

    ```Bash
    export ARM_SUBSCRIPTION_ID=SubscriptionID
    export ARM_CLIENT_ID=appID
    export ARM_CLIENT_SECRET=password
    export ARM_TENANT_ID=tenant
    ```
   
5. Run packer build windows.pkr.hcl init to execute the Packer script.

    ```Bash 
    packer build windows.pkr.hcl 
    ```

    Verify there are no errors in the initial script execution:

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

6. Verify the Resource Group that is outlined in the above screenshot exists in the Azure Portal.  You will notice that Packer creates a temporary Resource Group trailing with a random identifier.  This is because a temporary Virtual Machine must be built that will execute the Builder section of the code defined in the Packer script.  The Builder section finishes with generalizing the VM with sysprep.  

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

7. When Packer completes, you will see one of the last steps it does after creating the Managed Image is to clean up the VM resources. 

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

    However, it mentions it fails to clean up the OS Disk.  If you give it several minutes, you'll notice Packer does successfully clean up all VM resources and automatically deletes the temporary Resource Group.

8. In the Resource Group you specified in the azure-resource-group variable within your Packer script, you will now see your Managed Image.  You can now deploy new VMs from your Managed Image or leverage Terraform to deploy VMs leveraging the Managed Image.

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)