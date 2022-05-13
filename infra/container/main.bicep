param aciConnectionName string
param containerRegistryName string
param imageName string
param imageVersion string
param logAnalyticsWorkspaceName string
param numberOfContainersToCreate int
param appName string
param environment string
param region string
param location string = resourceGroup().location
param keyVaultName string
param managedIdentityName string
param storageAccountName string
param storageAccountConnectionStringSecretName string
param osType string

module names 'resource-names.bicep' = {
  name: 'resource-names'
  params: {
    appName: appName
    region: region
    env: environment
  }
}

module containerInstanceDeployment 'aci.bicep' = {
  name: 'container-instance-deployment'
  params: {
    containerInstanceName: names.outputs.containerInstanceName
    containerRegistryName: containerRegistryName
    numberOfContainersToCreate: numberOfContainersToCreate
    imageName: imageName
    imageVersion: imageVersion
    keyVaultName: keyVaultName
    location: location
    managedIdentityName: managedIdentityName
    osType: osType
    storageAccountConnectionStringSecretName: storageAccountConnectionStringSecretName
    storageAccountName: storageAccountName
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
