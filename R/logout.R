#' Create a button to log out
#'
#' A \code{logoutButton} is an \code{\link[shiny]{actionButton}} that is meant
#' to be used to log out of an auth0 Shiny app.
#'
#' @param label The label on the button.
#' @param ... Named attributes to apply to the button.
#' @param id An ID for the button. If you only have one logout button in
#' your app, you do not need to explicitly provide an ID. If you have more than
#' one logout button, you need to provide a unique ID to each button. When you
#' create a button with a non-default ID, you must create an observer that
#' listens to a click on this button and logs out of the app with a call to
#' \code{\link[auth0]{logout}}.
#' @seealso \code{\link[auth0]{logout}},
#' \code{\link[auth0]{logout_url}}
#' @examples
#' if (interactive()) {
#'   ui <- fluidPage(
#'     logoutButton(),
#'     logoutButton(label = "Another logout button", id = "logout2")
#'   )
#'   server <- function(input, output, session) {
#'     observeEvent(input$logout2, {
#'       logout()
#'     })
#'   }
#'   shinyAuth0App(ui, server)
#' }
#'
#' @export
logoutButton <- function(label = "Log out", ..., id = "._auth0logout_") {
  shiny::actionButton(id, label, ...)
}

#' Generate a logout URL
#'
#' Generate a URL that will log the user out of the app if visited.
#'
#' @return URL string to log out.
#'
#' @seealso \code{\link[auth0]{logoutButton}},
#' \code{\link[auth0]{logout}}
#'
#' @details You can also use a diferent configuration file by setting the
#' `auth0_config_file` option with:
#' `options(auth0_config_file = "path/to/file.yaml")`.
#'
#' @export
logout_url <- function() {

  config <- auth0_config()

  app_url_enc <- utils::URLencode(redirect_uri, reserved = TRUE)
  logout_url <- sprintf("%s/v2/logout?client_id=%s&returnTo=%s",
                        config$auth0_config$api_url,
                        config$auth0_config$credentials$key,
                        app_url_enc)
  logout_url
}

#' Log out of an auth0 app
#'
#' Log the current user out of an auth0 shiny app.
#'
#' @seealso \code{\link[auth0]{logoutButton}},
#' \code{\link[auth0]{logout_url}}
#'
#' @details You can also use a diferent configuration file by setting the
#' `auth0_config_file` option with:
#' `options(auth0_config_file = "path/to/file.yaml")`.
#'
#' @export
logout <- function() {

  if (!requireNamespace("shinyjs", quietly = TRUE)) {
    stop("Package \"shinyjs\" required.", call. = FALSE)
  }

  shiny::insertUI(
    selector = "head", where = "beforeEnd", immediate = TRUE,
    ui = shinyjs::useShinyjs()
  )
  url <- logout_url()
  js <- sprintf('location.replace("%s")', url)
  shinyjs::runjs(js)
}
