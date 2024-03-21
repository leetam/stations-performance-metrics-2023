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
         source = "ATR") %>%
  select(locationtext,
         highway,
         direction,
         milepost,
         numberlanes = no_lanes,
         agencyid = agency_station_id,
         lon = longitude,
         lat = latitude,
         source,
         agency,
         region,
         lrs_id)

atr_meta_table <- atr_stations_meta %>%
  mutate(
    start_date = "",
    rampid = "",
    stationid = seq(from = 20000, to = 20353)
  ) %>%
  select(
    stationid,
    agencyid,
    milepost,
    locationtext,
    numberlanes,
    agency,
    highway,
    direction,
    source,
    start_date,
    rampid,
    lon,
    lat
  )
  
map_meta <- readRDS("data/map_meta.rds")

its_agency_id <- its_stations_meta %>%
  select(stationid, agencyid)

its_meta_table <- map_meta %>%
  mutate(source = if_else(agency == "ODOT", "ITS", "")) %>%
  left_join(its_agency_id, by = "stationid") %>%
  select(
    stationid,
    agencyid,
    milepost,
    locationtext,
    numberlanes,
    agency,
    highway = highwayname,
    direction,
    source,
    start_date,
    rampid = ramp_devices,
    lon,
    lat
  )

all_meta <- bind_rows(atr_meta_table, its_meta_table) %>%
  arrange(highway) %>%
  filter(!is.na(lat),
         !lat %in% c(-1, 0))

saveRDS(all_meta, "data/atr_its_map_meta.rds")
