library(shiny)
library(rlang)
# library(auth0)


ui <- function(request) {
  fluidPage(
    textInput("txt", "Enter text"),
    checkboxInput("caps", "Capitalize"),
    verbatimTextOutput("out"),
    bookmarkButton(),
    auth0::logoutButton()
  )
}
server <- function(input, output, session) {
  output$out <- renderText({
    if (input$caps)
      toupper(input$txt)
    else
      input$txt
  })
}

shiny::setBookmarkExclude(c("code", "state"))

options(shiny.port = 8080)
enableBookmarking(store = "url")
shinyAppAuth0(ui, server)
