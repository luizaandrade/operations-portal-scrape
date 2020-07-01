 
  projects <- read.csv(file.path(path_dt,
                              "ag-projects.csv"),
                    stringsAsFactors = FALSE)

  projects <- 
    projects %>%
    mutate(doc_id = paste0(id, ".txt"),
           path = file.path(path_txt, doc_id),
           pad = file.exists(path)) 

  txts <-
    projects %>%
    filter(pad == TRUE) %>%
    select(path) %>%
    unlist %>%
    unname
  
  
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
  
  light <-
    pads %>%
    select(-text)
  
  projects_constructed <-
    projects %>%
    left_join(light) %>%
    select(-c(doc_id, path))
  
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
    
  project_long <-
    project_long %>%
    apply_labels(year = "Fiscal year when project was approved",
                 pads = "Number of projects with PAD available",
                 projects = "Number of projects listed in operations portal",
                 expression = "Component",
                 pct = "Percent of projects that mention component in PAD")

  project_year <- 
    project_long %>%
    filter(year >= 1990,
           year <= 2020)
  
  saveRDS(project_year,
          file.path(path_dt, "ag-projects-year-summary.RDS"))
  
  saveRDS(projects_constructed,
          file.path(path_dt, 
                    "ag-projects-constructed.RDS"))
  saveRDS(project_long,
          file.path(path_dt, 
                    "ag-projects-summary.RDS"))
  saveRDS(pads,
          file.path(path_dt, "pads.RDS"))
  
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
    pivot_longer(cols = c(ext, demo, ffs, fao, gender, climate, com, contact),
                 values_to = "count",
                 names_to = "expression") %>%
    mutate(pct = (count/pads)*100,
           expression = factor(expression)) %>%
    select(-pads) %>%
    filter(region != "Other")
  
  projects_region$expression <-
    projects_region$expression %>%
    fct_recode( "Agricultural extension" =	"ext",
                "Demonstration plot" = "demo",
                "Farmer field school" = "ffs",
                "FAO" = "fao",
                "Contact farmer" = "contact" )
  
  projects_region <-
    projects_region %>%
    apply_labels(expression = "Component",
                 pct = "Percent of projects that mention component in PAD")
  
  saveRDS(projects_region,
          file.path(path_dt, "ag-projects-region-summary.RDS"))
  
  
  
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
  
  projects_value <-
    projects_value %>%
    apply_labels(expression = "Component",
                 median = "Million USD",
                 total = "Million USD")
  
  saveRDS(projects_value,
          file.path(path_dt, "ag-projects-value-summary.RDS"))
  