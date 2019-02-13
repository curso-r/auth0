# auth0

[![Travis-CI Build Status](https://travis-ci.org/curso-r/auth0.svg?branch=master)](https://travis-ci.org/curso-r/auth0) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/curso-r/auth0?branch=master&svg=true)](https://ci.appveyor.com/project/curso-r/auth0) [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/auth0)](https://cran.r-project.org/package=auth0)


The goal of auth0 is to implement an authentication scheme to Shiny using 
OAuth Apps through the freemium service [Auth0](https://auth0.com).

## Installation

You can install auth0 from github with:

``` r
# install.packages("devtools")
devtools::install_github("curso-r/auth0")
```

## Auth0 Configuration

Auth0 is an external service so you should create an account there. To create your authenticated shiny app, you should follow the five steps below.

### Step 1: Create an Auth0 account

- Go to [auth0.com](https://auth0.com)
- Click "Sign Up"
- You can create an account placing user name and password or simply signing with your github account.

### Step 2: Create an Auth0 application

After logging in Auth0, you will see a page like this:

<img src="man/figures/README-dash.png">

- Click on "+ New Application"
- Give a name to your app
- Select "Regular Web Applications" and click "Choose"

### Step 3: Configure your application

- Go to the Settings in your selected application. You should see a page like this:

<img src="man/figures/README-myapp.png">

- Add `http://localhost:8100` to the "Allowed Callback URLs", "Allowed Web Origins" and "Allowed Logout URLs".
    - You can change `http://localhost:8100` to another port or the remote server you are going to deploy your shiny app. Just make sure that these addresses are correct. If you are placing your app inside a folder (e.g. https://johndoe.shinyapps.io/fooBar), don't include the folder (`fooBar`) in "Allowed Web Origins".
- Click "Save"

Now let's go to R!

### Step 4: Create your shiny app and fill the `_auth0.yml` file

- Create a configuration file for your shiny app, using `auth0::use_auth0()`:

```r
auth0::use_auth0()
```

- You can set the directory where this file will be created using the `path=` parameter. See `?use_auth0` for details.
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
AUTH0_USER=jtrecenti
AUTH0_KEY=5wugt0W...
AUTH0_SECRET=rcaJ0p8...
```

More about environment variables [here](https://csgillespie.github.io/efficientR/set-up.html#renviron). You can also fill these information directly in the `_auth0.yml` file, although it is not recommended. If you do so, don't forget to save the `_auth0.yml` file after editing it.

- Save and **restart your session**.
- Write a simple shiny app in a `app.R` file, like this:

```r
library(shiny)

ui <- bootstrapPage(
  fluidRow(plotOutput("plot"))
)

server <- function(input, output, session) {
  output$plot <- renderPlot({
    plot(1:10)
  })
}

# note that here we're using a different version of shinyApp!
auth0::shinyAuth0App(ui, server)
```

**Note**: If you want to use a different path to the `auth0` configuration file, you may
set the `auth0_config_file` option by running `options(auth0_config_file = "path/to/file")`.

### Step 5: Run!

You can try your app running

```r
shiny::runApp("app/directory/", port = 8100)
```

If everything is OK, you should be forwarded to a login page and, after logging in or signing up, you'll be redirected to your app.

## Managing users

You can manage user access from the Users panel in Auth0. To create an user, simply click on "+ Create users".

You can also use many OAuth providers like Google, Facebook, Github etc. To configure them, go to Connections tab. 

In the near future, our plan is to implement Auth0's API in R so that you can manage your app using R.

## User information

When you are connected, it is possible to access user information inside the `session$userData$login_info` object. This object must be acessed in a reactive environment. There is a small example here:

```r
library(shiny)
library(auth0)

# simple UI with user info
ui <- fluidPage(
  verbatimTextOutput("user_info")
)

# server with one observer that logouts
server <- function(input, output, session) {

  # print user info
  output$user_info <- renderPrint({
    session$userData$login_info
  })

}

shinyAuth0App(ui, server)
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

## Logout

You can also add a logout button to your app using [`shinyjs`](https://github.com/daattali/shinyjs) package. There is a small example here:

```r
library(shiny)
library(auth0)
library(shinyjs)

# simple UI with action button
# note that you must include shinyjs::useShinyjs() for this to work
ui <- fluidPage(shinyjs::useShinyjs(), actionButton("logout_auth0", "Logout"))

# server with one observer that logouts
server <- function(input, output, session) {
  observeEvent(input$logout_auth0, {
    # javascript code redirecting to correct url
    js <- auth0::auth0_logout_url()
    shinyjs::runjs(js)
  })
}

shinyAuth0App(ui, server)
```

## Costs

Auth0 is a freemium service. The free account lets you have up to 1000 connections in one month and two types of social connections. You can check all the plans [here](https://auth0.com/pricing).

## Disclaimer

This package is not provided nor endorsed by Auth0 Inc. Use it on your own risk.

## Licence

MIT
