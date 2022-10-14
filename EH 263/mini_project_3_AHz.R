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

hobo_raw <- read_csv("EH263-H12.csv", skip = 1)


hobo_clean <- hobo_raw %>% 
  clean_names() %>% 
  rename_all(~str_remove_all(., "_lgr.*")) %>% 
  rename_with(~"date_time", contains("date_time")) %>% 
  select(number:rh_percent) %>% 
  mutate(date_time = mdy_hms(date_time)) %>% 
  filter(date_time > mdy_hms("10-05-22 06:40:00") & date_time < mdy_hms("10-11-22 12:00:00")) %>% 
  mutate(month = month(date_time),
         day = day(date_time),
         hour = hour(date_time),
         minute = minute(date_time))


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
  


hobo_long <- hobo_clean %>% 
  pivot_longer(names_to = "metric", values_to = "value", temp_f:rh_percent)



###############################################################################
# 3. PLOT   #########################################
###############################################################################


hobo_plot <- ggplot(hobo_long,
       aes(x = date_time, y = value, color = metric)) +
  geom_line() + 
  scale_color_viridis(discrete = TRUE, end = 0.75, direction = -1) + 
  scale_x_datetime(labels = scales::date_format("%m/%d")) + 
  theme_bw() + 
  theme(legend.title = element_blank(),
        legend.text = element_text(size = 14), 
        axis.text = element_text(size=14),
        strip.text = element_text(size = 16, face = "bold"))


plotly::ggplotly(hobo_plot)
