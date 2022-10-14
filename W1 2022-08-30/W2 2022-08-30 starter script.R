### Author: your name here! 
### Date: 9/1/2022
### Purpose: learn R together! workshop 1 :) 


# set working directory to file location
source_file_loc <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(source_file_loc)

#install.packages("pacman")
library(pacman)
p_load(tidyverse)



###############################################################################
# 1. LOAD DATA   ##############################################################
###############################################################################

collegiate_sports_raw <- read_csv("collegiate_sports_raw.csv")
sports_clean <- read_csv("sports_clean.csv")
school_enrollment <- read_csv("school_enrollment.csv")





###############################################################################
# 2. XXXXXXXXX   ##############################################################
###############################################################################

length(unique(sports_clean$year))

length(unique(sports_clean$unitid))

setdiff(sports_clean$unitid, school_enrollment$unitid)

class(sports_clean$unitid)

haverford_sports <- sports_clean %>% 
  filter(str_detect(institution_name, "Haverford")) %>% 
  mutate(sports = case_when(sports %in% c("Baseball", "Softball") ~ "Baseball and Softball",
                            TRUE ~ sports))
  #filter(institution_name == "Haverford College")



haverford_enroll <- school_enrollment %>% 
  filter(str_detect(institution_name, "Haverford"))


haverford_enroll_summary <- haverford_enroll %>% 
  group_by(year) %>% 
  summarize(perc_men = enrollment[which(gender == "men")]/enrollment[which(gender == "menwomen")],
            perc_women = enrollment[which(gender == "women")]/enrollment[which(gender == "menwomen")])


haverford_sports_summary <- haverford_sports %>% 
  group_by(year, sports) %>% 
  summarize(men_partic = sum(partic[which(gender == "men")], na.rm = TRUE),
            women_partic = sum(partic[which(gender == "women")], na.rm = TRUE),
            perc_men = men_partic/sum(men_partic, women_partic),
            perc_women = women_partic/sum(men_partic, women_partic),)


unique(haverford_sports$sports)
