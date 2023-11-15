library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)

ramp_raw <- read.csv("data/ramp_data_1021.csv", stringsAsFactors = F)

ramp_dates <- ramp_raw %>%
  separate(col = start_time,
           into = c("Date", "Time"),
           sep = " ",
           remove = F) %>%
  separate(col = Time,
           into = c("time", "tz"),
           sep = "-") %>%
  select(-tz)

ramp_dates$start_time <- ymd_hms(ramp_raw$start_time, tz = "US/Pacific")

ramp <- ramp_dates %>%
  mutate(dow = wday(start_time, label = T),
         year = year(start_time))
ramp$dow <- as.character(ramp$dow)
ramp$Date <- as.Date(ramp$Date)
ramp$time <- hms::as_hms(ramp$time)

saveRDS(ramp, "data/ramp.rds")

hours <- ramp %>%
  distinct(time)

# saveRDS(hours, "data/hours.rds")
