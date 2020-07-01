
  library(tidyverse)
  library(readtext)
  library(RColorBrewer)
  library(expss)
  library(eulerr)
  
  
  path_dt <- file.path("C:/Users/wb501238/WBG/Maria Ruth Jones - DIME Analytics/Operations portal scraping/data")
  path_txt <- file.path("C:/Users/wb501238/WBG/Maria Ruth Jones - DIME Analytics/Operations portal scraping/pad")

  
  theme_bar <-
    theme_void() +
    theme(axis.title.x = element_text())
  
    
  