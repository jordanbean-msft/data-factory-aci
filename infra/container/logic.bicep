param aciConnectionName string
param containerInstanceName string
param logAnalyticsWorkspaceName string
param logicAppName string
param location string

resource aciConnection 'Microsoft.Web/connections@2016-06-01' existing = {
  name: aciConnectionName
}

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-10-01' existing = {
  name: containerInstanceName
}

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'Recurrence': {
          'recurrence': {
            'frequency': 'Day'
            'interval': 1
          }
          'type': 'Recurrence'
        }
      }
      actions: {
        'Start_containers_in_a_container_group': {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'aci\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '${containerInstance.id}/start'
            queries: {
              'x-ms-api-version': '2019-12-01'
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          aci: {
            connectionId: aciConnection.id
            connectionName: 'aci'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${uriComponent(location)}/managedApis/aci'
          }
        }
      }
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: logicApp
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'WorkflowRuntime'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output logicAppName string = logicApp.name
