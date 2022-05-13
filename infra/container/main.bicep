param appName string
param containerRegistryName string
param environment string
param linuxContainerSettings object
param windowsContainerSettings object
param keyVaultName string
param location string = resourceGroup().location
param logAnalyticsWorkspaceName string
param managedIdentityName string
param numberOfContainersToCreate int
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

module linuxContainerInstanceDeployment 'aci.bicep' = {
  name: 'linux-container-instance-deployment'
  params: {
    containerInstanceName: names.outputs.linuxContainerInstanceName
    containerRegistryName: containerRegistryName
    numberOfContainersToCreate: numberOfContainersToCreate
    imageName: linuxContainerSettings.imageName
    imageVersion: linuxContainerSettings.imageVersion
    location: location
    managedIdentityName: managedIdentityName
    osType: linuxContainerSettings.osType
    storageAccountName: storageAccountName
    storageAccountConnectionStringSecret: keyVault.getSecret(storageAccountConnectionStringSecretName)
    aciConnectionName: names.outputs.aciConnectionName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

module windowsContainerInstanceDeployment 'aci.bicep' = {
  name: 'windows-container-instance-deployment'
  params: {
    containerInstanceName: names.outputs.windowsContainerInstanceName
    containerRegistryName: containerRegistryName
    numberOfContainersToCreate: numberOfContainersToCreate
    imageName: windowsContainerSettings.imageName
    imageVersion: windowsContainerSettings.imageVersion
    location: location
    managedIdentityName: managedIdentityName
    osType: windowsContainerSettings.osType
    storageAccountName: storageAccountName
    storageAccountConnectionStringSecret: keyVault.getSecret(storageAccountConnectionStringSecretName)
    aciConnectionName: names.outputs.aciConnectionName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

module linuxLogicAppDeployment 'logic.bicep' = {
  name: 'linux-logic-app-deployment'
  params: {
    containerInstanceName: linuxContainerInstanceDeployment.outputs.containerInstanceName
    logicAppName: names.outputs.linuxLogicAppName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    aciConnectionName: names.outputs.aciConnectionName
    location: location
  }
}

module windowsLogicAppDeployment 'logic.bicep' = {
  name: 'windows-logic-app-deployment'
  params: {
    containerInstanceName: windowsContainerInstanceDeployment.outputs.containerInstanceName
    logicAppName: names.outputs.windowsLogicAppName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    aciConnectionName: names.outputs.aciConnectionName
    location: location
  }
}
