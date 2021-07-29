param location string = resourceGroup().location
param stage string = 'dev'
param instance string = 'a'
param tenantId string = subscription().tenantId
param role string = 'func' 
param serverFarmId string 
param appInsightsInstrumentationKey string
param keyVaultName string
param appConfigName string
param appConfigId string
param appConfigEndpoint string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'sa${role}${stage}${instance}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource azureFunction 'Microsoft.Web/sites@2020-12-01' = {
  name: 'af-${role}-${stage}-${instance}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
  properties: {
    serverFarmId: serverFarmId
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsDashboard'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};AccountKey=${listKeys('${storageaccount.id}', '2019-06-01').keys[0].value}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};AccountKey=${listKeys('${storageaccount.id}', '2019-06-01').keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'AzureAppConfigEndpoint'
          value: appConfigEndpoint
        }
      ]
    }
  }
}

resource kvapFunction 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: azureFunction.identity.principalId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

var appConfigDataReaderRoleId = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/516239f1-63e1-4d78-a4de-a74fb236a071'
resource appConfigRoleAssignment 'Microsoft.AppConfiguration/configurationStores/providers/roleAssignments@2018-01-01-preview' = {
  name: '${appConfigName}/Microsoft.Authorization/${guid(uniqueString(appConfigName,azureFunction.name,appConfigDataReaderRoleId))}'
  properties: {
    roleDefinitionId: appConfigDataReaderRoleId
    principalId: azureFunction.identity.principalId
    scope: appConfigId
  }
}
