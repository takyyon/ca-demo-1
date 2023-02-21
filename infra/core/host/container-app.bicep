param name string
param location string = resourceGroup().location
param tags object = {}

param managedEnvironmentId string
param containerName string = 'main'
param env array = []
param external bool = true
param imageName string
param targetPort int = 80
param allowedOrigins array = []
param serviceBinds array = []

@description('CPU cores allocated to a single container instance, e.g. 0.5')
param containerCpuCoreCount string = '1.0'

@description('Memory allocated to a single container instance, e.g. 1Gi')
param containerMemory string = '2.0Gi'

resource app 'Microsoft.App/containerApps@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: managedEnvironmentId
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        external: external
        targetPort: targetPort
        transport: 'auto'
        corsPolicy: {
          allowedOrigins: union([ 'https://portal.azure.com', 'https://ms.portal.azure.com' ], allowedOrigins)
        }
      }
    }
    template: {
      serviceBinds: serviceBinds
      containers: [
        {
          image: imageName
          name: containerName
          env: env
          resources: {
            cpu: json(containerCpuCoreCount)
            memory: containerMemory
          }
        }
      ]
    }
  }
}

output uri string = 'https://${app.properties.configuration.ingress.fqdn}'
output appId string = app.id
