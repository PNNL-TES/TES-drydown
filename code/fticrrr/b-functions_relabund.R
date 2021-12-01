# FTICRRR: fticr results in R
# Kaizad F. Patel
# October 2020

################################################## #

## `functions_relabund.R`
## this script will load functions for computing and plotting relative abundances
## source this file in the `fticr_drake_plan.R` file, do not run the script here.

################################################## #
################################################## #


    ## compute_relabund_cores = function(fticr_data_longform, fticr_meta, ...){
    ##   fticr_data_longform %>% 
    ##     # add the Class column to the data
    ##     left_join(dplyr::select(fticr_meta, formula, Class), by = "formula") %>% 
    ##     # calculate abundance of each Class as the sum of all counts
    ##     group_by(CoreID, Class, ...) %>%
    ##     dplyr::summarise(abund = sum(presence)) %>%
    ##     ungroup %>% 
    ##     # create a new column for total counts per core assignment
    ##     # and then calculate relative abundance  
    ##     group_by(CoreID, ...) %>% 
    ##     dplyr::mutate(total = sum(abund),
    ##                   relabund  = round((abund/total)*100,2))
    ## }


# relabund bar graphs -----------------------------------------------------

      ## plot_relabund = function(relabund_cores, ...){
      ##   relabund_trt = 
      ##     relabund_cores %>% 
      ##     group_by(..., Class) %>% 
      ##     dplyr::summarize(rel_abund = round(mean(relabund),2),
      ##                      se  = round((sd(relabund/sqrt(n()))),2),
      ##                      relative_abundance = paste(rel_abund, "\u00b1",se)) %>% 
      ##     ungroup() %>% 
      ##     mutate(Class = factor(Class, levels = c("aliphatic", "unsaturated/lignin", "aromatic", "condensed aromatic")))
      ##   
      ##   relabund_trt %>% 
      ##     ggplot(aes(x = sat_level, y = rel_abund, fill = Class))+
      ##     geom_bar(stat = "identity")+
      ##     theme_kp()
      ## }

plot_relabund = function(relabund_cores, TREATMENTS){
  relabund_trt = 
    relabund_cores %>% 
    group_by(!!!TREATMENTS, Class) %>% 
    dplyr::summarize(rel_abund = round(mean(relabund),2),
                     se  = round((sd(relabund/sqrt(n()))),2),
                     relative_abundance = paste(rel_abund, "\u00b1",se)) %>% 
    ungroup() %>% 
    mutate(Class = factor(Class, levels = c("aliphatic", "unsaturated/lignin", "aromatic", "condensed aromatic"))) %>% 
    mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d"))) %>% 
    filter(!is.na(Class))
  
  relabund_bar_trt = 
    relabund_trt %>% 
    filter(length != "timezero") %>% 
    ggplot(aes(x = length, y = rel_abund, fill = Class))+
    geom_bar(stat = "identity")+
    scale_fill_manual(values = PNWColors::pnw_palette("Sailboat"))+
    labs(title = "relative abundance",
         x = "",
         y = "% relative abundance")+
    facet_grid(Site+depth~drying+saturation)+
    theme_kp()
  
  relabund_bar_tzero = 
    relabund_trt %>% 
    filter(length == "timezero") %>% 
    ggplot(aes(x = depth, y = rel_abund, fill = Class))+
    geom_bar(stat = "identity")+
    scale_fill_manual(values = PNWColors::pnw_palette("Sailboat"))+
    labs(title = "time zero relative abundance",
         x = "",
         y = "% relative abundance")+
    facet_grid(. ~ Site)+
    theme_kp()+
    theme(legend.position = "right")+
    NULL
  
  list(relabund_bar_trt = relabund_bar_trt,
       relabund_bar_tzero = relabund_bar_tzero)
}


plot_relabund_drying_vs_dw = function(relabund_cores, TREATMENTS){
  relabund_trt = 
    relabund_cores %>% 
    drop_na() %>% 
    group_by(!!!TREATMENTS, Class) %>% 
    dplyr::summarize(rel_abund = round(mean(relabund),2),
                     se  = round((sd(relabund/sqrt(n()))),2),
                     relative_abundance = paste(rel_abund, "\u00b1",se)) %>% 
    ungroup() %>% 
    mutate(Class = factor(Class, levels = c("aliphatic", "unsaturated/lignin", "aromatic", "condensed aromatic"))) %>% 
    filter(!is.na(Class))
  
  #relabund_bar_trt = 
    relabund_trt %>% 
    #filter(saturation != "timezero") %>% 
    ggplot(aes(x = saturation, y = rel_abund, fill = Class))+
    geom_bar(stat = "identity")+
    scale_fill_manual(values = PNWColors::pnw_palette("Sailboat"))+
    labs(title = "relative abundance",
         x = "",
         y = "% relative abundance")+
    facet_grid(depth~Site)+
    theme_kp()
  
}
