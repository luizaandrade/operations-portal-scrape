
  fao_projects <-
    projects %>%
    filter(fao == TRUE) %>%
    select(id) %>%
    unlist %>%
    unname
  
  ffs_projects <-
    projects %>%
    filter(ffs == TRUE) %>%
    select(id) %>%
    unlist %>%
    unname
  
  euler <- list(`Farmer field school` = ffs_projects,
                `FAO` = fao_projects)