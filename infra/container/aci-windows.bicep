param containerRegistryName string
param imageName string
param imageVersion string
param numberOfContainersToCreate int
param storageAccountName string
param location string
param containerInstanceName string
param managedIdentityName string
param osType string
@secure()
param storageAccountConnectionStringSecret string
param logAnalyticsWorkspaceName string
param aciConnectionName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' existing = {
  name: managedIdentityName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: containerInstanceName
  location: location
  properties: {
    containers: [for i in range(0, numberOfContainersToCreate): {
      name: '${imageName}${i}'
      properties: {
        image: '${containerRegistry.name}.azurecr.io/${imageName}:${imageVersion}'
        environmentVariables: [
          {
            name: 'AZURE_STORAGE_CONNECTION_STRING'
            secureValue: storageAccountConnectionStringSecret
          }
        ]
        resources: {
          requests: {
            cpu: 1
            memoryInGB: 1
          }
        }
      }
    }]
    osType: osType
    restartPolicy: 'Never'
    imageRegistryCredentials: [
      {
        server: '${containerRegistry.name}.azurecr.io'
        username: listCredentials(containerRegistry.id, containerRegistry.apiVersion).username
        password: listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords[0].value
      }
    ]
    diagnostics: {
      logAnalytics: {
        workspaceId: reference(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).customerId
        workspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
      }
    }
  }
}

resource aciConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: aciConnectionName
  location: location
  properties: {
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${uriComponent(location)}/managedApis/${aciConnectionName}'
    }
    displayName: aciConnectionName
    parameterValues: {}
  }
}

output containerInstanceName string = containerInstance.name
