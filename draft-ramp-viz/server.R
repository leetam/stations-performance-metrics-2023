library(shinydashboard)
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)

ramp_data <- readRDS("data/ramp.rds")

function(input, output, session) {
  
  
  #### Date range filters ####
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
             resolution == input$ramp_resolution) %>%
      mutate(datetime = make_datetime(2020, month(start_time), day(start_time), 
                                      hour(start_time), minute(start_time), second(start_time)),
             dataset = "init")
  })
  
#### Grouping yes/no ####
    ramp_data_configurations <- reactive({
    req(ramp_data_range_filters())
    ramp_data_range_filters() %>%
      {if(input$ramp_group == "Yes") group_by(., time) else .} %>%
      summarise(mean_volume = mean(metered_lane_volume)) %>%
      mutate(datetime = make_datetime(2020, month(start_time), day(start_time), 
                                      hour(start_time), minute(start_time), second(start_time)),
             dataset = "init")
  })
  
#### Ramp volume figure ####
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
  
#### Historic data ####

    ramp_data_historic <- reactive({
      # req(input$yn_historic)
      comp_1 <- ramp_data %>%
        filter(Date >= input$ramp_daterange_comp1[1] & Date <= input$ramp_daterange_comp1[2],
               resolution == input$ramp_resolution) %>%
        mutate(dataset = paste0(as.character(input$ramp_daterange_comp1[1]), 
                                "-", 
                                as.character(input$ramp_daterange_comp1[2])),
          datetime = make_datetime(2020, month(start_time), day(start_time), 
                                        hour(start_time), minute(start_time), second(start_time)))
      
      comp_2 <- ramp_data %>%
        filter(Date >= input$ramp_daterange_comp2[1] & Date <= input$ramp_daterange_comp2[2],
               resolution == input$ramp_resolution) %>%
        mutate(dataset = paste0(as.character(input$ramp_daterange_comp2[1]), 
                                "-", 
                                as.character(input$ramp_daterange_comp2[2])),
               datetime = make_datetime(2020, month(start_time), day(start_time), 
                                        hour(start_time), minute(start_time), second(start_time)))
      
      comp_3 <- ramp_data %>%
        filter(Date >= input$ramp_daterange_comp3[1] & Date <= input$ramp_daterange_comp3[2],
               resolution == input$ramp_resolution) %>%
        mutate(dataset = paste0(as.character(input$ramp_daterange_comp3[1]), 
                                "-", 
                                as.character(input$ramp_daterange_comp3[2])),
               datetime = make_datetime(2020, month(start_time), day(start_time), 
                                        hour(start_time), minute(start_time), second(start_time)))
      
      comp_data <- bind_rows(comp_1, comp_2, comp_3)
    })
      # ramp_data_historic <- reactive({
      # req(ramp_data_range_filters())
      
      # four_years <- seq(from = as.numeric(year(input$ramp_daterange[1])), to = as.numeric(year(input$ramp_daterange[1]))- 3)
      # four_months <- min(input$ramp_daterange %m-% months(3))
      # four_weeks <- min(input$ramp_daterange - weeks(3))
      
      # ramp_data_range_filters() %>%
      #     filter(year %in% four_years)
      # case_when(input$ramp_time_comp == "Past 4 Years" ~ filter(year(input$ramp_daterange[1]) %in% c(four_years)),
      #           input$ramp_time_comp == "Past 4 Months" ~ filter(Date >= four_months & Date <= input$ramp_daterange[1]),
      #           input$ramp_time_comp == "Past 4 Weeks" ~ filter(Date >= four_weeks & Date <= input$ramp_daterange[1])
    # })
    
    
#### Historic comparison figure ####

    output$test_ramp_figure <- renderPlotly({
      req(input$ramp_daterange_comp1)
      
      figure <- ramp_data_historic() %>%
        ggplot(aes(x = datetime, y = metered_lane_volume, fill = dataset)) +
        geom_bar(stat = "identity", position = "dodge") +
        theme_bw() +
        xlab(NULL) +
        ylab("Metered Lane Volume")
    })
    # output$test_ramp_figure <- renderPlotly({
    #   if (input$ramp_group == "No" & input$yn_historic == "No") {
    #     figure <- ramp_data_range_filters() %>%
    #       ggplot(aes(x = start_time, y = metered_lane_volume)) +
    #       geom_bar(stat = "identity", fill = "purple") +
    #       theme_bw() +
    #       xlab(NULL) +
    #       ylab("Metered Lane Volume") +
    #       theme(axis.text.x = element_text(angle = 45, hjust = 1))
    #   }
    #   if (input$ramp_group == "Yes" & input$yn_historic == "No") {
    #     figure <- ramp_data_configurations() %>%
    #       ggplot(aes(x = time, y = mean_volume)) +
    #       geom_bar(stat = "identity", fill = "blue") +
    #       theme_bw() +
    #       xlab(NULL) +
    #       ylab("Mean Metered Lane Volume") +
    #       theme(axis.text.x = element_text(angle = 45, hjust = 1))
    #   }
    #   if (input$ramp_group == "No" & input$yn_historic == "Yes") {
    #     figure <- ramp_data_range_filters() %>%
    #       ggplot(aes(x = datetime, y = metered_lane_volume)) +
    #       geom_bar(stat = "identity", fill = "purple") +
    #       geom_bar(ramp_data_historic(), fill = year) +
    #       theme_bw() +
    #       xlab(NULL) +
    #       ylab("Metered Lane Volume") +
    #       scale_x_datetime(breaks = make_date_time(2020, 1:12), labels = month.abb)
    #   }
    #   figure
    # })
    
  # output$test_ramp_figure <- renderPlotly({
  #   {if(input$ramp_time_comp == "No")
  #     ramp_data_range_filters() %>%
  #       ggplot(aes(x = start_time, y = metered_lane_volume)) +
  #       geom_bar(stat = "identity")
  #     else
  #       ramp_data_historic() %>%
  #       mutate(datetime = make_datetime(2020, month(start_time), day(start_time), hour(start_time), minute(start_time), second(start_time))) %>%
  #       ggplot(aes(x = start_time, y = metered_lane_volume, fill = "year")) +
  #       geom_bar(stat = "identity", position = "jitter")
  #   }
  # })
  
}
