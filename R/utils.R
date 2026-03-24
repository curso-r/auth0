.onLoad <- function(libname, pkgname) {
  op <- options()
  op.auth0 <- list(
    auth0_config_file = NULL,
    auth0_disable = NULL,
    auth0_local = interactive()
  )
  toset <- !(names(op.auth0) %in% names(op))
  if (any(toset)) options(op.auth0[toset])
  invisible()
}

#' Find the configuration file.
#'
#' Tries to find the path to the `_auth0.yml` file. First, it tries to get
#'   this info from `options(auth0_config_file = )`. If this option is `NULL`
#'   (the default) it tries to find the `_auth0.yml` within the working
#'   directory. If the file does not exist, it raises an error.
#'
#' @return Character vector of length one contaning the path of the
#'   `_auth0.yml` file.
#'
#' @seealso [`use_auth0`].
#'
#' @export
auth0_find_config_file <- function() {
  config_file <- getOption("auth0_config_file")

  if (is.null(config_file) || !file.exists(config_file)) {
    config_file <- "./_auth0.yml"
  }

  if (!file.exists(config_file)) {
    stop(
      "Didn't find any YML configuration file. ",
      "There are two possible explanations:\n",
      "1. You didn't create an _auth0.yml file. Solution: Run `use_auth0()`\n",
      "2. You created an _auth0.yml file, but it was not found.\n",
      "You have two options:\n",
      "  Solution 2a): set the path for the _auth0.yml ",
      "file running `options(auth0_config_file = \"/path/to/_auth0.yml\")`. ",
      "Always use absolute path, because shiny::runApp() modifies ",
      "the working directory.\n",
      "  Solution 2b): If your app.R file is in the same directory as the ",
      "_auth0.yml file, set the working directory to the folder ",
      "where _auth0.yml file is located."
    )
  }

  config_file
}

auth0_remove_callback_params <- function(session) {
  shiny::observeEvent(session[["clientData"]]$url_search,
    {
      params <- shiny::parseQueryString(session[["clientData"]]$url_search)

      # Remove only auth callback params and keep any other query params untouched.
      if (!is.null(params$code) || !is.null(params$state)) {
        params$code <- NULL
        params$state <- NULL

        path <- session[["clientData"]]$url_pathname
        hash <- session[["clientData"]]$url_hash

        query <- ""
        if (length(params) > 0) {
          encoded <- mapply(
            function(nm, val) {
              paste0(
                utils::URLencode(nm, reserved = TRUE),
                "=",
                utils::URLencode(as.character(val), reserved = TRUE)
              )
            },
            names(params),
            params,
            SIMPLIFY = TRUE,
            USE.NAMES = FALSE
          )
          query <- paste0("?", paste(encoded, collapse = "&"))
        }

        shiny::updateQueryString(paste0(path, query, hash), mode = "replace", session = session)
      }
    },
    once = TRUE,
    ignoreInit = FALSE
  )
}

# Get rid of NOTE
globalVariables(c("redirect_uri"))
