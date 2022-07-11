# FTICRRR: fticr results in R
# Kaizad F. Patel
# October 2020

################################################## #

## `functions_relabund.R`
## this script will load functions for computing and plotting relative abundances
## source this file in the `fticr_drake_plan.R` file, do not run the script here.

################################################## #
################################################## #


# relabund bar graphs -----------------------------------------------------

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
