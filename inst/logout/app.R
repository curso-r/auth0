# shinyapp
library(shiny)
library(auth0)

ui <- fluidPage(logoutButton())

server <- function(input, output, session) { }
auth0App(ui, server)
