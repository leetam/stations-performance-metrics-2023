library(dplyr)
library(lubridate)
library(tidyr)

fake_2qnt_df <- function(start_date, end_date, resolution){
  seq_startdate <- paste(as.character(start_date), "00:00:00")
  seq_enddate <- paste(as.character(end_date), "23:59:59")
  start_time <- seq(ymd_hms(seq_startdate), ymd_hms(seq_enddate), resolution)
  quant1 <- floor(runif(start_time, min = 0, max = 200))
  quant2 <- floor(runif(start_time, min = 0, max = 300))
  
  df_a <- bind_cols(start_time, quant1, quant2)
  colnames(df_a) <- c("start_time", "quant1", "quant2")
  df_b <- df_a %>%
    pivot_longer(2:3,
                 names_to = "quantity",
                 values_to = "value")
  
  return(df_b)
}

test_function <- fake_2qnt_df("2022-01-01", "2022-01-04", "hour")

seq_start <- paste(as.character("2022-01-01"), "00:00:00")
seq_end <- paste(as.character("2022-01-04"), "23:59:59")
start_time <- seq(ymd_hms(seq_start), ymd_hms(seq_end), "hour")
quant1 <- floor(runif(length(start_time), min = 0, max = 200))
quant2 <- floor(runif(length(start_time), min = 0, max = 300))

df_test_a <- bind_cols(start_time, quant1, quant2)
colnames(df_test_a) <- c("start_time", "quant1", "quant2")
df_test_a <- df_test_a %>%
  mutate(dow = wday(start_time, label = T),
         year = year(start_time),
         date = ymd(start_time),
         time = hms::as_hms(start_time))


df_test_a$dow <- as.character(df_test_a$dow)
df_test_a$time <- hms::as_hms(df_test_a$time)


df_test_b <- df_test_a %>%
  pivot_longer(cols = 2:3,
               names_to = "quantity",
               values_to = "value")

group_df_a <- df_test_a %>%
  group_by(., time) %>%
  summarise(mean_quant1 = mean(quant1),
            mean_quant2 = mean(quant2)
  )
