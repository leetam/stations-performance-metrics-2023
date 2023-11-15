library(shinydashboard)
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)

ramp_data <- readRDS("data/ramp.rds")

function(input, output, session) {
  
  ramp_data_filters <- reactive({
    req(input$ramp_daterange,
        input$ramp_dow,
        input$ramp_timerange,
        input$ramp_resolution,
        # input$ramp_time_comp,
        # input$ramp_lane,
        # input$ramp_group
        )
    ramp_data %>%
      filter(Date >= input$ramp_daterange[1] & Date <= input$ramp_daterange[2],
             dow %in% input$ramp_dow,
             time >= input$ramp_timerange[1] & time <= input$ramp_timerange[2],
             resolution == input$ramp_resolution)
  })
  
  output$ramp_volume_figure <- renderPlotly({
    req(ramp_data_filters())
    ramp_fig <- ramp_data_filters() %>%
      ggplot(aes(x = start_time, y = metered_lane_volume)) +
      geom_bar(stat = "identity", fill = "purple") +
      theme_bw() +
      xlab(NULL) +
      ylab("Metered Lane Volume") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
    

 
}
