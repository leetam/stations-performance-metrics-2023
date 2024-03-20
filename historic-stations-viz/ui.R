library(shinydashboard)
library(shiny)
library(leaflet)
library(DT)


header <- dashboardHeader(title = "Historic PORTAL Stations Map DRAFT",
                          titleWidth = 450)

body <- dashboardBody(
  fluidRow(
    column(
      width = 2,
      box(
        width = NULL,
        p(
          "PORTAL only displays data from active stations recording data. If you're looking for a recently deactivated or historic station, use the table to filter and search for your station(s) of interest. Please note that prior to 2023, many of the ODOT station locations were tied to cabinet locations, not the location of the actual detectors. Once you've identified the station(s) of interest, please send us a .csv or .txt file of those stations (use the Download Table button below), and include in your email the date range and resolution, and we will pull that data for you within one to two days of your request."
        )
      ),
      # box(
      #   width = NULL,
      #   dateRangeInput(
      #     "stations_daterange",
      #     label = "Date Range:",
      #     start = "2012-03-01",
      #     end = Sys.Date(),
      #     min = "2012-03-01",
      #     max = Sys.Date()
      #   )
      # ),
      box(
        width = NULL,
        downloadButton(
          "table_download",
          label = "Download Metadata Table"
        )
      )
    ),
    column(
      width = 10,
      box(
        width = 12,
        solidHeader = T,
        leafletOutput("stations_map",
                      height = 600)
      )
      # box(
      #   width = NULL,
      #   solidHeader = T,
      #   leafletOutput("stations_map",
      #                 height = 600)
      # )
    )
  ),
  fluidRow(
    box(
      width = NULL,
      solidHeader = T,
      label = "Stations Metadata",
      DTOutput("meta_table")
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = T),
  body
)