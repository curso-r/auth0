.onLoad <- function(libname, pkgname) {
  op <- options()
  op.auth0 <- list(
    auth0_config_file = NULL,
    auth0_disable = NULL,
    auth0_local = interactive()
  )
  toset <- !(names(op.auth0) %in% names(op))
  if(any(toset)) options(op.auth0[toset])
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

# Get rid of NOTE
globalVariables(c("redirect_uri"))
