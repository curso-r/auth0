library(shiny)
library(auth0)

auth0_ui(fluidPage(logoutButton()), info = a0_info)
