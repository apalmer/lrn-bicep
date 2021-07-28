@description('Azure service name to grant access')
param azureServiceName string = 'af-func-dev-a'

@description('App configuration name')
param appConfigurationName string = 'ac-apco-dev-a'

var appConfigurationDataReaderRoleId = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/516239f1-63e1-4d78-a4de-a74fb236a071'
var azureServicePrincipalId = resourceId('Microsoft.Web/sites', azureServiceName)
var appConfigurationId = resourceId('Microsoft.AppConfiguration/configurationStores', appConfigurationName)

resource appConfigurationName_Microsoft_Authorization_azureServiceName 'Microsoft.AppConfiguration/configurationStores/providers/roleAssignments@2018-01-01-preview' = {
  name: '${appConfigurationName}/Microsoft.Authorization/${guid(uniqueString(azureServiceName))}'
  properties: {
    roleDefinitionId: appConfigurationDataReaderRoleId
    principalId: reference(azureServicePrincipalId, '2018-11-01', 'Full').identity.principalId
    scope: appConfigurationId
  }
}