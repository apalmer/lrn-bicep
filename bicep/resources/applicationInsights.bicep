param location string = resourceGroup().location
param stage string = 'dev'
param instance string = 'a'

resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'ai-${stage}-${instance}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output appInsightsInstrumentationKey string = appInsightsComponents.properties.InstrumentationKey
