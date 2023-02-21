param name string
param location string = resourceGroup().location
param tags object = {}

param managedEnvironmentId string
param serviceType string

resource app 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: managedEnvironmentId
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

output id string = app.id
