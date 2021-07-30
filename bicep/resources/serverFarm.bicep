param location string = resourceGroup().location
param stage string = 'dev'
param instance string = 'a'

resource serverFarm 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'sf-${stage}-${instance}'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
}

output serverFarmId string = serverFarm.id
