param appName string
param region string
param env string

output containerInstanceName string = 'ci-${appName}-${region}-${env}'
output logicAppName string = 'logic-${appName}-${region}-${env}'
