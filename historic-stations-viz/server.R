library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(DT)

stations_meta <- readRDS("data/stations_meta.rds")

# Define server logic required to draw a histogram
function(input, output, session) {
  
  stations_df1 <- reactive({
    req(input$stations_daterange)
    stations_meta %>%
      filter(start_date >= input$stations_daterange[1] & end_date <= input$stations_daterange[2])
  })
  
  output$stations_metadata = renderDT(
    stations_df1(),
    filter = "top",
    colnames = c("Highway",
                 "Direction",
                 "Station ID",
                 "Milepost",
                 "Description",
                 "AgencyID",
                 "Start Date",
                 "End Date",
                 "Lon",
                 "Lat",
                 "Agency",
                 "Status"
                 ),
    rownames = F,
    options = list(pageLength = 10,
                   stateSave = T
                   )
  )
  
  


}
