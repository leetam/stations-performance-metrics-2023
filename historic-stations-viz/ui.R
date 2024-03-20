library(shinydashboard)
library(shiny)
library(leaflet)
library(DT)
library(ggplot2)
library(plotly)
library(lubridate)

header <- dashboardHeader(title = "Historic PORTAL Stations Map DRAFT")

body <- dashboardBody(
    
    fluidRow(
        column(
            width = 3,
            box(
                p(
                    "PORTAL only displays data from active stations recording data. Use this map and it's tools to search for historic stations. Please note that prior to 2023, many of the ODOT station locations were tied to cabinet locations, not the location of the actual detector locations. Once you've identified the station(s) of interest, please send us a .csv or .txt file of those stations, and include in your email the date range and resolution, and we will pull that data for you within one to two days of your request."
                )
            )
        ),
        column(
            
        )
    )
)