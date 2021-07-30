targetScope = 'subscription'

param location string = deployment().location
param stage string = 'dev'
param instance string = 'a'
param tenantId string = subscription().tenantId
param adminUser string = '1a9ce792-c5d9-4740-87c1-49e6acecf490'

resource gsResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-gs-${stage}-${instance}'
  location: location
}

module kvModule 'resources/keyVault.bicep' = {
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
    location: location
    stage: stage
    instance: instance
    keyVaultSecretUri: kvModule.outputs.keyVaultSecretUri
  }
}

module aiModule 'resources/applicationInsights.bicep' = {
  scope: gsResourceGroup
  name: 'aiDeploy'
  params: {
    location: location
    stage: stage
    instance: instance
  }
}

module sfModule 'resources/serverFarm.bicep' = {
  scope: gsResourceGroup
  name: 'sfDeploy'
  params: {
    location: location
    stage: stage
    instance: instance
  }
}

module afTestModule 'resources/azureFunction.bicep' = {
  scope: gsResourceGroup
  name: 'afTestDeploy'
  params: {
    location: location
    stage: stage
    instance: instance
    serverFarmId: sfModule.outputs.serverFarmId
    appInsightsInstrumentationKey: aiModule.outputs.appInsightsInstrumentationKey
    appConfigEndpoint: acModule.outputs.AppConfigEndpoint
  }
}

module permissions 'resources/permissions.bicep' = {
  scope: gsResourceGroup
  name: 'permissionsDeploy'
  params: {
    tenantId: tenantId
    keyVaultName: kvModule.outputs.keyVaultName
    appConfigName: acModule.outputs.AppConfigName
    appConfigId: acModule.outputs.AppConfigId
    appConfigPrincipal: afTestModule.outputs.azureFunctionPrincipal
    azureFunctionName: afTestModule.outputs.azureFunctionName
    adminUser: adminUser
  }
}
