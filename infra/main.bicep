targetScope = 'subscription'
param environmentName string
param location string
param resourceGroupName string = ''

param acaLocation string = 'northcentralusstage' // use North Central US (Stage) for ACA resources
param acaEnvironmentName string = 'aca-env'
param postgreSqlName string = 'postgres'
param redisCacheName string = 'redis'
param webServiceName string = 'web-service'
param apiServiceName string = 'api-service'
param webImageName string = 'docker.io/ahmelsayed/springboard-web:r'
param apiImageName string = 'docker.io/ahmelsayed/springboard-api:r4'
var tags = { 'azd-env-name': environmentName }

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${environmentName}-rg'
  location: location
  tags: tags
}

module acaEnvironment './core/host/container-apps-environment.bicep' = {
  name: 'container-apps-environment'
  scope: rg
  params: {
    name: acaEnvironmentName
    location: acaLocation
    tags: tags
  }
}

module postgreSql './core/host/springboard-container-app.bicep' = {
  name: 'postgres'
  scope: rg
  params: {
    name: postgreSqlName
    location: acaLocation
    tags: tags
    managedEnvironmentId: acaEnvironment.outputs.id
    serviceType: 'postgres'
  }
}

module redis './core/host/springboard-container-app.bicep' = {
  name: 'redis'
  scope: rg
  params: {
    name: redisCacheName
    location: acaLocation
    tags: tags
    managedEnvironmentId: acaEnvironment.outputs.id
    serviceType: 'redis'
  }
}

// The application backend
module api './core/host/container-app.bicep' = {
  name: 'api'
  scope: rg
  params: {
    name: apiServiceName
    location: acaLocation
    tags: tags
    managedEnvironmentId: acaEnvironment.outputs.id
    imageName: apiImageName
    targetPort: 80
    allowedOrigins: [ '${webServiceName}.${acaEnvironment.outputs.defaultDomain}' ]
    serviceBinds: [
      redis.outputs.serviceBind
      postgreSql.outputs.serviceBind
    ] 
  }
}

// the application frontend
module web './core/host/container-app.bicep' = {
  name: 'web'
  scope: rg
  params: {
    name: webServiceName
    location: acaLocation
    tags: tags
    managedEnvironmentId: acaEnvironment.outputs.id
    imageName: webImageName
    targetPort: 80
    env: [
      {
        name: 'REACT_APP_API_BASE_URL'
        value: 'https://${apiServiceName}.${acaEnvironment.outputs.defaultDomain}'
      }
    ]
  }
}

module pgweb './core/host/container-app.bicep' = {
  name: 'pgweb'
  scope: rg
  params: {
    name: 'pgweb'
    location: acaLocation
    tags: tags
    managedEnvironmentId: acaEnvironment.outputs.id
    imageName: 'docker.io/sosedoff/pgweb:latest'
    targetPort: 8081
    command: [
      '/bin/sh'
    ]
    args: [
      '-c'
      'PGWEB_DATABASE_URL=$POSTGRES_URL /usr/bin/pgweb --bind=0.0.0.0 --listen=8081'
    ]
    serviceBinds: [
      postgreSql.outputs.serviceBind
    ] 
  }
}

module redisStat './core/host/container-app.bicep' = {
  name: 'redis-stat'
  scope: rg
  params: {
    name: 'redis-stat'
    location: acaLocation
    tags: tags
    managedEnvironmentId: acaEnvironment.outputs.id
    imageName: 'docker.io/insready/redis-stat:latest'
    targetPort: 3000
    command: [
      '/bin/sh'
    ]
    args: [
      '-c'
      'redis-stat $REDIS_HOST:$REDIS_PORT --auth=$REDIS_PASSWORD --server=0.0.0.0'
    ]
    serviceBinds: [
      redis.outputs.serviceBind
    ] 
  }
}

// App outputs
output REACT_APP_API_BASE_URL string = api.outputs.uri
output REACT_APP_WEB_BASE_URL string = web.outputs.uri
