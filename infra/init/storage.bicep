param managedIdentityName string
param storageAccountName string
param location string
param logAnalyticsWorkspaceName string
param storageAccountContainerName string
param keyVaultName string
param storageAccountConnectionStringSecretName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedIdentityName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${storageAccount.name}/default/${storageAccountContainerName}'
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

resource storageAccountConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: storageAccountConnectionStringSecretName
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
  }
}

resource storageDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: storageAccount
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource storageBlobDiagnosticSettings 'Microsoft.Storage/storageAccounts/blobServices/providers/diagnosticsettings@2017-05-01-preview' = {
  name: '${storageAccount.name}/default/Microsoft.Insights/Logging'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

output storageAccountName string = storageAccount.name
output blobContainerName string = storageAccountContainer.name
