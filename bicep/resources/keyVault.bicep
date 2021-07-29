param location string = resourceGroup().location
param stage string = 'dev'
param instance string = 'a'
param tenantId string = subscription().tenantId
param adminUser string = ''

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

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: '${keyVault.name}/testKeyVaultSecret'
  properties: {
    value: 'keyvault secret'
  }
}

output keyVaultName string = keyVault.name
output keyVaultSecretUri string = keyVaultSecret.properties.secretUri
