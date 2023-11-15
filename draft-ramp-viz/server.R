library(shinydashboard)
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)

ramp_data <- readRDS("data/ramp.rds")

function(input, output, session) {
  
  ramp_data_range_filters <- reactive({
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
  
  ramp_data_configurations <- reactive({
    req(ramp_data_range_filters())
    ramp_data_range_filters() %>%
      {if(input$ramp_group == "Yes") group_by(., time) else .} %>%
      summarise(mean_volume = mean(metered_lane_volume))
  })
  
  output$ramp_volume_figure <- renderPlotly({
    {if(input$ramp_group == "No")
      ramp_data_range_filters() %>%
        ggplot(aes(x = start_time, y = metered_lane_volume)) +
        geom_bar(stat = "identity", fill = "purple") +
        theme_bw() +
        xlab(NULL) +
        ylab("Metered Lane Volume") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
      else
        ramp_data_configurations() %>%
        ggplot(aes(x = time, y = mean_volume)) +
        geom_bar(stat = "identity", fill = "blue") +
        theme_bw() +
        xlab(NULL) +
        ylab("Mean Metered Lane Volume") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
  })
    

 
}
