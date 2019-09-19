library(shiny)
library(auth0)

# # run this before running the app:
# options(shiny.port = 8080)
# shiny::enableBookmarking(store = "server")

server <- function(input, output, session) {
  output$out <- renderText({
    if (input$caps)
      toupper(input$txt)
    else
      input$txt
  })
}

auth0_server(server)
