param repositoryUrl string
param repositoryBranch string

param appName string

param location string = resourceGroup().location
param skuName string
param skuTier string

@secure()
param repositoryToken string
param appOutputLocation string

resource staticWebApp 'Microsoft.Web/staticSites@2021-03-01' = {
  name: appName
  location: location
  properties: {
    repositoryUrl: repositoryUrl
    branch: repositoryBranch
    repositoryToken: repositoryToken
    buildProperties: {
      outputLocation: appOutputLocation
      githubActionSecretNameOverride: 'DEPLOY_TOKEN'
      skipGithubActionWorkflowGeneration: true
    }
  }
  sku: {
    name: skuName
    tier: skuTier
  }
}
