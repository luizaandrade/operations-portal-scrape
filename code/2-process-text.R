# This code process the data obtained from scraping the WB docs portal and saves the datasets that are relevant
# for the different pieces of analysis. Since the processing is slighlty time-consuming, we want to avoid
# repeating the process everytime a new change is made to the analysis

# 1. Settings ==================================================================================================

library(tidyverse)
library(readtext)
library(RColorBrewer)
library(expss)
library(eulerr)

github <- "C:/Users/wb501238/Documents/GitHub/operations-portal-scrape"
path_dt <- file.path(github,"data")
path_txt <- file.path(path_dt, "pad")


theme_bar <-
  theme_void() +
  theme(axis.title.x = element_text())

# 2. Load data =================================================================================================
# Data was scraped from WB docs portal

  # List of ag projects from operations portal
  projects <- read.csv(file.path(path_dt,
                              "ag-projects.csv"),
                    stringsAsFactors = FALSE)

  # txt version of PAD, scraped from WB docs
  projects <- 
    projects %>%
    mutate(doc_id = paste0(id, ".txt"),
           path = file.path(path_txt, doc_id),
           pad = file.exists(path)) 


# 3. Read PADs ===============================================================================================

  # Projects with valid txt files
  txts <-
    projects %>%
    filter(pad == TRUE) %>%
    select(path) %>%
    unlist %>%
    unname
  
  # Read PADs and mark occurrences of the expressions we're interested in
  pads <- 
    readtext(txts) %>%
    mutate(text = 
             str_remove_all(text, "\n") %>% 
             str_trim %>%
             str_to_lower) %>%
    mutate(ie = str_detect(text, "impact evaluation"),
           demo = str_detect(text, "demonstration plot"),
           ext = str_detect(text, "agricultural extension"),
           contact = str_detect(text, "contact farmer"),
           com = (str_detect(text, "commercial") | str_detect(text, "commercialize") | str_detect(text, "commercialization")),
           climate = (str_detect(text, "climate-smart") | str_detect(text, "climate smart") | 
                     str_detect(text, "climate-sensitive") | str_detect(text, "climate sensitive")),
           gender = str_detect(text, "gender") | str_detect(text, "gender-sensitive") | str_detect(text, "gender sensitive"),
           ffs = str_detect(text, "farmer field school") | str_detect(text, "farmers field school"),
           fao = str_detect(text, "food and agriculture organization"))
  
  # Save this dataset, as computation can take a while
  saveRDS(pads,
          file.path(path_dt, 
                    "processed",
                    "pads.RDS"))
  
  # Get a lighter version of the dataset
  light <-
    pads %>%
    select(-text)
  

