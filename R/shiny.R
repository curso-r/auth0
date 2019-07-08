auth0_ui <- function(ui, info) {
  function(req) {
    verify <- has_auth_code(shiny::parseQueryString(req$QUERY_STRING), info$state)
    if (!verify) {
      if (grepl("error=unauthorized", req$QUERY_STRING)) {
        redirect <- sprintf("location.replace(\"%s\");", logout_url())
        htmltools::tags$script(htmltools::HTML(redirect))
      } else {
        url <- httr::oauth2.0_authorize_url(
          info$api, info$app, scope = info$scope, state = info$state
        )
        redirect <- sprintf("location.replace(\"%s\");", url)
        htmltools::tags$script(htmltools::HTML(redirect))
      }
    } else {
      ui
    }
  }
}

auth0_server <- function(server, info) {
  function(input, output, session) {
    shiny::isolate(auth0_server_verify(session, info$app, info$api, info$state))
    shiny::observeEvent(input[["._auth0logout_"]], logout())
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
#' @param config_file path to YAML configuration file.
#'
#' @details
#' You can also use a diferent configuration file by setting the
#' `auth0_config_file` option with:
#' `options(auth0_config_file = "path/to/file.yaml")`.
#'
#' @section Disable auth0 while developing apps:
#'
#' Sometimes, using auth0 to develop and test apps can be frustrating,
#'   because every time the app is started, auth0 requires the user to log-in.
#'   To avoid this problem, one can run `options(auth0_disable = TRUE)` to
#'   disable auth0 temporarily.
#'
#' @export
shinyAppAuth0 <- function(ui, server, config_file = NULL) {

  disable <- getOption("auth0_disable")
  if (!is.null(disable) && disable) {
    shiny::shinyApp(ui, server)
  } else {
    if (is.null(config_file)) {
      config_file <- find_config_file()
    }
    else {
      options(auth0_config_file = config_file)
    }

    config <- auth0_config()
    info <- auth0_info(config)
    if (interactive()) {
      p <- config$shiny_config$local_url
      re <- regexpr("(?<=:)([0-9]+)", p, perl = TRUE)
      port <- as.numeric(regmatches(p, re))
      shiny::shinyApp(auth0_ui(ui, info),
                      auth0_server(server, info),
                      options = list(port = port))
    } else {
      shiny::shinyApp(auth0_ui(ui, info),
                      auth0_server(server, info))
    }
  }
}

#' Create a Shiny app object with Auth0 Authentication
#'
#' @description
#'
#' As of auth0 0.1.2, `shinyAuth0App()` has
#' been renamed to [shinyAppAuth0()] for consistency.
#'
#' @inheritParams shinyAppAuth0
#'
#' @export
shinyAuth0App <- function(ui, server, config_file = NULL) {
  warning("`shinyAuth0App()` is soft-deprecated as of auth0 0.1.2.",
          "Please use `shinyAppAuth0()` instead.")
  shinyAppAuth0(ui, server, config_file)
}

#' Generate logout URL
#'
#' `auth0_logout_url()` is defunct as of auth0 0.1.2 in order to simplifly the
#'   user experience with the [logoutButton()] function.
#'
#' @param config_file Path to YAML configuration file.
#' @param redirect_js include javascript code to redirect page? Defaults to `TRUE`.
#'
#' @examples
#' \donttest{
#'
#' # simple UI with action button
#' # AFTER auth0 0.1.2
#'
#' library(shiny)
#' library(auth0)
#'
#' ui <- fluidPage(logoutButton())
#' server <- function(input, output, session) {}
#' shinyAuth0App(ui, server, config_file)
#'
#' # simple UI with action button
#' # BEFORE auth0 0.1.2
#'
#' library(shiny)
#' library(auth0)
#' library(shinyjs)
#'
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
#' shinyAppAuth0(ui, server, config_file = config_file)
#' }
#'
#'
#' @export
auth0_logout_url <- function(config_file = NULL, redirect_js = TRUE) {

  stop("`auth0_logout_url()` is deprecated. ",
       "See `?logoutButton()` to add a logout button in auth0 apps.")

}

