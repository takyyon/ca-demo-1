param name string
param location string = resourceGroup().location
param tags object = {}

param environmentName string

module cache '../core/host/springboard-container-app.bicep' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    containerAppsEnvironmentName: environmentName
    serviceType: 'redis'
  }
}

output redisServiceId string = cache.outputs.appId
