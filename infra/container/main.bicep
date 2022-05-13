param aciConnectionName string
param appName string
param containerRegistryName string
param environment string
param imageName string
param imageVersion string
param keyVaultName string
param location string = resourceGroup().location
param logAnalyticsWorkspaceName string
param managedIdentityName string
param numberOfContainersToCreate int
param osType string
param region string
param storageAccountConnectionStringSecretName string
param storageAccountName string

module names 'resource-names.bicep' = {
  name: 'resource-names'
  params: {
    appName: appName
    region: region
    env: environment
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
}

module containerInstanceDeployment 'aci.bicep' = {
  name: 'container-instance-deployment'
  params: {
    containerInstanceName: names.outputs.containerInstanceName
    containerRegistryName: containerRegistryName
    numberOfContainersToCreate: numberOfContainersToCreate
    imageName: imageName
    imageVersion: imageVersion
    location: location
    managedIdentityName: managedIdentityName
    osType: osType
    storageAccountName: storageAccountName
    storageAccountConnectionStringSecret: keyVault.getSecret(storageAccountConnectionStringSecretName)
  }
}

module logicAppDeployment 'logic.bicep' = {
  name: 'logic-app-deployment'
  params: {
    containerInstanceName: containerInstanceDeployment.outputs.containerInstanceName
    logicAppName: names.outputs.logicAppName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    aciConnectionName: aciConnectionName
    location: location
  }
}

output containerInstanceName string = containerInstanceDeployment.outputs.containerInstanceName
