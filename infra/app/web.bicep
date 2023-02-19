param name string
param location string = resourceGroup().location
param tags object = {}

param environmentName string
param imageName string
param apiBaseUri string

module web '../core/host/container-app.bicep' = {
  name: '${name}-deployment'
  params: {
    name: name
    location: location
    tags: tags
    containerAppsEnvironmentName: environmentName
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    imageName: imageName
    targetPort: 80
    env: [
      {
        name: 'REACT_APP_API_BASE_URL'
        value: apiBaseUri
      }
    ]
  }
}

output SERVICE_WEB_URI string = web.outputs.uri
