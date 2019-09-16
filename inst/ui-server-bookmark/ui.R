library(shiny)
library(auth0)

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
