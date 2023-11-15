library(shinydashboard)
library(shiny)
library(leaflet)
library(DT)
library(plotly)
library(lubridate)

hours <- readRDS("data/hours.rds")

header <- dashboardHeader(title = "Stations: Ramp DRAFT",
                          titleWidth = 450)

body <- dashboardBody(
  
  fluidRow(
    column(
      width = 2,
      box(
        width = NULL,
        dateRangeInput(
          "ramp_daterange",
          label = "Date Range:",
          start = "2023-01-01",
          end = "2023-01-01",
          min = "2019-01-01",
          max = "2023-11-09"
        )
      ),
      box(
        width = NULL,
        checkboxGroupInput(
          "ramp_dow",
          label = "Days Of The Week",
          choices = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"),
          selected = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
        )
      ),
      box(
        width = NULL,
        sliderInput(
          "ramp_timerange",
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
          "ramp_resolution",
          label = "Resolution",
          choices = list("1 hour",
                         "1 day"),
          selected = 1)
      ),
      box(
        width = NULL,
        selectInput(
          "ramp_group",
          label = "Group",
          choices = list("Yes",
                         "No"),
          selected = "No"
        )
      ),
      box(
        width = NULL,
        checkboxGroupInput(
          "ramp_lane",
          label = "Lane(s)",
          choices = list("All",
                         1,
                         2),
          selected = "All"
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