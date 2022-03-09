# Server Arrays to Target
$servers = [System.Collections.ArrayList]@()
$servers.Add('vmdc01') | Out-Null

# Username of the Service Account for Hybrid Runbook Worker to use when executing remote code against servers specified above
$userName = "Shudnow\eshudnow"

# Vault Name
$KeyVaultName = "HRWRemoteCodeExecutionKV"

# Key Vault Secret Name
$KeyVaultSecretName = "HRWRemoteCodeExecutionKVSecret"

### Do not modify below this line (except line 70 to specify the script you will remotely execute)

# Generate the password used for this certificate
Add-Type -AssemblyName System.Web -ErrorAction SilentlyContinue | Out-Null
$Password = [System.Web.Security.Membership]::GeneratePassword(25, 10)

# Get the management certificate that will be used to make calls into Azure Service Management resources
$RunAsCert = Get-AutomationCertificate -Name "AzureRunAsCertificate"

# location to store temporary certificate in the Automation service host
$CertPath = Join-Path $env:temp  "AzureRunAsCertificate.pfx"

# Save the certificate
$Cert = $RunAsCert.Export("pfx",$Password)
Set-Content -Value $Cert -Path $CertPath -Force -Encoding Byte | Write-Verbose

Write-Output ("Importing Run-As certificate into $env:computername local machine root store from " + $CertPath)
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
Import-PfxCertificate -FilePath $CertPath -CertStoreLocation Cert:\LocalMachine\My -Password $SecurePassword | Write-Verbose

Remove-Item -Path $CertPath -ErrorAction SilentlyContinue | Out-Null

# Test to see if authentication to Azure Resource Manager is working
$RunAsConnection = Get-AutomationConnection -Name "AzureRunAsConnection"

Write-Output "`r`nLogging into Azure using Run-As Account"
Connect-AzAccount `
    -ServicePrincipal `
    -Tenant $RunAsConnection.TenantId `
    -ApplicationId $RunAsConnection.ApplicationId `
    -CertificateThumbprint $RunAsConnection.CertificateThumbprint | Write-Verbose

Set-AzContext -Subscription $RunAsConnection.SubscriptionID | Write-Verbose

Write-Output "`r`nObtaining Password for Service Account"
$Password = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultSecretName -AsPlainText
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Take Password, Specify Username, and create a Credential Object
$myPsCred = New-Object System.Management.Automation.PSCredential ($userName,$securePassword)

Write-Output "`r`nUsername specified as $userName"

# Execute code on each server in Server Array
# This requires WSMAN/Remote PowerShell to be open on Destination Server for Test-WSMan.
foreach ($server in $servers)
{
	Write-Output "`r`nBeginning Remote Script Execution for the following server: $Server"
    Write-Output " "
	$WSManTest = Test-WSMan -ComputerName $server
   
    if ($WSManTest)
	{
        Write-Output($server + " test for Remote PowerShell was successful.  Executing Remote Script.")
		#Invoke-Command -Credential $myPsCred -FilePath $ScriptPath -ComputerName $Server
        #Invoke-Command -Credential $myPsCred -Cn $server {'powershell.exe -File C:\PowerShell\Script.ps1' }
		$s = New-PSSession -ComputerName $Server -Credential $myPsCred
		Invoke-Command -Session $s -Command {C:\PowerShell\Script.ps1}
    }
    else
	{
        Write-Output($server + " test for Remote PowerShell was unsuccessful. Terminating Remote Script Execution.")
    }
}
