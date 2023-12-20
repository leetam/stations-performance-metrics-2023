library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)

raw_agg_data <- read.csv("data/freeway_data_1021-10707.csv", stringsAsFactors = F)

data <- raw_agg_data %>%
  separate(col = starttime,
           into = c("date", "Time"),
           sep = " ",
           remove = F) %>%
  separate(col = Time,
           into = c("time", "tz"),
           sep = "-") %>%
  select(-tz, -id)
 
data$starttime <- ymd_hms(data$starttime, tz = "US/Pacific")

data <- data %>%
  mutate(dow = wday(starttime, label = T),
         year = year(starttime))

data$dow <- as.character(data$dow)
data$Date <- as.Date(data$date)
data$time <- hms::as_hms(data$time)

data_example_lane <- data %>%
  filter(detector_id %in% c(100192, 100193)) %>%
  mutate(lane_no = if_else(detector_id == 100192, 2, 1))
# saveRDS(data_example_lane, "data/data_example_lane.rds")

data_example_station <- data %>%
  group_by(resolution, starttime) %>%
  summarise(
    total_volume = sum(volume),
    mean_volume = mean(volume),
    mean_speed = mean(speed),
    mean_occupany = mean(occupancy),
    mean_vmt = mean(vmt),
    mean_vht = mean(vht),
    mean_delay = mean(delay),
    mean_traveltime = mean(traveltime)
  ) %>%
  as.data.frame() %>%
  mutate(dow = wday(starttime, label = T),
         year = year(starttime))

data_example_station <- data_example_station %>%
  separate(col = starttime,
           into = c("date", "time"),
           sep = " ",
           remove = F)

data_example_station$dow <- as.character(data_example_station$dow)
data_example_station$time <- hms::as_hms(data_example_station$time)
data_example_station$date <- as.Date(data_example_station$date)

# saveRDS(data_example_station, "data/data_example_station.rds")

speed_lane_fig <- data_example_lane %>%
  filter(year == 2023,
         resolution == "1 day") %>%
  select(lane_no, starttime, time, Date, speed, volume) %>%
  pivot_longer(cols = c("speed", "volume"), names_to = "quantity", values_to = "value") %>%
  ggplot(aes(x = Date, y = value, color = quantity)) +
  geom_line(stat = "identity") +
  facet_grid(quantity ~ lane_no, scales = "free_y") +
  theme_bw()
speed_lane_fig
