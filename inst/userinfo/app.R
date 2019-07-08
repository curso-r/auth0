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
    session$userData$auth0_info
  })

}

shinyAppAuth0(ui, server)
