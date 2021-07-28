targetScope = 'subscription'

param location string = deployment().location
param stage string = 'dev'
param instance string = 'a'
param tenantId string = subscription().tenantId

resource apcoResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01'= {
  name: 'rg-apco-${stage}-${instance}'
  location: location
}

module kvModule 'keyvault.bicep' = {
  scope: apcoResourceGroup
  name: 'kvDeploy'
  params: {
    tenantId: tenantId
    location: location
    stage: stage
    instance: instance
  }
}

module acModule 'appconfiguration.bicep' = {
  scope: apcoResourceGroup
  name: 'acDeploy'
  params: {
    tenantId: tenantId
    location: location
    stage: stage
    instance: instance
    keyVault: kvModule.outputs.keyVaultName
  }
}

module aiModule 'applicationInsights.bicep' = {
  scope: apcoResourceGroup
  name: 'aiDeploy'
  params: {
    tenantId: tenantId
    location: location
    stage: stage
    instance: instance
  }
}

module sfModule 'serverFarm.bicep' = {
  scope: apcoResourceGroup
  name: 'sfDeploy'
  params: {
    tenantId: tenantId
    location: location
    stage: stage
    instance: instance
  }
}

module afTestModule 'azureFunction.bicep' = {
  scope: apcoResourceGroup
  name: 'afTestDeploy'
  params: {
    tenantId: tenantId
    location: location
    stage: stage
    instance: instance
    serverFarmId: sfModule.outputs.serverFarmId
    appInsightsInstrumentationKey: aiModule.outputs.appInsightsInstrumentationKey
    keyVaultName: kvModule.outputs.keyVaultName
    appConfigName: acModule.outputs.AppConfigName
    appConfigId: acModule.outputs.AppConfigId
    appConfigEndpoint: acModule.outputs.AppConfigEndpoint
  }
}
