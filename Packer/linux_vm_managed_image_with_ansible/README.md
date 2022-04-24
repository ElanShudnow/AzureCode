# Linux VM Managed Image with Ansible
## Description
Leverage a Packer Script executed on a Linux Server to deploy a Generalized Linux (Ubuntu) Managed Image for future VM deployments leveraging Terraform or manual procedures. Packer will configured the Managed Image to have Nginx installed as well as leverage the Ansible Provisioner to install Ansible Roles defined within the ansible directory.

## Packer AzureRM Version Tested
- 1.9

## Ansible Version Tested (Installed on the same host as Packer)
- ansible [core 2.12.4]
- python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]
- jinja version = 2.10.1

## Files/Directories Involved
- ubuntu.pkr.hcl
- ansible

## Instructions
1. Download ubuntu.pkr.hcl and the ansible directory and its contents

2. Open ubuntu.pkr.hcl and modify variables according to your needs. The following variables exist with a description:

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
   
5. Run packer build ubuntu.pkr.hcl init to execute the Packer script.

    ```Bash 
    packer build ubuntu.pkr.hcl 
    ```

    Verify there are no errors in the initial script execution:

    ![Alt text](./DemoScreenshots/demo2.jpg?raw=true)

6. Verify the Resource Group that is outlined in the above screenshot exists in the Azure Portal.  You will notice that Packer creates a temporary Resource Group trailing with a random identifier.  This is because a temporary Virtual Machine must be built that will execute the Builder section of the code defined in the Packer script.  The Builder section finishes with generalizing the VM with sysprep.  

    ![Alt text](./DemoScreenshots/demo3.jpg?raw=true)

7. As the code runs, you will notice in the output that Ansible begins execution and installs any roles that are defined.

    ![Alt text](./DemoScreenshots/demo4.jpg?raw=true)

8. When Packer completes, you will see one of the last steps it does after creating the Managed Image is to clean up the VM resources. 

    ![Alt text](./DemoScreenshots/demo5.jpg?raw=true)


9.  In the Resource Group you specified in the azure-resource-group variable within your Packer script, you will now see your Managed Image.  You can now deploy new VMs from your Managed Image or leverage Terraform to deploy VMs leveraging the Managed Image.

    ![Alt text](./DemoScreenshots/demo6.jpg?raw=true)

## Ansible Configuration
In most public documentation, it shows how to execute a single Ansible Playbook using Packer.  However, the solution I provide allows you to run multiple roles.  You define a root.yml playbook which executes as many roles (playbooks within the roles) as you have defined within the root.yml file.  We do need to specify the path to which the roles are created.

  ```Bash
  provisioner "ansible" {
    extra_arguments = ["--become"]
    playbook_file   = "./ansible/root.yml"
    roles_path      = "./ansible/roles"
  }
  ```

Taking a good at the root.yml file: if you have multiple Ansible Roles you want to execute, you will simply add additional roles to the root.yml.

  ```Bash
    ---
    - name: Execute Ansible Playbooks
    hosts: default

    roles:
        - git
  ```

Then within the path you've specified in roles_path which is ./ansible/roles, we would add a new folder for each of our Ansible Roles.  For example, our git role we see above, there is a folder under our ansible directory called roles, with the git directory under it, and a tasks folder under that which includes our playbook to install git.

![Alt text](./DemoScreenshots/demo7.jpg?raw=true)

Our code to install git within our main.yml role file is simple:

  ```Bash
    ---
    - name: Install Git package
    apt: 
        name=git
        state=present
  ```