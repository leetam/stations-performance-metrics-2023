library(dplyr)
library(tidyr)
library(readxl)

raw_atr_meta <- read_excel("draft-atr/data/location_lane599.xlsx")

atr_meta_highway <- raw_atr_meta %>%
  select(agencyid = Local_ID,
         description = OnRoad,
         onroadroute = OnRoadRoute,
         onroadroutetype = OnRoadRouteType,
         lanes = Direction,
         lrs_id = LRS_ID,
         milepost = LRS_LOC_PT,
         district = District,
         latitude = Latitude,
         longitude = Longitude,
         region = District
         ) %>%
  mutate(highway = paste0(onroadroutetype, onroadroute), 
         direction = case_when(grepl("NB", agencyid, ignore.case = T) ~ "NORTH",
                               grepl("SB", agencyid, ignore.case = T) ~ "SOUTH",
                               grepl("WB", agencyid, ignore.case = T) ~ "WEST",
                               grepl("EB", agencyid, ignore.case = T) ~ "EAST",
                               .default = "other"
                               )
  )

atr_stations_meta <- atr_meta_highway %>%
  separate_wider_delim(agencyid, delim = "_", names = c("lrsid", "laneno", "bound")) %>%
  mutate(agency_station_id = paste0(lrsid, "_", bound)) %>%
  group_by(agency_station_id) %>%
  mutate(no_lanes = n()) %>%
  distinct(agency_station_id,
           .keep_all = T) %>%
  as.data.frame() %>%
  mutate(locationtext = paste(description, agency_station_id),
         agency = "ODOT",
         agencyid = agency_station_id,
         detectortype = "ATR") %>%
  select(locationtext,
         highway,
         direction,
         milepost,
         numberlanes = no_lanes,
         agencyid = agency_station_id,
         lon = longitude,
         lat = latitude,
         detectortype,
         agency,
         region,
         lrs_id)
  
atr_detectors_meta <- atr_meta_highway %>%
  