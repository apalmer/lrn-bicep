param location string = resourceGroup().location
param stage string = 'dev'
param instance string = 'a'
param tenantId string = subscription().tenantId

param keyVault string = 'kv-apco-${stage}-${instance}'

resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: 'ac-apco-${stage}-${instance}'
  location: location
  sku: {
    name: 'standard' 
  }
}

resource acTestConfigValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: appConfiguration
  name: 'test:apco:configvalue'
  properties: {
    value: 'this is a config value'
    contentType: 'application/text'
  }
}

resource acTestSecret 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: appConfiguration
  name: 'test:apco:keyvaultsecret'
  properties: {
    value: 'https://${keyVault}.vault.azure.net/secrets/Test-APCO-Secret'
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}
