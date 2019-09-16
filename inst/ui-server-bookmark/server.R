library(shiny)
library(auth0)

server <- function(input, output, session) {
  output$out <- renderText({
    if (input$caps)
      toupper(input$txt)
    else
      input$txt
  })
}

auth0_server(server)
