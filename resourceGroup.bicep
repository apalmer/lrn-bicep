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
