targetScope = 'subscription'
param resourcesSuffix string = '3'
param environmentName string

param resourceGroupName string = 'springboard-${resourcesSuffix}'
param location string = 'eastus2'

param acaEnvironmentName string = 'aca-${resourcesSuffix}'
param postgreSqlName string = 'postgre-${resourcesSuffix}'
param redisCacheName string = 'redis-${resourcesSuffix}'
param webServiceName string = 'web-service-${resourcesSuffix}'
param apiServiceName string = 'api-service-${resourcesSuffix}'
param webServiceImage string = 'docker.io/ahmelsayed/springboard-web:latest'
param apiServiceImage string = 'docker.io/ahmelsayed/springboard-api:latest'

var tags = { 'azd-env-name': environmentName }

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module acaenvironment './core/host/container-apps-environment.bicep' = {
  name: 'container-apps-environment'
  scope: rg
  params: {
    name: acaEnvironmentName
    location: location
    tags: tags
  }
}

// The application database
module postgreSql './app/db.bicep' = {
  name: 'sql'
  scope: rg
  params: {
    name: postgreSqlName
    location: location
    tags: tags
    environmentName: acaenvironment.outputs.name
  }
}

module cache './app/cache.bicep' = {
  name: 'cache'
  scope: rg
  params: {
    name: redisCacheName
    location:location
    tags: tags
    environmentName: acaenvironment.outputs.name
  }
}

// The application frontend
module web './app/web.bicep' = {
  name: 'web'
  scope: rg
  params: {
    name: webServiceName
    location: location
    tags: tags
    environmentName: acaenvironment.outputs.name
    imageName: webServiceImage
    apiBaseUri: api.outputs.SERVICE_API_URI
  }
}

// The application backend
module api './app/api.bicep' = {
  name: 'api'
  scope: rg
  params: {
    name: apiServiceName
    location: location
    tags: tags
    environmentName: acaenvironment.outputs.name
    imageName: apiServiceImage
    allowedOrigins: [ '*' ]
    // serviceBinds: [
      // cache.outputs.redisServiceId
      // postgreSql.outputs.postgresServiceId
    // ]
  }
}


// App outputs
output REACT_APP_API_BASE_URL string = api.outputs.SERVICE_API_URI
output REACT_APP_WEB_BASE_URL string = web.outputs.SERVICE_WEB_URI
