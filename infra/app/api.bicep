param name string
param location string = resourceGroup().location
param tags object = {}

param environmentName string
param imageName string
param allowedOrigins array
param serviceBinds array = []

module api '../core/host/container-app.bicep' = {
  name: '${name}-app-module'
  params: {
    name: name
    location: location
    tags: tags
    containerAppsEnvironmentName: environmentName
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    imageName: imageName
    targetPort: 80
    allowedOrigins: allowedOrigins
    serviceBinds: serviceBinds
  }
}

output SERVICE_API_URI string = api.outputs.uri
