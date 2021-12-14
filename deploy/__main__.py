import pulumi
import pulumi_azure_native as azure_native

config = pulumi.Config()

resource_group = azure_native.resources.ResourceGroup("az-static-web-app-docs")

static_site = azure_native.web.StaticSite(
    "staticSite",
    branch="main",
    build_properties=azure_native.web.StaticSiteBuildPropertiesArgs(
        api_location="api",
        app_artifact_location="",
        app_location="docs/build",
        github_action_secret_name_override="DEPLOY_TOKEN",
        skip_github_action_workflow_generation=True,
    ),
    location="West Europe",
    name="az-static-web-app-docs-template",
    repository_token=config.require_secret("github-access-token"),
    repository_url="https://github.com/equinor/az-static-web-app-docs-template",
    resource_group_name=resource_group.name,
    sku=azure_native.web.SkuDescriptionArgs(
        name="Free",
        tier="Free",
    ),
)

pulumi.export("Url", static_site.default_hostname)