# 4. Save analysis datasets ===============================================================================

  # 4.1 Constructed dataset: each row is one project, with the dummies for expression occurences ----------
  projects_constructed <-
    projects %>%
    left_join(light) %>%
    select(-c(doc_id, path))
  
  saveRDS(projects_constructed,
          file.path(path_dt, 
                    "processed",
                    "ag-projects-constructed.RDS"))
  
  # 4.2 Year-level dataset: each row is one year (FY of project approval) -------------------------------
  project_long <-
    projects_constructed %>%
    group_by(approvalfy) %>%
    summarise(projects = n(),
              pads = sum(pad, na.rm = T),
              ext = sum(ext, na.rm = T),
              demo = sum(demo, na.rm = T),
              ffs = sum(ffs, na.rm = T),
              fao = sum(fao, na.rm = T),
              gender = sum(gender, na.rm = T),
              climate = sum(climate, na.rm = T),
              com = sum(com, na.rm = T),
              contact = sum(contact, na.rm = T)) %>%
    rename(year = approvalfy) %>%
    pivot_longer(cols = c(ext, demo, ffs, fao, gender, climate, com, contact),
                 values_to = "count",
                 names_to = "expression") %>%
    mutate(pct = (count/pads)*100,
           expression = factor(expression))
  
  # Label factors
  project_long$expression <-
    project_long$expression %>%
    fct_recode( "Agricultural extension" =	"ext",
                "Demonstration plot" = "demo",
                "Farmer field school" = "ffs",
                "FAO" = "fao",
                "Gender" = "gender",
                "Climate" = "climate",
                "Commercialization" = "com",
                "Contact farmer" = "contact" )
    
  # Label variables
  project_long <-
    project_long %>%
    apply_labels(year = "Fiscal year when project was approved",
                 pads = "Number of projects with PAD available",
                 projects = "Number of projects listed in operations portal",
                 expression = "Component",
                 pct = "Percent of projects that mention component in PAD")
  
  # Save complete dataset
  saveRDS(project_long,
          file.path(path_dt, 
                    "processed", 
                    "ag-projects-summary.RDS"))
  
  # Save with only relevant years
  project_year <- 
    project_long %>%
    filter(year >= 1990,
           year <= 2020)
  
  saveRDS(project_year,
          file.path(path_dt, 
                    "processed",
                    "ag-projects-year-summary.RDS"))
  


  # 4.3 Region-level dataset: each row is one WB region =================================================
  
  projects_region <-
    projects_constructed %>%
    filter(approvalfy >= 1990,
           approvalfy <= 2020) %>%
    group_by(region) %>%
    summarise(pads = sum(pad, na.rm = T),
              ext = sum(ext, na.rm = T),
              demo = sum(demo, na.rm = T),
              ffs = sum(ffs, na.rm = T),
              fao = sum(fao, na.rm = T),
              contact = sum(contact, na.rm = T)) %>%
    pivot_longer(cols = c(ext, demo, ffs, fao, contact),
                 values_to = "count",
                 names_to = "expression") %>%
    mutate(pct = (count/pads)*100,
           expression = factor(expression)) %>%
    select(-pads) %>%
    filter(region != "Other")
  
  # Label factor
  projects_region$expression <-
    projects_region$expression %>%
    fct_recode( "Agricultural extension" =	"ext",
                "Demonstration plot" = "demo",
                "Farmer field school" = "ffs",
                "FAO" = "fao",
                "Contact farmer" = "contact" )
  
  # Label variables
  projects_region <-
    projects_region %>%
    apply_labels(expression = "Component",
                 pct = "Percent of projects that mention component in PAD")
  
  saveRDS(projects_region,
          file.path(path_dt, 
                    "processed",
                    "ag-projects-region-summary.RDS"))
  
  
  # 4.3 Component value sumary: each row is one  component =======================================
  # Show median and mean value of projects in period of interest
  
  projects_value <-
    projects_constructed %>%
    filter(approvalfy >= 1990,
           approvalfy <= 2020) %>%
    pivot_longer(cols = c(ext, demo, ffs, fao, gender, climate, com, contact),
                 names_to = "expression",
                 values_to = "included") %>%
    filter(included == TRUE & !is.na(included)) %>%
    select(netcommitment, expression) %>%
    mutate(expression = factor(expression),
           netcommitment = as.numeric(netcommitment)) %>%
    group_by(expression) %>%
    summarise(median = median(netcommitment, na.rm = T),
              total = sum(netcommitment, na.rm = T)) 
  
  # Label factors
  projects_value$expression <-
    projects_value$expression %>%
    fct_recode( "Agricultural extension" =	"ext",
                "Demonstration plot" = "demo",
                "Farmer field school" = "ffs",
                "FAO" = "fao",
                "Gender" = "gender",
                "Climate" = "climate",
                "Commercialization" = "com",
                "Contact farmer" = "contact")
  
  # Label variables
  projects_value <-
    projects_value %>%
    apply_labels(expression = "Component",
                 median = "Million USD",
                 total = "Million USD")
  
  saveRDS(projects_value,
          file.path(path_dt, 
                    "processed",
                    "ag-projects-value-summary.RDS"))
  