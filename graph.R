
  library(VennDiagram)

  process_projects <- 
    readRDS(file.path(data, "ag-projects-with-dummies.RDS")) %>%
    mutate(id = str_remove(doc_id, ".txt")) %>%
    select(-doc_id)

  demo <-
    process_projects %>%
    mutate(`Demonstration plots` = ifelse(demo == TRUE, id, NA)) %>%
    select(`Demonstration plots`) %>%
    filter(!is.na(`Demonstration plots`)) %>%
    unlist %>%
    unname
      
  ext <-
    process_projects %>%
    mutate(`Agricultural extension` = ifelse(ext == TRUE, id, NA)) %>%
    select(`Agricultural extension`) %>%
    filter(!is.na(`Agricultural extension`)) %>%
    unlist %>%
    unname
  
  contact <-
    process_projects %>%
    mutate(`Contact farmer` = ifelse(contact == TRUE, id, NA)) %>%
    select(`Contact farmer`) %>%
    filter(!is.na(`Contact farmer`)) %>%
    unlist  %>%
    unname
  
  ffs <-
    process_projects %>%
    mutate(`Farmer field school` = ifelse(ffs == TRUE, id, NA)) %>%
    select(`Farmer field school`) %>%
    filter(!is.na(`Farmer field school`)) %>%
    unlist %>%
    unname
  
  
  venn.diagram(
    x = list(ffs, 
             demo, 
             ext, 
             contact),
    category.names = c("Farmer field school",
                       "Demonstration plots", 
                       "Agricultural extension",
                       "Contact farmer"),
    filename = "C:/Users/wb501238/Downloads/text.png",
    output = TRUE
    )

  aggregate <-
    process_projects %>%
    group_by(demo, ext, contact, ffs) %>%
    summarise(count = n())

  library(eulerr)
  
  euler <- list(`Demonstration plot` = demo,
                `Farmer field school` = ffs,
                `Agricultural extension` = ext,
                `Contact farmer` = contact)
  cmyk = c(rgb(237, 43, 140, max = 255), 
           rgb(1, 174, 240, max = 255), 
           rgb(242, 230, 0, max = 255),
           "white")
  
  rgb =  c(rgb(0,255,0, max = 255), 
           rgb(0,0,255, max = 255), 
           rgb(255,0,0, max = 255),
           "white")
  
  pastel = c(rgb(44,187,193, max = 255), 
           rgb(255,115,28, max = 255), 
           rgb(205,51,1, max = 255), 
           "gray88",
           rgb(42,168,43, max = 255),
           rgb(43,112,171, max = 255),
           "white",
           rgb(255,176,39, max = 255),
           "white",
           rgb(205, 1, 155, max = 255),
           rgb(40,66,117, max = 255),
           "white",
           "white",
           rgb(255,230,39, max = 255))
  
  plot(euler(euler, 
             shape = "ellipse"),
       fills = list(fill = pastel, 
                    alpha = .8),
       edges = FALSE,
       legend = TRUE,
       quantities = list(fontefamily = "mono",
                         font = 2),
       counts = TRUE)
  
  