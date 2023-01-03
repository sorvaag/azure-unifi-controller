# Unifi Controller hosted on Azure
This repo contains Bicep code to deploy a Unifi Network Controller virtual machine running in Azure with a SSL certificate.

The hard work was done by [Glenn Rietveld](https://glennr.nl/) with his [Network Application Scripts](https://glennr.nl/s/unifi-network-controller|Unifi) and [Unifi Lets Encrypt Certificates](https://glennr.nl/s/unifi-lets-encrypt). 

This repo is about the Infrastructure as Code using Bicep to make the deployment of the Unifi controller easy on Azure.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Feusdeploymentresources.blob.core.windows.net%2Farm-templates%2Fdeploy-unifi-controller.json)

## Accessing the Unifi Controller on Azure
Once you have deployed the Unifi Controller, you can access and configure it at: https://DNSPrefix.region.cloudapp.azure.com:8443/ 
The simplest way is to browse to the virtual machine in the Azure Portal, copy the host name, and append :8443 to access the controller. You can configure your new controller from here.

## Parameters
To make the code as flexible as possible, it requires a number of parameters to configure the application. The table below includes a description of these parameters.

|Parameter|Description|
|---------|-----------|
| environmentName | The name of the Environment (Prod/Test/Dev). The default is set to prod. |
| controllerName | This is used as the main part of the resource naming. The default is set to unifi-controller. |
| location | The Azure region that you would like to deploy the controller into. The default is set to westus3. |
| dnsPrefix | This is the subdomain that is used to access the Unifi controller and to configure the Let's Encrypt certificate. You can also leave this blank and some random characters will be used. |
| sslExpiryNotificationEmail | This email address is used to deliver notifications of SSL certificates that are about to expire. |
| controllerUsername | This is the username / account that is provisioned on the Ubuntu vm. The default username is set to ubuntu |
| controllerVmSize | The Azure VM sku for the controller VM. The default is set to Standard_B1ms |
| vNetAddressSpace | The RFC1918 address space that is allocated to the virtual network. The default value is set to 172.16.0.0/24 |
| subnetAddressSpace | The RFC1918 address space that is allocated to the subnet. The default value is set to 172.16.0.0/28 |
| restrictedSourceIPaddress | This can be used to lock down the controller to a specific IPv4 address. By default, all internet sources are permitted with a * |
| depplymentResourcesGroup | The name of the resource group that contains deployment resources, including the SSH Key'
| sshPublicKeyName | The name of the SSH public key stored in Azure that is used for authentication on the controller VM. By default, password based authentication is disabled. |

## Parameter File
You can create a parameter file to make the deployment easier, and more repeatable. The basic structure of the main.parameters.json file looks something like this:

```
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "dnsPrefix": {
      "value": ""
    },
    "controllerUsername": {
      "value": ""
    },
    "controllerVmSize": {
      "value": "Standard_B1ms"
    },
    "sshPublicKey": {
      "value": ""
    },
    "restrictedSourceIPaddress": {
      "value": "100.100.5.1"
    },
    "controllerName": {
      "value": "unifi-controller"
    },
    "location": {
      "value": "southafricanorth"
    },
    "vNetAddressSpace": {
      "value": "172.16.0.0/24"
    },
    "subnetAddressSpace": {
      "value": "172.16.0.0/28"
    },
    "environmentName": {
      "value": "prod"
    },
    "sslExpiryNotificationEmail": {
      "value": ""
    }
  }
}
```

## Deployment
The simplest way to get started it so clone this repo and open in Visual Studio Code.
You will need a few additional bits of software installed, including:
1. [Visual Studio Code and Bicep extension](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#vs-code-and-bicep-extension)
2. [Azure Cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)
3. [Bicep Cli](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

## Deployed Azure Resources
The table below is a high level summary of the resources deployed, and the naming conventions that have been used. 

|Name|Type|Location|
|----|----|--------|
| vnet-unifi-controller-prod-southafricanorth | Virtual network | South Africa North |
| nic-unifi-controller-prod-southafricanorth | Network Interface | South Africa North |
| pip-unifi-controller-prod-southafricanorth | Public IP address | South Africa North |
| asg-unifi-controller-prod-southafricanorth | Application security group | South Africa North |
| nsg-unifi-controller-prod-southafricanorth | Network security group | South Africa North |
| osd-unifi-controller-prod-southafricanorth | Disk | South Africa North |
| vm-unifi-controller-prod-southafricanorth  | Virtual machine | South Africa North |


## Bicep Assistance
If you need some assistance getting started with Bicep, [Microsoft Learn has great content covering Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/learn-bicep).
