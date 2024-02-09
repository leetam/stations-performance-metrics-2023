library(dplyr)
library(tidyr)
library(highcharter)
library(htmlwidgets)
library(xts)

data <- readRDS("data/data_example_lane.rds")
subdata <- data %>%
  filter(detector_id == 100192,
         resolution == "1 day",
         year == 2021) %>%
  select(starttime, volume, speed)
subdatax <- as.xts(subdata)

# datareorder <- data[, c(2, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)]
# dataxts <- xts(datareorder[,-1], order.by = datareorder$starttime)
# saveRDS("data/data_ex_lane_xts.rds")
# 
# subdataxx <- subdatax %>%
#   filter(detector_id == 100192,
#          resolution == "1 day",
#          year == 2021)

onequant <- highchart(type = "chart") %>%
  hc_yAxis_multiples(
    list(lineWidth = 2,
         opposite = FALSE),
    list(showLastLabel = FALSE,
         opposite = TRUE)
    ) %>%
  hc_add_series(
    subdatax[, "volume"],
    type = "column",
    yAxis = 0,
    name = "Volume"
    ) %>%
  hc_add_series(
    type = "line",
    subdatax[, "speed"],
    yAxis = 1,
    name = "Speed"
  ) %>%
  hc_xAxis(dateTimeLabelFormats = list(day = "%m %Y"), type = "datetime")
onequant

onequant2 <- hchart(type = "chart") %>%
  hc_yAxis_multiples(
    list(lineWidth = 2,
         opposite = FALSE),
    list(showLastLabel = FALSE,
         opposite = TRUE)
  ) %>%
  hc_add_series(
    subdata,
    hcaes(x = starttime, y = volume),
    type = "column",
    yAxis = 0
  ) %>%
  hc_add_series(
    type = "line",
    subdata,
    hcaes(x = starttime, y = speed),
    yAxis = 1
  ) %>%
  hc_xAxis(dateTimeLabelFormats = list(day = "%m %Y"), type = "datetime")
onequant2


selected_lane_data <- lane_data %>%
  filter(detector_id == 100192) %>%
  select(starttime, resolution, date, time, dow,
         vmt, occupancy) %>%
  filter(
    date >= "2023-02-01" & date <= "2023-02-26",
    dow %in% c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
    time >= format("00:00:00", format = "%H:%M:%S") & time <= format("23:59:59", format = "%H:%M:%S"),
    resolution == "01:00:00") %>%
  select(-resolution, -date, -time, -dow)
selected_lane_data_xts <- as.xts(selected_lane_data)
