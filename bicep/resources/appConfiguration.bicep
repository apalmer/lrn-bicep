param location string = resourceGroup().location
param stage string = 'dev'
param instance string = 'a'
param keyVaultSecretUri string
param now string = utcNow()

resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: 'ac-gs-${stage}-${instance}'
  location: location
  sku: {
    name: 'standard' 
  }
}

resource acTestConfigValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: appConfiguration
  name: 'gs:configvalue'
  properties: {
    value: 'this is a config value from appConfig'
    contentType: 'application/text'
  }
}

resource acTestSentinel 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: appConfiguration
  name: 'gs:sentinel'
  properties: {
    value: now
    contentType: 'application/text'
  }
}

var keyVaultRef = {
  uri: keyVaultSecretUri
}
resource acTestSecret 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: appConfiguration
  name: 'gs:keyvaultref'
  properties: {
    value: string(keyVaultRef)
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

var featureFlagId = 'gs-feature-flag'
var featureFlag = {
  id: featureFlagId
  description: 'Feature Flag Alpha'
  enabled: true
  conditions: {
		client_filters: []
	}
}
resource acTestFeatureFlag 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: appConfiguration
  name: '.appconfig.featureflag~2F${featureFlagId}$'
  properties: {
    value: string(featureFlag)
    contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
  }
}

output AppConfigName string = appConfiguration.name
output AppConfigId string = appConfiguration.id
output AppConfigEndpoint string = appConfiguration.properties.endpoint
