library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(DT)

stations_meta <- readRDS("data/stations_meta.rds")

# Define server logic required to draw a histogram
function(input, output, session) {
  
  # stations_df1 <- reactive({
  #   req(input$stations_daterange)
  #   stations_meta %>%
  #     filter(start_date >= input$stations_daterange[1] & end_date <= input$stations_daterange[2])
  # })
  
  output$meta_table = renderDT({
    datatable(
      stations_meta,
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
                     stateSave = F
                     )
    )
  })
  
  # output$stations_metadata <- renderDT({
  #   datatable(stations_meta, filter = "top")
  # })
  
  filtered_table <- reactive({
    req(input$meta_table_rows_all)
    stations_meta[input$meta_table_rows_all, ]
  })
  
  output$stations_map <- renderLeaflet({
    filtered_table() %>%
      leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(
        lng = filtered_table()$lon,
        lat = filtered_table()$lat,
        clusterOptions = markerClusterOptions(maxClusterRadius = 2)
      )
  })
  
  output$table_download <- downloadHandler(
    filename = function(){"stations_metadata.csv"},
    content = function(fname){
      write.csv(filtered_table(), fname, row.names = F)
    }
  )


}
