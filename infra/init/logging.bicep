param logAnalyticsWorkspaceName string
param location string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
}

output logAnalyticsWorkspaceName string = logAnalytics.name
