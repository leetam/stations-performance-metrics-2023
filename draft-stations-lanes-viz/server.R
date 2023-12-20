library(shinydashboard)
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)

lane_data <- readRDS("data/data_example_lane.rds")
station_data <- readRDS("data/data_example_station.rds")

function(input, output, session) {
  
  
  #### Date range filters ####
  lane_data_range_filters <- reactive({
    req(
      input$main_quant_1,
      input$main_quant_2,
      input$main_daterange,
      input$main_dow,
      input$main_timerange,
      input$main_resolution
        # input$ramp_time_comp,
        # input$ramp_lane,
        # input$ramp_group
      )
    selected_lane_data <- lane_data %>%
      select(resolution, starttime, date, time, dow,
             input$main_quant_1, input$main_quant_2) %>%
      filter(
        date >= input$main_daterange[1] & date <= input$main_daterange[2],
        dow %in% input$main_dow,
        time >= input$main_timerange[1] & time <= input$main_timerange[2],
        resolution == input$main_resolution) %>%
      pivot_longer(cols = c(input$main_quant_1, input$main_quant_2), 
                   names_to = "quantity",
                   values_to = "value")
    selected_lane_data
  })

  output$lane_level_figure <- renderPlotly({
    
    lane_data_range_filters() %>%
      ggplot(aes(x = starttime, y = value, color = quantity)) +
      geom_line(stat = "identity") +
      facet_grid(quantity ~ lane_no, scales = "free_y") +
      theme_bw()
  })
  
}
  
  
  
  
  
  
  
  
  
  
  
  
  
    
