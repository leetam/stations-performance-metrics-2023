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
    yAxis = 0
    ) %>%
  hc_add_series(
    type = "line",
    subdatax[, "speed"],
    yAxis = 1
  )
onequant
