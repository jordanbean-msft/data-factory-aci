param keyVaultName string
param location string
param userAssignedManagedIdentityName string

resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: userAssignedManagedIdentityName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false
    enabledForTemplateDeployment: true
    accessPolicies: [
      {
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
        objectId: userAssignedManagedIdentity.properties.principalId
        tenantId: subscription().tenantId
      }
    ]
  }
}

output keyVaultName string = keyVaultName
