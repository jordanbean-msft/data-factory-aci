param appName string
param environment string
param region string
param location string = resourceGroup().location

module names 'resource-names.bicep' = {
  name: 'resource-names'
  params: {
    appName: appName
    region: region
    env: environment
  }
}

module managedIdentityDeployment 'managed-identities.bicep' = {
  name: 'managed-identity-deployment'
  params: {
    location: location
    managedIdentityName: names.outputs.managedIdentityName
  }
}

module loggingDeployment 'logging.bicep' = {
  name: 'logging-deployment'
  params: {
    logAnalyticsWorkspaceName: names.outputs.logAnalyticsWorkspaceName
    location: location
  }
}

module keyVaultDeployment 'keyVault.bicep' = {
  name: 'key-vault-deployment'
  params: {
    keyVaultName: names.outputs.keyVaultName
    location: location
    userAssignedManagedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
  }
}

module storageDeployment 'storage.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: names.outputs.storageAccountName
    storageAccountContainerName: names.outputs.storageAccountContainerName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    location: location
    managedIdentityName: managedIdentityDeployment.outputs.managedIdentityName
    keyVaultName: keyVaultDeployment.outputs.keyVaultName
    storageAccountConnectionStringSecretName: names.outputs.storageAccountConnectionStringSecretName
  }
}

module containerRegistryDeployment 'acr.bicep' = {
  name: 'container-registry-deployment'
  params: {
    containerRegistryName: names.outputs.containerRegistryName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    location: location
  }
}
