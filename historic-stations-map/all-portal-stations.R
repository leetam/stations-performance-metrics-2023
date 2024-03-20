library(leaflet)
library(dplyr)
library(tidyr)
library(lubridate)

#### clean-up metadata
raw_stations <- read.csv("historic-stations-map/data/stations-metadata.csv", stringsAsFactors = F)
raw_highways <- read.csv("historic-stations-map/data/highways-metadata.csv", stringsAsFactors = F)

highways <- raw_highways %>%
  select(highwayid, highwayname, direction)

stations <- raw_stations %>%
  left_join(highways, by = "highwayid") %>%
  select(highwayname, direction, stationid, milepost, locationtext,
         agencyid, start_date, end_date, lon, lat, agency)

stations$start_date <- ymd_hms(stations$start_date, tz = "US/Pacific")
stations$end_date <- ymd_hms(stations$end_date, tz = "US/Pacific")

stations <- stations %>%
  mutate(status = if_else(!is.na(end_date), "historic", "current")) %>%
  filter(!is.na(lon),
         !is.na(lat),
         lon != -1,
         lat != -1)
saveRDS(stations, "data/all-stations-meta.rds")

#### create map
# pal <- colorFactor(
#   palette = c("blue", "green"),
#   domain = stations$status
# )

maxlng <- max(stations$lon)
minlng <- min(stations$lon)
maxlat <- max(stations$lat)
minlat <- min(stations$lat)

historic <- stations %>%
  filter(status == "historic") %>%
  as.data.frame()
current <- stations %>%
  filter(status == "current") %>%
  as.data.frame()

map_v1 <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  fitBounds(minlng, minlat, maxlng, maxlat) %>%
  addCircleMarkers(
    data = current,
    lng = stations$lon,
    lat = stations$lat,
    clusterOptions = markerClusterOptions(maxClusterRadius = 2),
    popup = paste("Highway: ", stations$highwayname, "<br>",
                  "Direction: ", stations$direction, "<br>",
                  "Milepost: ", stations$milepost, "<br>",
                  "Description: ", stations$locationtext, "<br>",
                  "Status: ", stations$status, "<br>",
                  "Active Dates: ", stations$start_date, " - ", stations$end_date
                  ),
    color = "green",
    group = "Current"
  ) %>%
  addCircleMarkers(
    data = historic,
    lng = stations$lon,
    lat = stations$lat,
    clusterOptions = markerClusterOptions(maxClusterRadius = 2),
    popup = paste("Highway: ", stations$highwayname, "<br>",
                  "Direction: ", stations$direction, "<br>",
                  "Milepost: ", stations$milepost, "<br>",
                  "Description: ", stations$locationtext, "<br>",
                  "Status: ", stations$status, "<br>",
                  "Active Dates: ", stations$start_date, " - ", stations$end_date
    ),
    color = "blue",
    group = "Historic"
  ) %>%
  addLayersControl(position = "topleft", overlayGroups = c("Historic", "Current")) %>%
  hideGroup("Historic")

map_v1
