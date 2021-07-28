targetScope = 'subscription'

param location string = deployment().location
param stage string = 'dev'
param instance string = 'a'
param tenantId string = subscription().tenantId
param adminUser string = '1a9ce792-c5d9-4740-87c1-49e6acecf490'

resource gsResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01'= {
  name: 'rg-gs-${stage}-${instance}'
  location: location
}

module kvModule 'resources/keyvault.bicep' = {
  scope: gsResourceGroup
  name: 'kvDeploy'
  params: {
    tenantId: tenantId
    location: location
    stage: stage
    instance: instance
    adminUser: adminUser
  }
}

module acModule 'resources/appconfiguration.bicep' = {
  scope: gsResourceGroup
  name: 'acDeploy'
  params: {
    tenantId: tenantId
    location: location
    stage: stage
    instance: instance
    keyVault: kvModule.outputs.keyVaultName
    adminUser: adminUser
  }
}

module aiModule 'resources/applicationInsights.bicep' = {
  scope: gsResourceGroup
  name: 'aiDeploy'
  params: {
    tenantId: tenantId
    location: location
    stage: stage
    instance: instance
  }
}

module sfModule 'resources/serverFarm.bicep' = {
  scope: gsResourceGroup
  name: 'sfDeploy'
  params: {
    tenantId: tenantId
    location: location
    stage: stage
    instance: instance
  }
}

module afTestModule 'resources/azureFunction.bicep' = {
  scope: gsResourceGroup
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
