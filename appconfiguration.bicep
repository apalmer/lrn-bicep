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

var adminUser = '1a9ce792-c5d9-4740-87c1-49e6acecf490'
var appConfigDataReaderRoleId = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/516239f1-63e1-4d78-a4de-a74fb236a071'
resource appConfigRoleAssignment 'Microsoft.AppConfiguration/configurationStores/providers/roleAssignments@2018-01-01-preview' = {
  name: '${appConfiguration.name}/Microsoft.Authorization/${guid(uniqueString(appConfiguration.name,adminUser,appConfigDataReaderRoleId))}'
  properties: {
    roleDefinitionId: appConfigDataReaderRoleId
    principalId: adminUser
    scope: appConfiguration.id
  }
}

output AppConfigName string = appConfiguration.name
output AppConfigId string = appConfiguration.id
output AppConfigEndpoint string = appConfiguration.properties.endpoint
