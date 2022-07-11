# FTICRRR: fticr results in R
# Kaizad F. Patel
# October 2020

################################################## #

## `functions_vankrevelens.R`
## this script will load functions for plotting Van Krevelen diagrams
## source this file in the `fticr_drake_plan.R` file, do not run the script here.

################################################## #
################################################## #

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
  fticr_hcoc = 
    fticr_data_trt %>% 
    drop_na() %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula")
  
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
  
  vk_drying_vs_rewet = 
    fticr_hcoc %>% 
    gg_vankrev(aes(x = OC, y = HC, color = saturation))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(depth ~ Site)+
    scale_color_manual(values = rev(soil_palette("redox2", 3)))+
    labs(subtitle = "instant chemistry vs. saturated")+
    theme_kp()+
    NULL
  
  fticr_hcoc_lossgain_drought = 
    fticr_hcoc %>% 
    filter(saturation == c("timezero", "instant chemistry")) %>% 
    group_by(formula, HC, OC, Site, depth) %>% 
    dplyr::mutate(n = n()) %>% 
    filter(n == 1) %>% 
    mutate(lossgain = 
             case_when(saturation == "timezero" ~ "drought: lost",
                       saturation == "instant chemistry" ~ "drought: gained"))

  fticr_hcoc_lossgain_rewetting = 
    fticr_hcoc %>% 
    filter(saturation == c("instant chemistry", "saturated")) %>% 
    group_by(formula, HC, OC, Site, depth) %>% 
    dplyr::mutate(n = n()) %>% 
    filter(n == 1) %>% 
    mutate(lossgain = 
             case_when(saturation == "saturated" ~ "rewet: gained",
                       saturation == "instant chemistry" ~ "rewet: lost"))
  
  
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
       vk_lossgain = vk_lossgain)

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
  
  nosc_by_saturation = 
    fticr_data_nosc %>% 
    ggplot(aes(x = NOSC, fill = saturation, color = saturation))+
    geom_histogram(binwidth = 0.25, position = "identity", alpha = 0.5)+
    facet_grid(Site + depth ~ length + drying)+
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
