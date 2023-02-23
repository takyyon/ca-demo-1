param name string
param location string = resourceGroup().location
param tags object = {}

param managedEnvironmentId string
param serviceType string = ''

resource app 'Microsoft.App/containerApps@2022-11-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      service: !empty(serviceType) ? {
        type: serviceType
      } : null
    }
    template: {
      containers: [
        {
          name: name
          image: !empty(serviceType) ? serviceType : 'nginx:latest'
        }
      ]
    }
  }
}

output serviceBind object = {
  serviceId: app.id
  name: name
}
