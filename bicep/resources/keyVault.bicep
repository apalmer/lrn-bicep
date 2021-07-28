param location string = resourceGroup().location
param stage string = 'dev'
param instance string = 'a'
param tenantId string = subscription().tenantId

var adminUser = '1a9ce792-c5d9-4740-87c1-49e6acecf490'
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'kv-gs-${stage}-${instance}'
  location: location
  properties: {
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: adminUser  
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
        }
      }
    ]
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}

output keyVaultName string = keyVault.name
