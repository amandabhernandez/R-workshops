### Author: AHz
### Date: 10/11/2022
### Purpose: Mini-Project 3


# set working directory to file location
source_file_loc <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(source_file_loc)

#install.packages("pacman")
library(pacman)
p_load(tidyverse)
p_load(janitor)
p_load(lubridate)
p_load(viridis)




###############################################################################
# 1. LOAD AND CLEAN DATA   #########################################
###############################################################################

hobo_raw <- read_csv("hobo_dat/EH263-H11.csv", skip = 1)

hobo_clean <- hobo_raw %>% 
  clean_names() %>% 
  rename_all(~str_remove_all(., "_lgr.*")) %>% 
  rename_with(~"date_time", contains("date_time")) %>% 
  select(number:rh_percent) %>% 
  mutate(date_time = mdy_hms(date_time),
         # date = ymd(str_remove_all(as.character(date_time), "\\d*:\\d*:\\d*")), 
         # time = hms(str_extract(as.character(date_time), "\\d*:\\d*:\\d*")),
         month = month(date_time),
         day = day(date_time),
         hour = hour(date_time),
         minute = minute(date_time)) %>% 
  filter(date_time > mdy_hms("10-05-22 06:40:00") & date_time < mdy_hms("10-11-22 12:00:00"))

class_hobo <- read_csv("20052699_PILOT.csv", skip = 1) %>% 
  clean_names() %>% 
  rename_all(~str_remove_all(., "_lgr.*")) %>% 
  rename_with(~"date_time", contains("date_time")) %>% 
  select(date_time:co2_ppm) %>% 
  mutate(date_time = mdy_hms(date_time))


###############################################################################
# 2. DATA EXPLORATION  #########################################
###############################################################################


#are there any gaps? 

hobo_gaps <- hobo_clean %>% 
  mutate(rec_after = lead(date_time, order_by = date_time, 
                          default = max(date_time)),
         check_lag = minute - lag(minute(rec_after)))

table(hobo_gaps$check_lag, useNA = "ifany")
#all lag = 0, 1 NA for first measurement -- all good!
  

# make hobo data long 

hobo_long <- hobo_clean %>% 
  pivot_longer(names_to = "metric", values_to = "indoor_value", temp_f:rh_percent)


# plot hobo data 
hobo_plot <- ggplot(hobo_long,
       aes(x = date_time, y = indoor_value, color = metric)) +
  geom_line() + 
  scale_color_viridis(discrete = TRUE, end = 0.75, direction = -1) + 
  scale_x_datetime(labels = scales::date_format("%m/%d")) + 
  theme_bw() + 
  xlab("Date") + 
  ylab("") + 
  theme(legend.position = "none", 
        axis.text = element_text(size=14),
        strip.text = element_text(size = 16, face = "bold")) +
  facet_wrap(~metric, scales = "free_y", nrow = 2)


plotly::ggplotly(hobo_plot)


###############################################################################
# Q4  #########################################
###############################################################################

# load, clean, and merge weather data


weather <- readxl::read_xlsx("weather.xlsx") %>% 
  mutate(time = hms(str_extract(as.character(Time), "\\d*:\\d*:\\d*")),
         date_time = ymd_hms(paste0(Date, " ", str_extract(as.character(Time), "\\d*:\\d*:\\d*"))),
         month = month(date_time),
         day = day(date_time),
         hour = hour(date_time),
         Temperature = as.numeric(str_extract(Temperature, "\\d*")),
         Humidity = as.numeric(str_extract(Humidity, "\\d*"))) %>% 
  select(date_time, Date, time:hour, Temperature, Humidity) %>% 
  rename(temp_outdoor = Temperature, 
         hum_outdoor = Humidity)


weather_long <- weather %>% 
  pivot_longer(names_to = "metric", values_to = "outdoor_value", temp_outdoor:hum_outdoor) %>% 
  mutate(metric = factor(metric, levels = c("temp_outdoor", "hum_outdoor"),
                         labels = c("Temperature (F)", "Relative Humidity (%)")))



indoor_outdoor <- hobo_long %>% 
  # group_by(month, day, hour, metric) %>%
  # summarize(indoor_value = mean(indoor_value)) %>%
  left_join(weather_long %>% 
              select(-date_time, -time, -Date), 
            by = c("month", "day", "hour", "metric"))








###############################################################################
# GARBAGE <3 ###################
###############################################################################



hobofiles <- list.files("hobo_dat", full.names = TRUE)
hobo_list <- list()

for (file in hobofiles){
  
  hobo_dat <- read.csv(file, skip = 1) 
  
  hobo_num <- str_extract(file, "(?<=EH263-)H\\d*")
  hobo_list[[hobo_num]] <- hobo_dat %>% 
    clean_names() %>% 
    rename_all(~str_remove_all(., "_lgr.*")) %>% 
    rename_with(~"date_time", contains("date_time")) %>% 
    select(number:rh_percent) %>% 
    mutate(date_time = mdy_hms(date_time),
           month = month(date_time),
           day = day(date_time),
           hour = hour(date_time),
           minute = minute(date_time))
}

hobo_all <- bind_rows(hobo_list, .id = "num") %>% 
  mutate(date_time = mdy_hms(date_time)) %>% 
  filter(date_time > mdy_hms("10-05-22 00:00:00") & date_time < mdy_hms("10-11-22 00:00:00")) %>% 
  mutate(month = month(date_time),
         day = day(date_time),
         hour = hour(date_time),
         minute = minute(date_time))

hobo_long_all <- hobo_all %>% 
  pivot_longer(names_to = "metric", values_to = "indoor_value", temp_f:rh) %>% 
  mutate(metric = factor(metric, levels = c("temp_f", "rh"),
                         labels = c("Temperature (F)", "Relative Humidity (%)")))


ideal_range <- data.frame(metric = c("Temperature (F)", "Relative Humidity (%)"),
                          indoor_value = c(67, 30, 82, 50),
                          low  = c(67, 30),
                          high = c(82, 50), 
                          date_time = rep(c(min(hobo_long_all$date_time), max(hobo_long_all$date_time)), 2),
                          num = NA)

ggplot(hobo_long_all,
       aes(x = date_time, y = indoor_value, color = num)) +
  geom_line() +
  geom_rect(data=ideal_range, mapping=aes(ymin = low,
                                          ymax= high,
                                          xmin=min(hobo_long_all$date_time), xmax = max(hobo_long_all$date_time)),
            alpha = 0.25, fill = "darkseagreen", inherit.aes=FALSE) +
  # geom_line(data = weather_long, mapping = aes(x = date_time, y = outdoor_value), color = "red") + 
  scale_color_viridis(discrete = TRUE, direction = -1) + 
  scale_x_datetime(labels = scales::date_format("%m/%d")) + 
  theme_bw() + 
  xlab("Date") + 
  ylab("") + 
  theme(legend.title = element_blank(),
        legend.text = element_text(size = 14), 
        axis.text = element_text(size=14),
        strip.text = element_text(size = 16, face = "bold")) + 
  facet_wrap(~metric, scales = "free_y", nrow = 2)
