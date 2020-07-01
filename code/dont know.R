
    
    by_component_plot <- function(x) {
      
      projects$var <- projects[, x]
      
      
      data <- 
        projects %>%
        filter(!(is.na(var))) %>%
        group_by(var) %>%
        summarise_at(components, 
                     sum,
                     na.rm = TRUE) %>%
        pivot_longer(cols = components,
                     names_to = "component")
      use_labels(data,
                 
                 ggplot(data, 
                        aes(fill = var, 
                            y = value,
                            x = component)) + 
                   geom_bar(position = "fill",
                            stat = "identity")
                 
      )
    }
    
    by_theme_plot <- function(x) {
      
      projects$var <- projects[, x]
      
      
      data <- 
        projects %>%
        filter(!(is.na(var))) %>%
        group_by(var) %>%
        summarise_at(themes, 
                     sum,
                     na.rm = TRUE) %>%
        pivot_longer(cols = themes,
                     names_to = "theme")
      use_labels(data,
                 
                 ggplot(data, 
                        aes(fill = var, 
                            y = value,
                            x = theme)) + 
                 geom_bar(position = "fill",
                          stat = "identity",
                          color = brewer.pal(3, "Dark2")[1],
                          fill = brewer.pal(3, "Dark2")[1]) +
                 theme(legend.position = "bottom",
                       axis.ticks.x = element_blank()
                 
      )
    }
  
    by_component_plot("com")
    by_theme_plot("demo")
    