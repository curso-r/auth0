library(shiny)
library(auth0)

# # run this before running the app:
# options(shiny.port = 8080)
# shiny::enableBookmarking(store = "server")

# this example is the same as bookmark, but using bookmarking
ui <- function(request) {
  fluidPage(
    textInput("txt", "Enter text"),
    checkboxInput("caps", "Capitalize"),
    verbatimTextOutput("out"),
    bookmarkButton(),
    logoutButton()
  )
}

auth0_ui(ui)
