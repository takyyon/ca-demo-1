param name string
param location string = resourceGroup().location
param tags object = {}

param containerAppsEnvironmentName string
param serviceType string

resource app 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {

    }
    template: {
      containers: [
        {
          name: 'nginx'
          image: 'nginx:latest'
        }
      ]
    }
  }
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsEnvironmentName
}

output appId string = app.id
