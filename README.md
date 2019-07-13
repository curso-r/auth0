# auth0

[![Travis-CI Build Status](https://travis-ci.org/curso-r/auth0.svg?branch=master)](https://travis-ci.org/curso-r/auth0) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/curso-r/auth0?branch=master&svg=true)](https://ci.appveyor.com/project/curso-r/auth0) [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/auth0)](https://cran.r-project.org/package=auth0)

The goal of auth0 is to implement an authentication scheme to Shiny using 
OAuth Apps through the freemium service [Auth0](https://auth0.com).

## Installation

You can install auth0 from CRAN with:

``` r
install.packages("auth0")
```

You can also install the development version from github with:

``` r
# install.packages("devtools")
devtools::install_github("curso-r/auth0")
```

## Auth0 Configuration

To create your authenticated shiny app, you need to follow the five steps below.

### Step 1: Create an Auth0 account

- Go to [auth0.com](https://auth0.com)
- Click "Sign Up"
- You can create an account with a user name and password combination, or by signing up with your GitHub or Google accounts.

### Step 2: Create an Auth0 application

After logging into Auth0, you will see a page like this:

<img src="man/figures/README-dash.png">

- Click on "+ Create Application"
- Give a name to your app
- Select "Regular Web Applications" and click "Create"

### Step 3: Configure your application

- Go to the Settings in your selected application. You should see a page like this:

<img src="man/figures/README-myapp.png">

- Add `http://localhost:8100` to the "Allowed Callback URLs", "Allowed Web Origins" and "Allowed Logout URLs".
    - You can change `http://localhost:8100` to another port or the remote server you are going to deploy your shiny app. Just make sure that these addresses are correct. If you are placing your app inside a folder (e.g. https://johndoe.shinyapps.io/fooBar), don't include the folder (`fooBar`) in "Allowed Web Origins".
- Click "Save"

Now let's go to R!

### Step 4: Create your shiny app and fill the `_auth0.yml` file

- Create a configuration file for your shiny app by calling `auth0::use_auth0()`:

```r
auth0::use_auth0()
```

- You can set the directory where this file will be created using the `path=` parameter. See `?auth0::use_auth0` for details.
- Your `_auth0.yml` file should be like this:


```yml
name: myApp
shiny_config:
  local_url: http://localhost:8100
  remote_url: ''
auth0_config:
  api_url: !expr paste0('https://', Sys.getenv("AUTH0_USER"), '.auth0.com')
  credentials:
    key: !expr Sys.getenv("AUTH0_KEY")
    secret: !expr Sys.getenv("AUTH0_SECRET")
```

- Run `usethis::edit_r_environ()` and add these three environment variables:

```
AUTH0_USER=johndoe
AUTH0_KEY=5wugt0W...
AUTH0_SECRET=rcaJ0p8...
```

There's how you identify each of them (see the image below):

- `AUTH0_USER` is your username, which can be found on the top corner of the site.
- `AUTH0_KEY` is your Client ID, which can be copied from inside the app page.
- `AUTH0_SECRET` is your Client Secret, which can be copied from the app page.

<img src="man/figures/README-myapp-vars.png">

More about environment variables [here](https://csgillespie.github.io/efficientR/set-up.html#renviron). You can also fill these information directly in the `_auth0.yml` file (see below). If you do so, don't forget to save the `_auth0.yml` file after editing it.

- Save and **restart your session**.
- Write a simple shiny app in a `app.R` file, like this:

```r
library(shiny)

ui <- fluidPage(
  fluidRow(plotOutput("plot"))
)
  
server <- function(input, output, session) {
  output$plot <- renderPlot({
    plot(1:10)
  })
}

# note that here we're using a different version of shinyApp!
auth0::shinyAppAuth0(ui, server)
```

**Note**: If you want to use a different path to the `auth0` configuration file, you can
either pass it to `shinyAppAuth0()` or
set the `auth0_config_file` option by running `options(auth0_config_file = "path/to/file")`.

Also note that currently Shiny apps that use the 2-file approach (`ui.R` and `server.R`) are not supported. Your app must be inside a single `app.R` file.

### Step 5: Run!

You can try your app running

```r
shiny::runApp("app/directory/", port = 8100)
```

If everything is OK, you should be forwarded to a login page and, after logging in or signing up, you'll be redirected to your app.

--------------------------------------------------------------------------------

## Environment variables and multiple auth0 apps

If you are using `auth0` for just one shiny app or you are running many apps for the same user database, the recommended workflow is using the environment variables `AUTH0_KEY` and `AUTH0_SECRET`.

However, if you are running many shiny apps and want to use different login settings, you must create many Auth0 apps. Hence, you'll have many Cliend IDs and Client Secrets to use. In this case, environment variables will be unproductive because you'll need to change them every time you change the app you are developing.

The best option in this case is to simply add the Client ID and Secret directly in the `_auth0.yml` file:

```yml
name: myApp
shiny_config:
  local_url: http://localhost:8100
  remote_url: ''
auth0_config:
  api_url: https://<USERNAME>.auth0.com
  credentials:
    key: <CLIENT_ID>
    secret: <CLIENT_SECRET>
```

Example:

```yml
name: myApp
shiny_config:
  local_url: http://localhost:8100
  remote_url: ''
auth0_config:
  api_url: https://johndoe.auth0.com
  credentials:
    key: cetQp0e7bdTNGrkrHpuF8gObMVl8vu
    secret: C6GHFa22mfliojqPyKP_5K0ml4TituWrOhYvLdTa7veIyEU3Q10R_-If-7Sh6Tc
```

--------------------------------------------------------------------------------

## RStudio limitations

Because RStudio is specialized in standard shiny apps, some features do not work as expected when using `auth0`. The main issues are:

1. The "Run App" button does not appear in the right corner of the `app.R` script. That's because RStudio searches for the "shinyApp" term in the code to identify a shiny app. A small hack to solve this is adding a comment containing "shinyApp" in the script:

```r
# shinyApp
library(shiny)
library(auth0)

ui <- fluidPage("hello")
server <- function(input, output, session) { }
shinyAppAuth0(ui, server)
```

If you run using `runApp()` (or pressing the button) and the host has a port (like `localhost:8100`), you must fix the port before running the app:

```r
options(shiny.port = 8100)
```

2. You must run the app in a real browser, like Chrome or Firefox. If you use the RStudio Viewer or run the app in a RStudio window, the app will show a blank page and won't work.

--------------------------------------------------------------------------------

## Alternative configuration options

The steps above show how to configure the `_auth0.yml` file setting `local_url` and `remote_url` fields under `shiny_config`. 

The `local_url` is used when you are developing your app locally, so it will probably be something like `http://localhost` or `http://127.0.0.1`. You will also need to set a default port, adding something like `:8888` after the `local_url`, so that when you run the app it is accessible by your browser. Some of these ports are reserved and you should __not__ use them. The default port in auth0 package is `:8100`, so if you want to change it, make sure that you also added it to the callback/web origin/logout URLs in Auth0.

The `remote_url` is used when you use your app in production. For example, if you set up your shiny-server to run through `http://example.com/myapp`, or `https://johndoe.shinyapps.io/myapp`, that is what you are going to put in `remote_url`. Please make sure that you wrote the `http` or `https` correctly, unless it won't work.

Actually, it is also possible to replace

```yml
shiny_config:
  local_url: http://localhost:8100
  remote_url: http://example.com
```

by just

```yml
shiny_config: http://localhost:8100
```

or

```yml
shiny_config: http://example.com
```

That will the case when you are developing the app to use locally or if you are developing directly inside a shiny-server folder. 

--------------------------------------------------------------------------------

## Managing users

You can manage user access from the Users panel in Auth0. To create a user, click on "+ Create users".

You can also use many different OAuth providers like Google, Facebook, Github etc. To configure them, go to the *Connections* tab. 

In the near future, our plan is to implement Auth0's API in R so that you can manage your app using R.

--------------------------------------------------------------------------------

## Logged information

After a user logs in, it's possible to access the current user's information using the `session$userData$auth0_info` reactive object. Here is a small example:

```r
library(shiny)
library(auth0)

# simple UI with user info
ui <- fluidPage(
  verbatimTextOutput("user_info")
)

server <- function(input, output, session) {

  # print user info
  output$user_info <- renderPrint({
    session$userData$auth0_info
  })

}

shinyAppAuth0(ui, server)
```

You should see an object like this:

```
$sub
[1] "auth0|5c06a3aa119c392e85234f"

$nickname
[1] "jtrecenti"

$name
[1] "jtrecenti@email.com"

$picture
[1] "https://s.gravatar.com/avatar/1f344274fc21315479d2f2147b9d8614?s=480&r=pg&d=https%3A%2F%2Fcdn.auth0.com%2Favatars%2Fjt.png"

$updated_at
[1] "2019-02-13T10:33:06.141Z"
```

Note that the `sub` field is unique and can be used for many purposes, like creating customized apps for different users.

--------------------------------------------------------------------------------

## Logout

You can add a logout button to your app using `logoutButton()`.

```r
library(shiny)
library(auth0)

# simple UI with logout button
ui <- fluidPage(logoutButton())
server <- function(input, output, session) {}
shinyAppAuth0(ui, server)
```

--------------------------------------------------------------------------------

## Costs

Auth0 is a freemium service. The free account lets you have up to 1000 connections in one month and two types of social connections. You can check all the plans [here](https://auth0.com/pricing).

## Disclaimer

This package is not provided nor endorsed by Auth0 Inc. Use it at your own risk.

--------------------------------------------------------------------------------

## Roadmap

- Auth0 0.1.2: Changes thanks to @daattali's review
    - [x] (breaking change) change `login_info` to `auth0_info` in the user session data (Issue #19).
    - [x] Option to ignore auth0 and work as a normal shiny app, to save developing time (Issue #26).
    - [x] Examples for different login types (google/facebook, database etc, Issue #23).
    - [x] Improved logout button (Issue #24)
    - [x] Use `shinyAppAuth0()` instead of `shinyAuth0App()` and soft-deprecate `shinyAuth0App()` (Issue #18).
    - Better documentation
          - [x] Handle multiple shiny apps and multiple auth0 apps (Issue #17).
          - [x] Explain some RStudio details(Issues #15 and #16).
          - [x] Explain environment variables (Issue #14).
          - [x] Explain yml file config (Issue #13).
    - [x] test whitelisting with auth0 (Issue #10).
    - [x] Improve handling and documentation of the `config_file` option (Issue #25).
- Auth0 0.2.0
    - [ ] Solve bookmarking and URL parameters issue (Issue #22).
    - [ ] `shinyAppDirAuth0()` function to work as `shiny::shinyAppDir()` (Issue #21).
    - [ ] Implement auth0 API functions to manage users and login options through R.
    - [ ] Support to `ui.R`/`server.R` apps.

--------------------------------------------------------------------------------

## Licence

MIT
