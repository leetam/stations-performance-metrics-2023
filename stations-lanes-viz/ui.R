library(shinydashboard)
library(shiny)
library(leaflet)
library(DT)
library(plotly)
library(lubridate)

hours <- readRDS("data/hours.rds")

header <- dashboardHeader(title = "Stations: Mainline DRAFT",
                          titleWidth = 450)

body <- dashboardBody(
  
  fluidRow(
    #### Select Filters ####
    column(
      width = 2,
      box(
        width = NULL,
        selectizeInput(
          "main_quant_1",
          label = "Quantity 1",
          choices = list(
            "volume",
            "speed",
            "occupancy",
            "vmt",
            "vht",
            "traveltime",
            "delay"
          )
        )
      ),
      box(
        width = NULL,
        selectizeInput(
          "main_quant_2",
          label = "Quantity 2",
          choices = list(
            "volume",
            "speed",
            "occupancy",
            "vmt",
            "vht",
            "traveltime",
            "delay"
          )
        )
      ),
      box(
        width = NULL,
        dateRangeInput(
          "main_daterange",
          label = "Date Range:",
          start = "2023-11-10",
          end = "2023-11-10",
          min = "2019-01-01",
          max = "2023-11-10"
        )
      ),
      box(
        width = NULL,
        checkboxGroupInput(
          "main_dow",
          label = "Days Of The Week",
          choices = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"),
          selected = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
        )
      ),
      box(
        width = NULL,
        sliderInput(
          "main_timerange",
          label = "Time Range",
          min = lubridate::origin,
          max = lubridate::origin + days(1) - seconds(1),
          value = c(lubridate::origin, lubridate::origin + days(1) - seconds(1)),
          step = 5 * 60,
          timeFormat = "%H:%M",
          timezone = "+0000",
          ticks = T
        )
      ),
      box(
        width = NULL,
        selectInput(
          "main_resolution",
          label = "Resolution",
          choices = list("1 hour" = "01:00:00",
                         "1 day"),
          selected = 1)
      ),
      box(
        width = NULL,
        checkboxGroupInput(
          "ramp_lane",
          label = "Lane(s)",
          choices = list(1,
                         2,
                         3),
          selected = c(1, 2, 3))
        ),
      box(
        width = NULL,
        selectInput(
          "main_group",
          label = "Group",
          choices = list("Yes",
                         "No"),
          selected = "No"
        )
      )
    ),
    column(
      width = 10,
      box(
        width = NULL,
        plotlyOutput(
          "stations_level_figure"
        )
      ),
      box(
        width = NULL,
        plotlyOutput(
          "lane_level_figure"
        )
      )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = T),
  body
)