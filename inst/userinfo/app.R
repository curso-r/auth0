library(shiny)
library(auth0)

# simple UI with user info
ui <- fluidPage(
  verbatimTextOutput("user_info")
)

# server with one observer that logouts
server <- function(input, output, session) {

  # print user info
  output$user_info <- renderPrint({
    session$userData$login_info
  })

}

shinyAuth0App(ui, server)
