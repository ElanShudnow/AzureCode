# Linux VM Managed Image
## Description
This Terraform Script executed on a Linux Server will deploy a single Windows Virtual Machine using a Managed Image.

## Terraform AzureRM Version Tested
- \~> 2.26 (Not tested in the new AzureRM 3.x Provider)

## Files Involved
- main.tf
- variables.tf
- terraform.tfvars

## Pre-Requisites
- You must have a Managed Image already created. If you do not have a Windows Managed Image created, feel free to use the following Packer Script which deploys an Ubuntu 18.04-LTS Managed Image: [Packer Windows_VM_Managed_Image](https://github.com/ElanShudnow/AzurePS/tree/main/Packer/windows_vm_managed_image)

## Instructions
1. Download main.tf, variables.tf, and terraform.tfvars and store them all in a new folder.

2. Open variables.tf and modify variables according to your needs. The following variables exist with a description:

    | Variable | Description |
    | --------------- | --------------- |
    | location | Azure Region in which your Virtual Machine and corresponding resources will be deployed. No default value is specified. In terraform.tfvars, make sure to specify the Azure Region. |
    | admin_username | The Administrator username that will be configured for your Windows Virtual Machine. |
    | admin_password | The Administrator password that will be configured for your Windows Virtual Machine. This is left blank for obvious reasons and therefore, when leveraging Terraform command line, you will be prompted to specify the password. |
    | prefix | The prefix that should be used for the resource names that get provisioned. |
    | tags | The tags that should be specified for resources that get provisioned. | 
    | inbound_rules | An array of NSG rules that should be added for the Virtual Machine deployed. |
   
2. Create a Service Principal for Terraform to use when deploying resources.  We will leverage the Contributor Role for our Service Principal. 

    **Note:** If you have already created a Service Principal while leveraging other Terraform Scripts or Packer, you can leverage the same Service Principal. 
   
    ```Bash
    az ad sp create-for-rbac --name="IAC" --role="Contributor" --scopes="/subscriptions/SubscriptionID"
    ```

    After running the command in Azure CLI, please record the following values:
    
    ![Alt text](./DemoScreenshots/demo1.jpg?raw=true)


3. The following Environmental Variables are set based on the JSON response information provided in the az ad sp command above. Having these Environmental Variables set allows Terraform to know how to authenticate to Azure.

    ```Bash
    export ARM_SUBSCRIPTION_ID=SubscriptionID
    export ARM_CLIENT_ID=appID
    export ARM_CLIENT_SECRET=password
    export ARM_TENANT_ID=tenant
    ```
   
4. Run terraform init to initialize your Terraform Script.

    ```Bash 
    terraform init 
    ```

    Verify there are no errors in the initialization process:

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

5. Run terraform plan which will leverage the Service Principal, connect to Azure, and determine what Terraform needs to do in order to create the resources based on Terraform's state file.  It will also see that the admin_password variable is blank and prompt to specify the value admin_password. 

    As this is a new deployment, as long as conflicting resources do not exist in the Azure Subscription, Terraform will inform you that new resources will be created.  

    ```Bash 
    terraform plan 
    ```   

    The following only provides a subset of the response back showing a preview of resources that will be created:

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

6. Run terraform apply which will then create the resources.

    ```Bash 
    terraform apply 
    ```

    As can be seen, Terraform has created the resources and has Outputed the Public IP as specified in main.tf.

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

7. In the Azure Portal, verify the Resource Group has been created as well as the Virtual Machine and its corresponding resources.

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)
