library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(plotly)
# library(highcharter)
# library(htmlwidgets)
# library(xts)
library(shiny)
library(shinydashboard)

lane_data <- readRDS("data/data_example_lane.rds")
station_data <- readRDS("data/data_example_station.rds")

source("draft2-quant/R/fake_2qnt_df.R")

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
    
    seq_startdate <- paste(as.character(input$main_daterange[1]), "00:00:00")
    seq_enddate <- paste(as.character(input$main_daterange[2]), "23:59:59")
    start_time <- seq(ymd_hms(seq_startdate), ymd_hms(seq_enddate), input$main_resolution)
    quant1 <- floor(runif(start_time, min = 0, max = 200))
    quant2 <- floor(runif(start_time, min = 0, max = 300))
      
    df_a <- bind_cols(start_time, quant1, quant2)
    colnames(df_a) <- c("start_time", input$main_quant_1, input$main_quant_2)
    df_b <- df_a %>%
      pivot_longer(2:3,
                   names_to = "quantity",
                   values_to = "value") %>%
      separate(col = start_time,
               into = c("date", "time"),
               sep = " ",
               remove = F) %>%
      mutate(dow = wday(start_time), label = T,
             year = year(starttime))
    
    df_b$dow <- as.character(df_b$dow)
    df_b$date <- as.date(df_b$date)
    df_b$time <- hms::as_hms(df_b$time)
    
    df_b_filtered <- df_b %>%
      filter(
        dow %in% input$main_dow,
        time >= input$main_timerange[1], time <= input$main_timerange[2]
      ) %>%
      select(-date, -time, -dow)
    
    return(df_b_filtered)
        # selected_lane_data <- lane_data %>%
    #   filter(detector_id == 100192) %>%
    #   select(starttime, resolution, Date, time, dow,
    #          input$main_quant_1, input$main_quant_2) %>%
    #   filter(
    #     Date >= input$main_daterange[1], Date <= input$main_daterange[2],
    #     dow %in% input$main_dow,
    #     time >= input$main_timerange[1], time <= input$main_timerange[2],
    #     resolution == input$main_resolution) %>%
    #   select(-resolution, -Date, -time, -dow)
    # selected_lane_data_xts <- as.xts(selected_lane_data)
    # selected_lane_data_xts
  })

  output$twoquantchart1 <- renderPlotly({
    lane_data_range_filters() %>%
      ggplot(aes())
    
  })
    
#   output$twoquantchart1 <- renderHighchart({
#     
#     lane_data_range_filters() %>%
#       highchart(type = "chart") %>%
#       hc_yAxis_multiples(
#         list(lineWidth = 2,
#              opposite = FALSE),
#         list(showLastLabel = FALSE,
#              opposite = TRUE)
#       ) %>%
#       hc_add_series(
#         subdatax[, input$main_quant_1],
#         type = "column",
#         yAxis = 0,
#         name = input$main_quant_1
#       ) %>%
#       hc_add_series(
#         type = "line",
#         subdatax[, input$main_quant_2],
#         yAxis = 1,
#         name = input$main_quant_2
#       ) %>%
#       hc_xAxis(dateTimeLabelFormats = list(day = "%m %Y"), type = "datetime")
#     
#   })
#   
# }














