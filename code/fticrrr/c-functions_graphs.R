# FTICRRR: fticr results in R
# Kaizad F. Patel
# October 2020

################################################## #

## `functions_vankrevelens.R`
## this script will load functions for plotting Van Krevelen diagrams
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

plot_relabund_cw_vs_fad = function(relabund_cores, TREATMENTS){
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
    ggplot(aes(x = drying, y = rel_abund, fill = Class))+
    geom_bar(stat = "identity")+
    scale_fill_manual(values = PNWColors::pnw_palette("Sailboat"))+
    labs(title = "relative abundance",
         x = "",
         y = "% relative abundance")+
    facet_grid(saturation~Site+depth)+
    theme_kp()
  
}



################################################## #####
################################################## #####


gg_vankrev <- function(data,mapping){
  ggplot(data,mapping) +
    # plot points
    geom_point(size=0.5, alpha = 0.5) + # set size and transparency
    # axis labels
    ylab("H/C") +
    xlab("O/C") +
    # axis limits
    xlim(0,1.25) +
    ylim(0,2.5) +
    # add boundary lines for Van Krevelen regions
    geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
    geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
    geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
    guides(colour = guide_legend(override.aes = list(alpha=1, size = 1)))
}


# van krevelen plots ------------------------------------------------------
plot_vankrevelen_domains = function(fticr_meta){
  
  gg_vk_domains = 
    fticr_meta %>%     
    mutate(Class = factor(Class, levels = c("aliphatic", "unsaturated/lignin", "aromatic", "condensed aromatic"))) %>% 
    filter(!is.na(Class)) %>% 
    gg_vankrev(aes(x = OC, y = HC, color = Class))+
    scale_color_manual(values = PNWColors::pnw_palette("Sunset2", 4))+
    theme_kp()+
    guides(color=guide_legend(nrow=2, override.aes = list(size = 1, alpha = 1)))+
    NULL

  gg_vk_domains_nosc = 
    gg_vankrev(fticr_meta, aes(x = OC, y = HC, color = as.numeric(NOSC)))+
    scale_color_gradientn(colors = PNWColors::pnw_palette("Bay"))+
    theme_kp()
  
  list(gg_vk_domains = gg_vk_domains,
       gg_vk_domains_nosc = gg_vk_domains_nosc)
}

plot_vk_drying_vs_dw = function(fticr_data_trt, fticr_meta){
  # make hcoc dataframe
  fticr_hcoc = 
    fticr_data_trt %>% 
    drop_na() %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula")
  
  # time zero plot
  vk_timezero = 
    fticr_hcoc %>% 
    filter(saturation == "timezero") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = depth))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(. ~ Site)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    labs(subtitle = "timezero")+
    theme_kp()+
    NULL
  
  # plot of saturation treatments
  vk_drying_vs_rewet = 
    fticr_hcoc %>% 
    gg_vankrev(aes(x = OC, y = HC, color = saturation))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(depth ~ Site)+
    scale_color_manual(values = rev(soil_palette("redox2", 3)))+
    labs(subtitle = "instant chemistry vs. saturated")+
    theme_kp()+
    NULL
  
  # compute unique peaks
  fticr_unique = 
    fticr_hcoc %>% 
    group_by(Site, depth, formula) %>% 
    dplyr::mutate(n = n()) %>% refactor_saturation_levels()
  
  # plot unique peaks
  vk_unique = 
    fticr_unique %>% 
    filter(n == 1) %>% 
    gg_vankrev(aes(x = OC, y = HC, color = saturation)) +
    stat_ellipse(level = 0.9, show.legend = F)+
    scale_color_manual(values = pal_saturation)+
    labs(title = "Unique peaks")+
    facet_grid(depth ~ Site)
  
  # compute loss/gain for drought
  fticr_hcoc_lossgain_drought = 
    fticr_hcoc %>% 
    filter(saturation == c("timezero", "drought")) %>% 
    group_by(formula, HC, OC, Site, depth) %>% 
    dplyr::mutate(n = n()) %>% 
    filter(n == 1) %>% 
    mutate(lossgain = 
             case_when(saturation == "timezero" ~ "drought: lost",
                       saturation == "drought" ~ "drought: gained"))

  # compute loss/gain for rewet
  fticr_hcoc_lossgain_rewetting = 
    fticr_hcoc %>% 
    filter(saturation == c("drought", "d+rewet")) %>% 
    group_by(formula, HC, OC, Site, depth) %>% 
    dplyr::mutate(n = n()) %>% 
    filter(n == 1) %>% 
    mutate(lossgain = 
             case_when(saturation == "d+rewet" ~ "rewet: gained",
                       saturation == "drought" ~ "rewet: lost"))
  
  # plot loss/gain drought
  vk_lossgain_drought = 
    fticr_hcoc_lossgain_drought %>% 
    gg_vankrev(aes(x = OC, y = HC, color = lossgain))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(depth ~ Site)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    labs(title = "peaks lost/gained following drought",
         subtitle = "timezero vs. drought")+
    theme_kp()+
    NULL   
  
  # plot loss/gain rewet
  vk_lossgain_rewet = 
    fticr_hcoc_lossgain_rewetting %>% 
    gg_vankrev(aes(x = OC, y = HC, color = lossgain))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(depth ~ Site)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    labs(title = "peaks lost/gained following rewet",
         subtitle = "drought vs. d+rewet")+
    theme_kp()+
    NULL   
  
  # combined lossgain for drought and rewet
  fticr_hcoc_lossgain = 
    fticr_hcoc_lossgain_drought %>% 
    bind_rows(fticr_hcoc_lossgain_rewetting) %>% 
    dplyr::select(-saturation) %>% 
    separate(lossgain, sep = ": ", into = c("treatment", "lossgain"))
  
  vk_lossgain = 
    fticr_hcoc_lossgain %>% 
    gg_vankrev(aes(x = OC, y = HC, color = lossgain))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(Site + depth ~ treatment)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    # labs(subtitle = "instant chemistry vs. saturated, unique peaks")+
    theme_kp()+
    NULL    
  

  list(vk_timezero = vk_timezero,
       vk_drying_vs_rewet = vk_drying_vs_rewet,
       vk_lossgain_drought = vk_lossgain_drought,
       vk_lossgain_rewet = vk_lossgain_rewet,
       vk_unique = vk_unique)

}

