function Get-InputOrDefault
{
    Param
    (
        [string] $promptText,
        [string] $defaultValue
    )
    $value = Read-Host -Prompt ($promptText + " [default: '$($defaultValue)']")
    if ($value) {
        return $value
    }
    else {
        return $defaultValue
    }
}

# Write welcome message
@"
╔═══╗            ╔═══╗╔╗    ╔╗     ╔╗╔╗╔╗  ╔╗  ╔═══╗         
║╔═╗║            ║╔═╗╠╝╚╗  ╔╝╚╗    ║║║║║║  ║║  ║╔═╗║         
║║ ║╠═══╦╗╔╦═╦══╗║╚══╬╗╔╬══╬╗╔╬╦══╗║║║║║╠══╣╚═╗║║ ║╠══╦══╦══╗
║╚═╝╠══║║║║║╔╣║═╣╚══╗║║║║╔╗║║║╠╣╔═╝║╚╝╚╝║║═╣╔╗║║╚═╝║╔╗║╔╗║══╣
║╔═╗║║══╣╚╝║║║║═╣║╚═╝║║╚╣╔╗║║╚╣║╚═╗╚╗╔╗╔╣║═╣╚╝║║╔═╗║╚╝║╚╝╠══║
╚╝ ╚╩═══╩══╩╝╚══╝╚═══╝╚═╩╝╚╝╚═╩╩══╝ ╚╝╚╝╚══╩══╝╚╝ ╚╣╔═╣╔═╩══╝
            ╔═══╗                  ╔╗    ╔╗        ║║ ║║     
            ╚╗╔╗║                 ╔╝╚╗  ╔╝╚╗       ╚╝ ╚╝     
         ╔╗  ║║║╠══╦══╦╗╔╦╗╔╦══╦═╗╚╗╔╬══╬╗╔╬╦══╦═╗           
        ╔╝╚╗ ║║║║╔╗║╔═╣║║║╚╝║║═╣╔╗╗║║║╔╗║║║╠╣╔╗║╔╗╗          
        ╚╗╔╝╔╝╚╝║╚╝║╚═╣╚╝║║║║║═╣║║║║╚╣╔╗║║╚╣║╚╝║║║║          
         ╚╝ ╚═══╩══╩══╩══╩╩╩╩══╩╝╚╝╚═╩╝╚╝╚═╩╩══╩╝╚╝          
                                                             

"@
Write-Host 'Welcome to this setup wizard for the Azure Static Web Apps Template'
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');


# Log into Azure
Write-Host "`nCONNECT TO YOUR AZURE ACCOUNT"
#Connect-AzAccount

# TODO: Log into Github



# Gather input data
## Name of the Azure Web App resource
Write-Host "`nCREATE PROJECT"
$appName = Get-InputOrDefault -promptText "Enter name of Azure Web App Resource" -defaultValue "static-web-apps-template"
$azResourceGroup = Get-InputOrDefault -promptText "Enter name of Azure Resource Group" -defaultValue "static-documentation-app"

## Repository URL and token
Write-Host "`nACCESSING GITHUB REPOSITORY"
# $repoURL = Read-Host -Prompt "URL to GitHub repository"
$repoURL = "https://github.com/viggotw/az-static-web-app-docs-template-fork"  # TODO: Slett meg
# $repoToken = Read-Host -Prompt "Token to GitHub repository" -AsSecureString
$repoToken = ConvertTo-SecureString "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" -AsPlainText -Force  # TODO: Slett meg
$repoBranch = Get-InputOrDefault -promptText "Enter branch that should be triggered to re-build the documentation" -defaultValue "main"


## Resource parameters
Write-Host "`nSETUP AZURE RESOURCE"
$location = Get-InputOrDefault -promptText "Enter desired Azure Resource Location" -defaultValue "westeurope"
$skuName = Get-InputOrDefault -promptText "Enter desired Azure Resource SKU Type" -defaultValue "free"
$skuTier = Get-InputOrDefault -promptText "Enter desired Azure Resource SKU Pricing Tier" -defaultValue "free"

# Desired file locations in repo
Write-Host "`nFILE LOCATIONS"
# $appLocation = Get-InputOrDefault -promptText "Enter location of your application code" -defaultValue "/docs/build"
$appOutputLocation = Get-InputOrDefault -promptText "Enter location where the public files are generated" -defaultValue "/docs/build"
# $apiLocation = Get-InputOrDefault -promptText "Enter location of your Azure Functions code" -defaultValue "api"
# $appArtifactLocation = Get-InputOrDefault -promptText "Enter the path of your build output relative to your apps location" -defaultValue "src"


# Delete previous deploy-script
Write-Host "`nDELETING OLD GITHUB ACTION"
if (Test-Path ".\.github\workflows\deploy-site.yml") {
    Remove-Item ".\.github\workflows\deploy-site.yml"
}

# Deploy new resource
Write-Host "`nDEPLOYING NEW AZURE RESOURCE..."

## Link to the bicep- and parameter-files
$templateFile = ".\azure-web-app-deployer\main.bicep"
# $templateParameterFile = ".\azure-web-app-deployer\azuredeploy.parameters.json"

## Create unique deployment name
$date = Get-Date -Format "MM-dd-yyThh-mm"
$deploymentName = "$appName-$date"

## Deploy new resource
New-AzResourceGroupDeployment `
-Name $deploymentName `
-ResourceGroupName $AzResourceGroup `
-TemplateFile $templateFile `
-appName $appName `
-repositoryUrl $repoURL `
-repositoryBranch $repoBranch `
-repositoryToken $repoToken `
-location $location `
-skuName $skuName `
-skuTier $skuTier `
-appOutputLocation $appOutputLocation


# Visit Static Web App Page
