param appName string
param region string
param env string

output linuxContainerInstanceName string = toLower('ci-linux-${appName}-${region}-${env}')
output windowsContainerInstanceName string = toLower('ci-windows-${appName}-${region}-${env}')
output linuxLogicAppName string = 'logic-linux-${appName}-${region}-${env}'
output windowsLogicAppName string = 'logic-windows-${appName}-${region}-${env}'
output aciConnectionName string = 'aci'
