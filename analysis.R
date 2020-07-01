  
  
  data <- 
    readRDS(file.path(path_dt, 
                      "ag-projects-summary.RDS"))
  
  line_graph <-
    function(x) {
      use_labels(x,
                 ggplot(data = x,
                        aes(x = year,
                            y  = pct,
                            color = expression)) + 
                   geom_line(size = 1) + 
                   geom_point(shape = 21,
                              size = 2,
                              fill = "white") + 
                   scale_color_brewer(palette = "Dark2") +
                   scale_x_continuous(breaks = seq(1990, 2020, by = 5),
                                      minor_breaks = seq(1990, 2020, by = 1)) +
                   theme(legend.position = "top")
      )
    }
  
  line_graph(fao)
  line_graph(ext)
  line_graph(cross_cutting)
  
  cross_cutting <-
    data %>%
    filter(expression %in% c("Gender", "Commercialization", "Climate"))
  
  ext <-
    data %>%
    filter(expression %in% c("Agricultural extension", "Demonstration plot", "Contact farmer"))
  fao <-
    data %>%
    filter(expression %in% c("Farmer field school", "FAO"))
 
  projects_region <-
    projects %>%
    group_by(region) %>%
    summarise(pad = sum(pad))
  
  