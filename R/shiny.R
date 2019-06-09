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

auth0_server <- function(server, info, config_file = NULL) {
  function(input, output, session) {
    shiny::isolate(auth0_server_verify(session, info$app, info$api, info$state))
    shiny::observeEvent(input[["._auth0logout_"]], logout(config_file = config_file))
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
    shiny::shinyApp(auth0_ui(ui, info), auth0_server(server, info, config_file),
                    options = list(port = port))
  } else {
    shiny::shinyApp(auth0_ui(ui, info), auth0_server(server, info, config_file))
  }
}
