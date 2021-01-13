# Azure static web apps template
This repository contains an example of how you can use Azure Static Web Apps to host public and private documentation for you projects. It contains examples of how to host Sphinx/mkdocs documentation and limit the access to certain roles. This repository should work with any type of documentation generator that can compile to HTML files and is not limited to the examples you find in the repo.

[Check out the live demo here](https://brave-tree-035ee0c03.azurestaticapps.net/)

### How to use
This guide uses poetry to manage dependencies and virtual environments, but any package manager should work with some configuration.

1. Fork this repository or click the template button above
1. Delete the `.github/` folder containing the old Github Actions setup
1. [Setup Azure Static Web App in Azure](https://docs.microsoft.com/en-us/azure/static-web-apps/get-started-portal?tabs=vanilla-javascript) and connect it to your forked repository.

  Make sure to set the following values in the portal or in the Github Actions workflow file to:
  ```
  app_location: "docs/build"
  api_location: "api"
  app_artifact_location: ""
  ```
4. A Github Actions workflow file should automatically be added to your repository after setting up the static app in Azure. Open this workflow file and add the following `routes_location` value to the file, so that it looks like this:
  ```
  ...
  app_location: "docs/build"
  api_location: "api"
  app_artifact_location: ""
  routes_location: "/"   <--- Add this line
  ...
  ```
 5. Clone the repository to your local machine
 5. [Install poetry](https://python-poetry.org/docs/) and then run `poetry install` in the project folder OR use any package manager of your choice and ensure that you have `sphinx` installed

 6. Make a change in the docs and recompile the documentation by running `poetry run sphinx-build -b html source/sphinx-example build/sphinx-example`
 7. Commit the recompiled docs
 8. Visit your web app to view the changes!
 
### Automate compilation of docs
Azure Static Web Apps does not support building non-Javascript projects and therefore you have compile the docs before it gets deployed. Thankfully, Github Actions allows us to compile the HTML files before we deploy them to the web app. Doing it in this way allows us to delete the build files, so that we do not have to have them committed into our repository. Furthermore, it ensures that we do not have to run any manual steps to update the documentation. Neat! This also means that we can use almost any type of documentation compiler as long as it is possible to install on the Github Action build server and it can compile to HTML. Nice! For this repository, `sphinx` is used, but it can modified to work with your preferred build tool.

To build the `sphinx` docs, we need to add some custom build steps to our workflow app. This should be added just below the first step `actions/checkout@v2`:

```yaml
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: true
      
      # Add custom build steps here 

      - name: Set up Python 3.8
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
          
      - name: Cache virtual environment
        uses: actions/cache@v2
        env:
          cache-name: cache-poetry-packages
        with:
          path: ~/.cache/pypoetry
          key: ${{ runner.os }}-build-${{ env.cache-name }}-${{ hashFiles('**/poetry.lock') }}
          
      - name: Build install poetry
        run: |
          curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python
          echo "$HOME/.poetry/bin" >> $GITHUB_PATH
          
      - name: Build docs
        run: |
          poetry install
          poetry run sphinx-build -b html docs/source/sphinx-example docs/build/sphinx-example
      # -------------------------
```

Have a look at the [workflow file](https://github.com/equinor/az-static-web-app-docs-template/blob/main/.github/workflows/azure-static-web-apps-brave-tree-035ee0c03.yml) to see where the steps should be placed.

### Routes and security
It is very easy to setup authentication with Azure Static Web Apps. The `routes.json` file contains examples of how to setup various access restrictions. Check the [documentation for more info on how this works.](https://docs.microsoft.com/en-us/azure/static-web-apps/routes)

```
{
    "routes": [
        {
            "route": "/.auth/login/github",         <- Disable Github login
            "statusCode": "401"
        },
        {
            "route": "/.auth/login/twitter",        <- Disable Twitter login
            "statusCode": "401"
        },
        {
            "route": "/.auth/login/facebook",       <- Disable Facebook login
            "statusCode": "401"
        },
        {
            "route": "/.auth/login/google",         <- Disable Google login
            "statusCode": "401"
        },
        {
            "route": "/login",                      <- Redirect /login to Azure AD login 
            "serve": "/.auth/login/aad"
        },
        {
            "route": "/logout",                     <- Redirect /logout to logout url
            "serve": "/.auth/logout",
        },
        {
            "route": "/",                           <- Allow anonymous access to the top level url
            "allowedRoles": ["anonymous"]
        },
        {
            "route": "/authenticated",              <- Limit /authenticated access to only users that have been authenticated (logged in with Azure AD)
            "allowedRoles": ["authenticated"]
        },
        {
            "route": "/reader_role",                <- Limit /reader_role access to only users that have been assigned the role "reader" or "contributer
            "allowedRoles": ["reader", "contributer"]
        }
    ]
}
```

To restrict access to all pages, replace the contents of `routes.json` to the following:

```
{
    "routes": [
        {
            "route": "/.auth/login/github",         <- Disable Github login
            "statusCode": "401"
        },
        {
            "route": "/.auth/login/twitter",        <- Disable Twitter login
            "statusCode": "401"
        },
        {
            "route": "/.auth/login/facebook",       <- Disable Facebook login
            "statusCode": "401"
        },
        {
            "route": "/.auth/login/google",         <- Disable Google login
            "statusCode": "401"
        },
        {
            "route": "/login",                      <- Redirect /login to Azure AD login (still needed to login)
            "serve": "/.auth/login/aad"
        },
        {
            "route": "/logout",                     <- Redirect /logout to logout url
            "serve": "/.auth/logout",
        },
        {
            "route": "/*",
            "allowedRoles": ["reader", "contributer"]
        }
    ]
}
```

### File contents
```
.github/workflows/azure-static-web-apps-purple-glacier-025f0d303.yml - Github Actions config generated by Azure when the repository was connected to the service

routes.json - Azure Static Web Apps routes/authentication configuration (see: https://docs.microsoft.com/en-us/azure/static-web-apps/routes)
pyproject.toml - (Optional) Project config used by the [Poetry package manager](https://python-poetry.org/).
poetry.lock - (Optional) Package description used by the package manager.

docs/source/ - Contains source files for documentation.
docs/build/ - Custom and compiled HTML that will be hosted on Azure Static Web Apps.
docs/build/
  authenticated.html
  doc_index.html
  index.html
  reader_role.html      - Custom HTML files that can be manually configured.
  
docs/source/sphinx-example/
docs/build/sphinx-example/ - Source and build folder for the Sphinx example documentation code.
```
