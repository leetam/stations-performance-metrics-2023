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
