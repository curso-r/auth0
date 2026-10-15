library(auth0)

# Authorization URL generation is local; no Auth0 account or token request is used.
local({
  old <- options(auth0_local = FALSE, auth0_disable = FALSE)
  on.exit(options(old))
  config <- list(
    name = "query-test",
    remote_url = "https://example.invalid/app",
    auth0_config = list(
      api_url = "https://tenant.example.invalid",
      credentials = list(key = "test-client", secret = "test-secret"),
      scope = "openid profile", request = "oauth/token", access = "oauth/token"
    )
  )
  info <- auth0_info(config)
  ui <- auth0_ui(shiny::fluidPage(), info)
  for (remote in c(FALSE, TRUE)) {
    options(auth0_local = !remote)
    for (query in c("", "_state_id_=bookmark-123", "label=one%26two%3Dthree&user%20name=Jane%20Doe&percent=100%25&plus=a%2Bb&literal=%2526&key%2520=value")) {
      html <- as.character(ui(list(QUERY_STRING = query, HTTP_HOST = "127.0.0.1:8080")))
      url <- sub('.*location.replace\\("(.*)"\\);.*', '\\1', html)
      redirect <- httr::parse_url(url)$query$redirect_uri
      actual <- httr::parse_url(redirect)
      expected <- shiny::parseQueryString(query)
      cat("remote:", remote, "query:", query, "redirect:", redirect, "\n")
      if (length(expected)) {
        stopifnot(identical(actual$query, expected))
      } else {
        stopifnot(length(actual$query) == 0L)
      }
      stopifnot(identical(actual$hostname, if (remote) "example.invalid" else "localhost"))
    }
  }
  # Exercise the cleanup observer via the public server wrapper, without a token exchange.
  session <- shiny::MockShinySession$new()
  on.exit(session$close(), add = TRUE)
  query <- "label=one%26two%3Dthree&literal=%2526&key%2520=value"
  session$clientData <- shiny::reactiveValues(
    url_search = paste0("?state=fixture&", query),
    url_pathname = "/app/", url_hash = "#section"
  )
  updated <- NULL
  session$updateQueryString <- function(queryString, mode) {
    stopifnot(mode == "replace")
    updated <<- queryString
  }
  server <- auth0_server(function(input, output, session) {}, info)
  shiny::withReactiveDomain(session, {
    server(session$input, session$output, session)
    session$flushReact()
  })
  stopifnot(identical(httr::parse_url(updated)$query, shiny::parseQueryString(query)))
  stopifnot(endsWith(updated, "#section"))
})
