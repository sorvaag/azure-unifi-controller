targetScope = 'resourceGroup'

//------------//
// Parameters //
//------------//
param controllerName string
param location string
param environmentName string
param vNetAddressSpace string
param subnetAddressSpace string
param restrictedSourceIPaddress string


//-----------//
// Resources //
//-----------//

// Application Security group //
resource asg 'Microsoft.Network/applicationSecurityGroups@2022-07-01' = {
  name: 'asg-${controllerName}-${environmentName}-${location}'
  location: location
}

// Network Security Group //
// Reference: https://help.ui.com/hc/en-us/articles/218506997-UniFi-Network-Required-Ports-Reference
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'nsg-${controllerName}-${environmentName}-${location}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'unifi-allow-ssh-admin'
        properties: {
          description: 'Allow SSH to manage the Unifi controller'
          priority: 100
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: restrictedSourceIPaddress
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '22'
          access: 'Allow'
        }
      }
      {
        name: 'unifi-allow-http'
        properties: {
          description: 'Used to validate the SSL certificate'
          priority: 110
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '80'
          access: 'Allow'
        }
      }
      {
        name: 'unifi-allow-stun'
        properties: {
          description: 'Used for STUN traffic to the Unifi controller'
          priority: 120
          direction: 'Inbound'
          protocol: 'Udp'
          sourceAddressPrefix: restrictedSourceIPaddress
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '3478'
          access: 'Allow'
        }
      }
      {
        name: 'unifi-allow-mobile-speed-test'
        properties: {
          description: 'Used to publish the Mobile Speed Test'
          priority: 130
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: restrictedSourceIPaddress
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '6789'
          access: 'Allow'
        }
      }
      {
        name: 'unifi-allow-device-communication'
        properties: {
          description: 'Used for Unifi device and controller communication'
          priority: 140
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: restrictedSourceIPaddress
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '8080'
          access: 'Allow'
        }
      }
      {
        name: 'unifi-allow-web-console'
        properties: {
          description: 'Used for Unifi controller GUI/API as seen in a web browser.'
          priority: 150
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: restrictedSourceIPaddress
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '8443'
          access: 'Allow'
        }
      }
      {
        name: 'unifi-allow-https-redirection'
        properties: {
          description: 'Used for Unifi HTTPS portal redirection'
          priority: 160
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: restrictedSourceIPaddress
          sourcePortRange: '*'
          destinationApplicationSecurityGroups: [
            {
              id: asg.id
            }
          ]
          destinationPortRange: '8843'
          access: 'Allow'
        }
      }
      {
        name: 'unifi-deny-all'
        properties: {
          description: 'Used to deny any additional inbound traffic'
          priority: 200
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          protocol: '*'
          access: 'Deny'
        }
      }
    ]
  }
}

// Virtual Network //
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'vnet-${controllerName}-${environmentName}-${location}'
  location: location
  
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'snet-${controllerName}-${environmentName}-${location}'
        properties: {
          addressPrefix: subnetAddressSpace
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
  resource subnet 'subnets' existing = {
    name: 'snet-${controllerName}-${environmentName}-${location}'
  }
}


//---------//
// Outputs //
//---------//
output asgId string = asg.id
output nsgId string = nsg.id
output subnetId string = virtualNetwork::subnet.id
