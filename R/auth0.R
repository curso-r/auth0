auth0_app_url <- function(config) {
  if (interactive()) {
    config$shiny_config$local_url
  } else {
    config$shiny_config$remote_url
  }
}

auth0_app <- function(app_url, app_name, key, secret) {
  httr::oauth_app(appname = app_name, key = key, secret = secret,
                  redirect_uri = app_url)
}

auth0_api <- function(auth0_url, request, access) {
  httr::oauth_endpoint(base_url = auth0_url, request = request,
                       authorize = "authorize", access = access)
}

has_auth_code <- function(params, state) {
  !is.null(params$code) && params$state == state
}

auth0_server_verify <- function(session, app, api, state) {
  u_search <- session[["clientData"]]$url_search
  params <- shiny::parseQueryString(u_search)
  if (has_auth_code(params, state)) {
    cred <- httr::oauth2.0_access_token(api, app, params$code)
    token <- httr::oauth2.0_token(
      app = app, endpoint = api, cache = FALSE, credentials = cred,
      user_params = list(grant_type = "authorization_code"))

    userinfo_url <- sub("authorize", "userinfo", api$authorize)
    resp <- httr::GET(userinfo_url, httr::config(token = token))
    session$userData$login_info <- httr::content(resp, "parsed")
  }
}

auth0_state <- function(server) {
  paste(sample(c(letters, 0:9), 10, replace = TRUE), collapse = "")
}

auth0_info <- function(config) {
  scope <- config$auth0_config$scope
  state <- auth0_state()
  conf <- config$auth0_config
  app_url <- auth0_app_url(config)
  app <- auth0_app(app_url, config$name,
                   conf$credentials$key, conf$credentials$secret)
  api <- auth0_api(conf$api_url, conf$request, conf$access)
  list(scope = scope, state = state, app = app, api = api)
}

auth0_config <- function(config_file) {
  config <- yaml::read_yaml(config_file, eval.expr = TRUE)

  # standardise and validate shiny_config
  if (is.null(config$auth0_config)) {
    stop("Missing 'auth0_config' tag in YAML file.")
  }
  if (is.null(config$shiny_config)) {
    default_url <- "http://localhost:8100"
    config$shiny_config <- list(local_url = default_url,
                                remote_url = default_url)
  } else if (!is.list(config$shiny_config)) {
    default_url <- config$shiny_config
    config$shiny_config <- list(local_url = default_url,
                                emote_url = default_url)
  } else if (is.null(config$shiny_config$local_url)) {
    config$shiny_config$local_url <- config$shiny_config$remote_url
  } else if (is.null(config$shiny_config$remote_url)) {
    config$shiny_config$remote_url <- config$shiny_config$local_url
  }

  # standardise and validate auth0_config
  if (is.null(config$auth0_config)) {
    stop("Missing 'auth0_config' tag in YAML file.")
  }
  config_names <- names(unlist(config$auth0_config))
  required_names <- c("api_url", "credentials.key", "credentials.secret")
  missing_args <- setdiff(required_names, config_names)
  s <- strrep("s", max(length(missing_args) - 1L, 0))
  if (length(missing_args) > 0) {
    msg <- sprintf("Missing '%s' tag%s in YAML file",
                   paste(missing_args, collapse = "','"), s)
    stop(msg)
  }
  defaults <- list(scope = "openid profile",
                   request = "oauth/token", access = "oauth/token")

  for (nm in names(defaults)) {
    if (!nm %in% config_names) {
      config$auth0_config[[nm]] <- defaults[[nm]]
    }
  }
  config
}

#' Auth0 configuration file
#'
#' Create an YAML containing information to connect with Auth0.
#'
#' @param path Directory name. Should be the root of the shiny app
#' you want to add this functionality
#' @param file File name. Defaults to `_auth0.yml`.
#' @param overwrite Will only overwrite existing path if `TRUE`.
#'
#' @details The YAML configuration file has required parameters and extra
#' parameters.
#'
#' The required parameters are:
#' - `shiny_config`: an URL to access the app or a list containing `local_url`
#' (e.g. http://localhost:8100) and `remote_url`
#' (e.g. https://johndoe.shinyapps.io/app) tags.
#' - `auth0_config` is a list contaning at least:
#'   - `api_url`: Your account at Auth0 (e.g. https://jonhdoe.auth0.com).
#'   It is the "Domain" in Auth0 application settings.
#'   - `credentials`: Your credentials to access Auth0 API, including
#'     - `key`: the Client ID in Auth0 application settings.
#'     - `secret`: the Client Secret in Auth0 application settings.
#'
#' The extra parameters are:
#' - `scope`: The information that Auth0 app will access.
#' Defaults to "openid profile".
#' - `request`: Endpoit to request a token. Defaults to "oauth/token"
#' - `access`: Endpoit to access. Defaults to "oauth/token"
#'
#' @export
use_auth0 <- function(path = ".", file = "_auth0.yml", overwrite = FALSE) {
  f <- paste0(normalizePath(path), "/", file)
  if (file.exists(f) && !overwrite) {
    stop("File exists and overwrite is FALSE.")
  }
  ks <- list(key = 'Sys.getenv("AUTH0_KEY")', secret = 'Sys.getenv("AUTH0_SECRET")')
  api_url <- "paste0('https://', Sys.getenv('AUTH0_USER'), '.auth0.com')"
  attr(ks[[1]], "tag") <- "!expr"
  attr(ks[[2]], "tag") <- "!expr"
  attr(api_url, "tag") <- "!expr"
  yaml_list <- list(
    name = "myApp",
    shiny_config = "http://localhost:8100",
    auth0_config = list(api_url = api_url, credentials = ks))
  yaml::write_yaml(yaml_list, f)
}
