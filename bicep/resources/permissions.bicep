param tenantId string = subscription().tenantId
param keyVaultName string
param appConfigName string
param appConfigId string
param appConfigPrincipal string
param azureFunctionName string
param adminUser string

resource kvapFunction 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: appConfigPrincipal
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
  name: '${appConfigName}/Microsoft.Authorization/${guid(uniqueString(appConfigName,azureFunctionName,appConfigDataReaderRoleId))}'
  properties: {
    roleDefinitionId: appConfigDataReaderRoleId
    principalId: appConfigPrincipal
    scope: appConfigId
  }
}

resource appConfigRoleAssignmentAdmin 'Microsoft.AppConfiguration/configurationStores/providers/roleAssignments@2018-01-01-preview' = {
  name: '${appConfigName}/Microsoft.Authorization/${guid(uniqueString(appConfigName,adminUser,appConfigDataReaderRoleId))}'
  properties: {
    roleDefinitionId: appConfigDataReaderRoleId
    principalId: adminUser
    scope: appConfigId
  }
}
