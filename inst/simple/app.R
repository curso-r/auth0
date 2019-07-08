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

shinyAppAuth0(ui, server)
