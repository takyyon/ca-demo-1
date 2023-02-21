targetScope = 'subscription'
param resourcesSuffix string = '7'
param environmentName string

param resourceGroupName string = 'springboard-${resourcesSuffix}'
param location string
param acaLocation string = 'northcentralusstage' // use North Central US (Stage) for ACA resources

param acaEnvironmentName string = 'aca-${resourcesSuffix}'
param postgreSqlName string = 'postgres-${resourcesSuffix}'
param redisCacheName string = 'redis-${resourcesSuffix}'
param webServiceName string = 'web-service-${resourcesSuffix}'
param apiServiceName string = 'api-service-${resourcesSuffix}'
param webImageName string = 'docker.io/ahmelsayed/springboard-web:latest'
param apiImageName string = 'docker.io/ahmelsayed/springboard-api:latest'

var tags = { 'azd-env-name': environmentName }

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
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

// The application database
module postgreSql './app/db.bicep' = {
  name: 'sql'
  scope: rg
  params: {
    name: postgreSqlName
    location: acaLocation
    tags: tags
    environmentName: acaEnvironment.outputs.name
  }
}

module cache './app/cache.bicep' = {
  name: 'cache'
  scope: rg
  params: {
    name: redisCacheName
    location:acaLocation
    tags: tags
    environmentName: acaEnvironment.outputs.name
  }
}

// The application frontend
module web './app/web.bicep' = {
  name: 'web'
  scope: rg
  params: {
    name: webServiceName
    location: acaLocation
    tags: tags
    environmentName: acaEnvironment.outputs.name
    imageName: webImageName
    apiBaseUri: 'https://${apiServiceName}.${acaEnvironment.outputs.defaultDomain}' //api.outputs.SERVICE_API_URI
  }
}

// The application backend
module api './app/api.bicep' = {
  name: 'api'
  scope: rg
  params: {
    name: apiServiceName
    location: acaLocation
    tags: tags
    environmentName: acaEnvironment.outputs.name
    imageName: apiImageName
    allowedOrigins: [ '${webServiceName}.${acaEnvironment.outputs.defaultDomain}' ]
    // serviceBinds: [
      // cache.outputs.redisServiceId
      // postgreSql.outputs.postgresServiceId
    // ]
  }
}


// App outputs
output REACT_APP_API_BASE_URL string = api.outputs.SERVICE_API_URI
output REACT_APP_WEB_BASE_URL string = web.outputs.SERVICE_WEB_URI
