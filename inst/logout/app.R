# shinyapp
library(shiny)
library(auth0)

ui <- fluidPage(logoutButton())

server <- function(input, output, session) { }
shinyAppAuth0(ui, server)
