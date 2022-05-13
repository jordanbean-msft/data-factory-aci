param appName string
param region string
param env string

output managedIdentityName string = 'mi-${appName}-${region}-${env}'
output logAnalyticsWorkspaceName string = 'la-${appName}-${region}-${env}'
output keyVaultName string = 'kv${appName}${region}${env}'
output containerRegistryName string = toLower('cr${appName}${region}${env}')
output storageAccountName string = toLower('sa${appName}${region}${env}')
output storageAccountContainerName string = 'inputdata'
output storageAccountConnectionStringSecretName string = 'sa${appName}${region}${env}-connection-string'
