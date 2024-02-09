library(dplyr)
library(highcharter)
library(htmlwidgets)
library(xts)
library(shiny)
library(shinydashboard)

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
      filter(detector_id == 100192) %>%
      select(starttime, resolution, Date, time, dow,
             input$main_quant_1, input$main_quant_2) %>%
      filter(
        Date >= input$main_daterange[1], Date <= input$main_daterange[2],
        dow %in% input$main_dow,
        time >= input$main_timerange[1], time <= input$main_timerange[2],
        resolution == input$main_resolution) %>%
      select(-resolution, -Date, -time, -dow)
    selected_lane_data_xts <- as.xts(selected_lane_data)
    selected_lane_data_xts
  })
  
  output$twoquantchart1 <- renderHighchart({
    
    lane_data_range_filters() %>%
      highchart(type = "chart") %>%
      hc_yAxis_multiples(
        list(lineWidth = 2,
             opposite = FALSE),
        list(showLastLabel = FALSE,
             opposite = TRUE)
      ) %>%
      hc_add_series(
        subdatax[, input$main_quant_1],
        type = "column",
        yAxis = 0,
        name = input$main_quant_1
      ) %>%
      hc_add_series(
        type = "line",
        subdatax[, input$main_quant_2],
        yAxis = 1,
        name = input$main_quant_2
      ) %>%
      hc_xAxis(dateTimeLabelFormats = list(day = "%m %Y"), type = "datetime")
    
  })
  
}