plot_vk_cw_vs_fad = function(fticr_data_trt, fticr_meta){
  # make hcoc dataframe
  fticr_hcoc = 
    fticr_data_trt %>% 
    drop_na() %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula")
  
  # plot of drying treatments
  vk_cw_vs_fad = 
    fticr_hcoc %>% 
    gg_vankrev(aes(x = OC, y = HC, color = drying))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(depth ~ Site+saturation)+
    scale_color_manual(values = rev(soil_palette("redox2", 3)))+
    labs(subtitle = "instant chemistry vs. saturated")+
    theme_kp()+
    NULL
  
  # compute unique peaks
  fticr_unique = 
    fticr_hcoc %>% 
    group_by(Site, depth, formula, saturation) %>% 
    dplyr::mutate(n = n()) %>% refactor_saturation_levels()
  
  # plot unique peaks
  vk_unique = 
    fticr_unique %>% 
    filter(n == 1) %>% 
    gg_vankrev(aes(x = OC, y = HC, color = drying)) +
    stat_ellipse(level = 0.9, show.legend = F)+
    scale_color_manual(values = pal_saturation)+
    labs(title = "Unique peaks")+
    facet_grid(depth ~ Site+saturation)
  
  vk_unique
  
}


################################################## #
################################################## #


# NOSC figures ------------------------------------------------------------


make_nosc_figures = function(fticr_data_trt, fticr_meta){
  fticr_data_nosc = 
    fticr_data_trt %>% 
    left_join(dplyr::select(fticr_meta, formula, NOSC)) %>% 
    mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d")))
  
  nosc_by_drying = 
    fticr_data_nosc %>% 
    ggplot(aes(x = NOSC, fill = drying, color = drying))+
    geom_histogram(binwidth = 0.25, position = "identity", alpha = 0.5)+
    facet_grid(Site + depth ~ length + saturation)+
    theme_kp()+
    NULL
  
#  nosc_by_saturation = 
    fticr_data_nosc %>% 
    ggplot(aes(x = NOSC, fill = saturation, color = saturation))+
    geom_histogram(binwidth = 0.25, position = "identity", alpha = 0.2)+
    facet_grid(depth ~ Site )+
    theme_kp()+
    NULL
    
    fticr_data_nosc %>% 
      ggplot(aes(x = NOSC, fill = saturation, color = saturation))+
      geom_density(size = 1, position = "identity", alpha = 0.2)+
      facet_grid(depth ~ Site )+
      
      geom_boxplot(aes(y = 1), fill = NA, width = 0.2, show.legend = F)+
      scale_color_manual(values = pal_saturation)+
      scale_fill_manual(values = pal_saturation)+
      theme_kp()+
      NULL
    
    
  
  list(nosc_by_drying = nosc_by_drying,
       nosc_by_saturation = nosc_by_saturation)
  
  
## fticr_data_nosc %>% 
##   distinct(formula, NOSC, saturation, depth) %>% 
##   ggplot(aes(x = NOSC, fill = saturation, color = saturation))+
##   geom_histogram(binwidth = 0.25, position = "identity", alpha = 0.5)+
##   facet_grid(depth ~ .)+
##   theme_kp()+
##   NULL
## 
## fticr_data_nosc %>% 
##   distinct(formula, NOSC, saturation, drying, depth) %>% 
##   ggplot(aes(x = NOSC, fill = drying, color = drying))+
##   geom_histogram(binwidth = 0.25, position = "identity", alpha = 0.5)+
##   facet_grid(depth ~ saturation)+
##   theme_kp()+
##   NULL
  
}
