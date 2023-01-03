targetScope = 'subscription'

//------------//
// Parameters //
//------------//
@minLength(3)
@maxLength(20)
@description('Enter the name of the deployment to be used. Defaults to unifi-controller.')
param controllerName string = 'unifi-controller'

@description('Enter the name of the Azure Region to be used. Defaults to westus3. There should be no spaces in the region name.')
param location string = 'westus3'

@description('The username for the Unifi Controller VM. The default is ubuntu')
param controllerUsername string = 'ubuntu'

@description('The email address to send certificate expiry notifications to')
param sslExpiryNotificationEmail string

@description('The size / SKU of the Unifi Controller VM. The default is Standard B1ms')
param controllerVmSize string = 'Standard_B1ms'

@description('Enter the address space to be used for the vNet. Defaults to 172.16.0.0/24.')
param vNetAddressSpace string = '172.16.0.0/24'

@description('Enter the address space to be used for the Subnet. Defaults to 172.16.0.0/28.')
param subnetAddressSpace string = '172.16.0.0/28'

@description('Enter the name of the deployment environment. Defaults to prod.')
param environmentName string = 'prod'

@description('Enter your source IPv4 address here if you you would like to lock down access to the Unifi controller. Default is allow all using *.')
param restrictedSourceIPaddress string = '*'

@secure()
@description('Enter the SSH Public Key used to secure and access the Linux controller VM')
param sshPublicKey string


//-----------//
// Resources //
//-----------//

// Resource Group //
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-${controllerName}-${environmentName}-${location}'
  location: location
}

// Networking Resources //
module networking './network.bicep' = {
  name: 'network-deployment'
  scope: rg
  params: {
    controllerName: controllerName
    environmentName: environmentName
    location: rg.location
    vNetAddressSpace: vNetAddressSpace
    subnetAddressSpace: subnetAddressSpace
    restrictedSourceIPaddress: restrictedSourceIPaddress
  }
}

module unifiController 'unifi-controller.bicep' = {
  name: 'compute-deployment'
  scope: rg
  params: {
    controllerName: controllerName
    controllerUsername: controllerUsername
    environmentName: environmentName
    dnsPrefix: uniqueString(rg.id)
    location: rg.location
    subnetId: networking.outputs.subnetId
    nsgId: networking.outputs.nsgId
    asgId: networking.outputs.asgId
    vmSize: controllerVmSize
    sshPublicKey: sshPublicKey
    sslExpiryNotificationEmail: sslExpiryNotificationEmail
  }
}
