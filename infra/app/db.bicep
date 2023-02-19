param name string
param location string = resourceGroup().location
param tags object = {}

param environmentName string

module postgreSql '../core/host/springboard-container-app.bicep' = {
  name: 'postgreSql'
  params: {
    name: name
    location: location
    tags: tags
    containerAppsEnvironmentName: environmentName
    serviceType: 'postgres'
  }
}

output postgresServiceId string = postgreSql.outputs.appId
