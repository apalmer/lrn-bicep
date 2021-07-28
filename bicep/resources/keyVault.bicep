param location string = resourceGroup().location
param stage string = 'dev'
param instance string = 'a'
param tenantId string = subscription().tenantId
param adminUser = ''

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
