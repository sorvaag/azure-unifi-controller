targetScope = 'resourceGroup'

//------------//
// Parameters //
//------------//
param controllerName string
param controllerUsername string
param environmentName string
param sshPublicKey string
param location string
param dnsPrefix string
param vmSize string
param subnetId string
param nsgId string
param asgId string
param sslExpiryNotificationEmail string


// Resources //
//-----------//

// Public IP //
resource pip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'pip-${controllerName}-${environmentName}-${location}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    deleteOption: 'Delete'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsPrefix
    }
  }
}

// Network Interface //
resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'nic-${controllerName}-${environmentName}-${location}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ip-config-${controllerName}-${environmentName}-${location}'
        properties: {
          applicationSecurityGroups: [ 
            {
              id: asgId
            }
          ]
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

// Create the Custom Data File
var customData = format('''
#cloud-config
packages_update: true
packages_upgrade: true
packages:
  - ca-certificates
  - wget
runcmd:
  - rm unifi-latest.sh &> /dev/null; wget https://get.glennr.nl/unifi/install/install_latest/unifi-latest.sh && bash unifi-latest.sh --skip --fqdn {0} --server-ip {1} --email {2}
  - rm unifi-easy-encrypt.sh &> /dev/null; wget https://get.glennr.nl/unifi/extra/unifi-easy-encrypt.sh && bash unifi-easy-encrypt.sh --skip --fqdn {0} --server-ip {1} --email {2}
''', pip.properties.dnsSettings.fqdn, pip.properties.ipAddress, sslExpiryNotificationEmail)


// Virtual Machine //
resource controllerVm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: 'vm-${controllerName}-${environmentName}-${location}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        name: 'osd-${controllerName}-${environmentName}-${location}'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        diskSizeGB: 30
      }
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            primary: true
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: 'vm${controllerName}${environmentName}${location}'
      adminUsername: controllerUsername
      customData: base64(customData)
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${controllerUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}


//---------//
// Outputs //
//---------//
output dnsHostName string = pip.properties.dnsSettings.fqdn
output publicIpAddress string = pip.properties.ipAddress
