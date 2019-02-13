auth0_ui <- function(ui, info) {
  function(req) {
    verify <- has_auth_code(shiny::parseQueryString(req$QUERY_STRING),
                            info$state)
    if (!verify) {
      url <- httr::oauth2.0_authorize_url(
        info$api, info$app, scope = info$scope, state = info$state
      )
      redirect <- sprintf("location.replace(\"%s\");", url)
      htmltools::tags$script(htmltools::HTML(redirect))
    } else {
      ui
    }
  }
}

auth0_server <- function(server, info) {
  function(input, output, session) {
    shiny::isolate(auth0_server_verify(session, info$app, info$api, info$state))
    server(input, output, session)
  }
}

find_config_file <- function() {
  config_file <- getOption("auth0_config_file")

  if (is.null(config_file)) {
    config_file <- "./_auth0.yml"
  }

  config_file
}

#' Create a Shiny app object with Auth0 Authentication
#'
#' This function modifies ui and server objects to run using Auth0
#' authentication.
#'
#' @param ui an ordinary UI object to create shiny apps.
#' @param server an ordinary server object to create shiny apps.
#' @param config_file Path to YAML configuration file.
#'
#' @details
#' If you want to use a diferent configuration file you can also set the `auth0_config_file`
#' option with: `options(auth0_config_file = "path/to/file.yaml")`.
#'
#' @export
shinyAuth0App <- function(ui, server, config_file = NULL) {

  if (is.null(config_file))
    config_file <- find_config_file()

  config <- auth0_config(config_file)

  info <- auth0_info(config)
  if (interactive()) {
    p <- config$shiny_config$local_url
    re <- regexpr("(?<=:)([0-9]+)", p, perl = TRUE)
    port <- as.numeric(regmatches(p, re))
    shiny::shinyApp(auth0_ui(ui, info), auth0_server(server, info),
                    options = list(port = port))
  } else {
    shiny::shinyApp(auth0_ui(ui, info), auth0_server(server, info))
  }
}

#' Generate logout URL
#'
#' Generates logout URL from configuration file. This can be used inside a
#' shiny app button to logout from the app.
#'
#' @param config_file Path to YAML configuration file.
#' @param redirect_js include javascript code to redirect page? Defaults to `TRUE`.
#'
#' @return url string to logout, collapsed or not by javascript code.
#'
#' @details To use this function successfully inside a shiny app, you may
#' want to install `shinyjs` package. See example
#'
#' If you want to use a diferent configuration file you can set the `auth0_config_file`
#' option with: `options(auth0_config_file = "path/to-file")`.
#'
#' @examples
#' \donttest{
#' library(shiny)
#' library(auth0)
#' library(shinyjs)
#
#' # simple UI with action button
#' # note that you must include shinyjs::useShinyjs() for this to work
#' ui <- fluidPage(shinyjs::useShinyjs(), actionButton("logout_auth0", "Logout"))
#'
#' # server with one observer that logouts
#' server <- function(input, output, session) {
#'   observeEvent(input$logout_auth0, {
#'     # javascript code redirecting to correct url
#'     js <- auth0_logout_url()
#'     shinyjs::runjs(js)
#'   })
#' }
#'
#' shinyAuth0App(ui, server, config_file = config_file)
#' }
#'
#' @export
auth0_logout_url <- function(config_file = NULL, redirect_js = TRUE) {

  if (is.null(config_file))
    config_file <- find_config_file()

  config <- auth0_config(config_file)

  app_url <- auth0_app_url(config)
  app_url_enc <- utils::URLencode(app_url, reserved = TRUE)
  logout_url <- sprintf("%s/v2/logout?client_id=%s&returnTo=%s",
                        config$auth0_config$api_url,
                        config$auth0_config$credentials$key,
                        app_url_enc)
  if (redirect_js) {
    logout_url <- sprintf('location.replace("%s")', logout_url)
  }
  logout_url
}
