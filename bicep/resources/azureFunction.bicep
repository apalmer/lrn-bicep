param location string = resourceGroup().location
param stage string = 'dev'
param instance string = 'a'
param role string = 'func' 
param serverFarmId string 
param appInsightsInstrumentationKey string
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

output azureFunctionName string = azureFunction.name
output azureFunctionPrincipal string = azureFunction.identity.principalId
