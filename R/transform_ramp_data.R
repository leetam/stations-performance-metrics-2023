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

# test past four years calculation
# four_years <- seq(from = as.numeric(year("2023-01-01 00:00:00")), 
#                   to = as.numeric(year("2023-01-01 00:00:00"))-3)
# four_months <- seq(from = as.numeric(month("2023-01-01 00:00:00")), 
#                   to = as.numeric(month("2023-01-01 00:00:00"))-3)

min_four_months <- as.Date("2023-01-01") %m-% months(3) 
min_four_weeks <- as.Date("2023-01-01") - weeks(3)

# test filters for historic comparisons
four_years_data <- ramp_data %>%
  filter(year(start_time) %in% four_years)
four_months_data <- ramp_data %>%
  filter(month(start_time) %in% four_months)

filter_df <- ramp_data %>%
  filter(Date >= min_four_months & Date <= "2023-01-01")

test_ramp_df <-ramp_data %>%
  mutate(datetime = make_datetime(2020, month(start_time), day(start_time),
                                  hour(start_time), minute(start_time), second(start_time))
  )

ramp_data_range_filters <- ramp_data %>%
  filter(Date >= "2023-01-01" & Date <= "2023-02-01",
         # dow %in% c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
         # time >= "00:00:00" & time <= "23:00:00",
         resolution == "1 day") %>%
  mutate(datetime = make_datetime(2020, month(start_time), day(start_time), 
                                  hour(start_time), minute(start_time), second(start_time)),
         df = "df1")
  

ramp_data_historic <- ramp_data %>%
  filter(Date >= "2023-03-01" & Date <= "2023-04-01",
         # dow %in% c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
         # time >= "00:00:00" & time <= "23:00:00",
         resolution == "1 day") %>%
  mutate(datetime = make_datetime(2020, month(start_time), day(start_time), 
                                  hour(start_time), minute(start_time), second(start_time)),
         df = "df2")


figure <- ramp_data_range_filters %>%
  ggplot(aes(x = datetime, y = metered_lane_volume)) +
  geom_bar(stat = "identity", fill = "purple") +
  geom_bar(data = ramp_data_historic, aes(y = metered_lane_volume), stat = "identity") +
  theme_bw() +
  xlab(NULL) +
  ylab("Metered Lane Volume") +
  scale_x_datetime(breaks = make_datetime(2020, 1:12), labels = month.abb)
figure

comb_data <- bind_rows(ramp_data_range_filters, ramp_data_historic)

figure2 <- comb_data %>%
  ggplot(aes(x = datetime, y = metered_lane_volume, fill = df, color = factor(year))) +
  geom_bar(stat = "identity", position = "dodge")
figure2
