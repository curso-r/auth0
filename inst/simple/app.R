library(shiny)
library(auth0)

ui <- bootstrapPage(
  fluidRow(plotOutput("plot"))
)

server <- function(input, output, session) {
  output$plot <- renderPlot({
    plot(1:10)
  })
}

shinyAuth0App(ui, server)
