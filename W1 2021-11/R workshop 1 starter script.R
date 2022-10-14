### Author: your name here! 
### Date: 11/18/2021
### Purpose: learn R together! workshop 1 :) 


# set working directory to file location
source_file_loc <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(source_file_loc)

install.packages("tidyverse")
library(tidyverse)


beyonce_tswift_lyrics <- read_csv("data/beyonce_tswift_lyrics_full.csv")

beyonce_tswift_lyrics_sep <- read_csv("data/beyonce_tswift_lyrics_sep.csv")


# how many unique songs does each artist have? 
length(unique(beyonce_tswift_lyrics$song_name))

beyonce_tswift_wordcounts <- beyonce_tswift_lyrics_sep %>% 
  group_by(artist_name, words) %>% 
  count(sort = TRUE)

beyonce_tswift_mostfreq <-  beyonce_tswift_wordcounts %>% 
  mutate(words = textclean::replace_contractions(words))
  #filter out "stop" words 
  filter(!words %in% c("a", "and", "the", "it", "to", 
                       "of", "that", "but", "in")) %>% 
  arrange(desc(n)) %>% 
  group_by(artist_name) %>% 
  slice(1:10)

# plot it 
ggplot(beyonce_tswift_mostfreq, aes(x = words, y = n, fill = words)) + 
  geom_bar(stat = "identity") + 
  theme(legend.position = "blank") + 
  facet_wrap(~artist_name, scales = "free")


#how often do taylor and beyonce use "i" and "you" ? 
beyonce_tswift_you_i <- beyonce_tswift_lyrics_sep %>% 
  textclean::replace
  filter(words %in% c("you", "i")) 


#install.packages("janitor")
library(janitor)

#create a 2x2 table of "you" and "i" frequencies 
tabyl(beyonce_tswift_you_i, artist_name, words) %>% 
  adorn_percentages() %>% 
  adorn_pct_formatting(digits = 2) %>% 
  adorn_ns() 

#try adding/removing a pipe and swap/add the following functions: 
 # adorn_percentages()
 # adorn_totals()
 # adorn_title()