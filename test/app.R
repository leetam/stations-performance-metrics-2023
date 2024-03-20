library(shiny)
library(DT)

ui <- basicPage(
  h2("The mtcars data"),
  DT::dataTableOutput("mytable"),
  verbatimTextOutput("test"),
  plotOutput('plot1')
  
)

server <- function(input, output) {
  
  mc <- head(mtcars) # could be reactive in real world case
  
  output$mytable = DT::renderDataTable({
    datatable(mc, filter = 'top')
  })
  
  filtered_table <- reactive({
    req(input$mytable_rows_all)
    mc[input$mytable_rows_all, ]  
  })
  
  output$plot1 <- renderPlot({
    plot(filtered_table()$wt, filtered_table()$mpg, col = "red", lwd = 10)
  })
  
  output$test <- renderPrint({
    filtered_table()
  })
  
}

shinyApp(ui, server)
