# FTICRRR: fticr results in R
# Kaizad F. Patel
# October 2020

################################################## #

## `functions_vankrevelens.R`
## this script will load functions for plotting Van Krevelen diagrams
## source this file in the `fticr_drake_plan.R` file, do not run the script here.

################################################## #
################################################## #


theme_kp <- function() {  # this for all the elements common across plots
  theme_bw() %+replace%
    theme(legend.position = "top",
          legend.key=element_blank(),
          legend.title = element_blank(),
          legend.text = element_text(size = 12),
          legend.key.size = unit(1.5, 'lines'),
          legend.background = element_rect(colour = NA),
          panel.border = element_rect(color="black",size=1.5, fill = NA),
          
          plot.title = element_text(hjust = 0.00, size = 14),
          axis.text = element_text(size = 10, color = "black"),
          axis.title = element_text(size = 12, face = "bold", color = "black"),
          
          # formatting for facets
          panel.background = element_blank(),
          strip.background = element_rect(colour="white", fill="white"), #facet formatting
          panel.spacing.x = unit(1.5, "lines"), #facet spacing for x axis
          panel.spacing.y = unit(1.5, "lines"), #facet spacing for x axis
          strip.text.x = element_text(size=12, face="bold"), #facet labels
          strip.text.y = element_text(size=12, face="bold", angle = 270) #facet labels
    )
}
gg_vankrev <- function(data,mapping){
  ggplot(data,mapping) +
    # plot points
    geom_point(size=0.5, alpha = 0.2) + # set size and transparency
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

plot_vankrevelens = function(fticr_data_trt, fticr_meta){
  
  fticr_hcoc = 
    fticr_data_trt %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula")
  
  gg_cpcrw_all = 
    fticr_hcoc %>% 
    filter(Site =="CPCRW") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = saturation))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(drying+depth~length)+
    labs(title = "CPCRW")+
    theme_kp()+
    NULL
  
  gg_sr_all = 
    fticr_hcoc %>% 
    filter(Site =="SR") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = saturation))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(drying+depth~length)+
    labs(title = "SR")+
    theme_kp()+
    NULL
  
  gg_cpcrw_drying = 
    fticr_hcoc %>% 
    filter(Site =="CPCRW" & saturation == "saturated") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = drying))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(depth~length)+
    labs(title = "CPCRW",
         subtitle = "comparing drying types")+
    theme_kp()+
    NULL
  
  gg_sr_drying = 
    fticr_hcoc %>% 
    filter(Site =="SR" & saturation == "saturated") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = drying))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(depth~length)+
    labs(title = "SR",
         subtitle = "comparing drying types")+
    theme_kp()+
    NULL
  
  list(gg_cpcrw_all = gg_cpcrw_all,
       gg_sr_all = gg_sr_all,
       gg_cpcrw_drying = gg_cpcrw_drying,
       gg_sr_drying = gg_sr_drying)
}

plot_vk_saturation = function(fticr_data_trt, fticr_meta){
  fticr_hcoc = 
    fticr_data_trt %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula")
  
  peakslossgain_saturation = 
    fticr_hcoc %>% 
    filter(
      (Site == "CPCRW" & length == "90d")|
        (Site == "SR" & length == "30d")|
        (Site == "SR" & length == "90d")) %>% 
    group_by(formula, Site, depth, length, drying) %>% 
    dplyr::mutate(n = n()) %>% 
    filter(n == 1) %>% 
    ungroup() %>% 
    mutate(lossgain = dplyr::recode(saturation, "saturated" = "gained", "instant chemistry" = "lost"))
  
  label_saturation = 
    peakslossgain_saturation %>% 
    group_by(depth, Site, length, drying, lossgain) %>% 
    dplyr::summarise(n = n()) %>% 
    ungroup() %>% 
    pivot_wider(names_from = lossgain, values_from = n) %>% 
    mutate(label = paste0("lost: ", lost, "; gained: ", gained))
  
  
  peakslossgain_saturation %>% 
    gg_vankrev(aes(x = OC, y = HC, color = lossgain))+
    stat_ellipse(level = 0.90, show.legend = F)+
    geom_text(data = label_saturation, aes(x = 0.6, y = 0.2, label = label), color = "black", size = 3)+
    facet_grid(length+depth ~ Site + drying)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    labs(subtitle = "instant chemistry vs. saturated")+
    theme_kp()+
    NULL
  
    
}

plot_vk_drying = function(fticr_data_trt, fticr_meta){
  fticr_hcoc = 
    fticr_data_trt %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula")
  
  peakslossgain_drying = 
    fticr_hcoc %>% 
    filter(saturation != "timezero") %>% 
    group_by(formula, Site, depth, length, saturation) %>% 
    dplyr::mutate(n = n()) %>% 
    filter(n == 1) %>% 
    ungroup() %>% 
    mutate(lossgain = dplyr::recode(drying, "FAD" = "gained", "CW" = "lost")) %>% 
    mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d")))
  
  label_drying = 
    peakslossgain_drying %>% 
    group_by(depth, Site, length, saturation, lossgain) %>% 
    dplyr::summarise(n = n()) %>% 
    ungroup() %>% 
    pivot_wider(names_from = lossgain, values_from = n) %>% 
    mutate(label = paste0("lost: ", lost, "; gained: ", gained)) %>% 
    mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d")))
  
  # overall
  lossgain_overall = 
    peakslossgain_drying %>% 
    distinct(formula, Site, depth, saturation, HC, OC, lossgain) %>% 
    gg_vankrev(aes(x = OC, y = HC, color = lossgain))+
    stat_ellipse(level = 0.90, show.legend = F)+
    #geom_text(data = label_drying, aes(x = 0.6, y = 0.2, label = label), color = "black", size = 3)+
    facet_grid(depth ~ Site)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    labs(title = "CW vs. FAD",
         subtitle = "peaks lost/gained during the forced drying")+
    theme_kp()+
    NULL 
  
  
  peakslossgain_drying %>% 
    gg_vankrev(aes(x = OC, y = HC, color = lossgain))+
    stat_ellipse(level = 0.90, show.legend = F)+
    geom_text(data = label_drying, aes(x = 0.6, y = 0.2, label = label), color = "black", size = 3)+
    facet_grid(depth + saturation ~ Site+length)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    labs(title = "CW vs. FAD",
         subtitle = "peaks lost/gained during the forced drying")+
    theme_kp()+
    NULL 
}

plot_vk_timezero = function(fticr_data_trt, fticr_meta){
  tzero = 
    fticr_data_trt %>% 
    filter(length == "timezero") %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula")
  

  tzero %>% 
    gg_vankrev(aes(x = OC, y = HC, color = depth))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(. ~ Site)+
    labs(title = "time zero peaks",
         subtitle = "")+
    theme_kp()+
    NULL
}

plot_tzero_diff = function(fticr_data_trt, fticr_meta){
  ## create dataframe for comparison ----
  fticr_trt_temp = 
    fticr_data_trt %>%
    filter(length != "timezero") %>% 
    mutate(trt = 1,
          assignment = paste0(length, "-", drying, "-", saturation)) %>% 
    dplyr::select(formula, depth, Site, assignment, trt) %>% 
    pivot_wider(names_from = assignment, values_from = trt)
  
  fticr_tzero_temp = 
    fticr_data_trt %>%
    filter(length == "timezero") %>% 
    mutate(tzero = 1) %>% 
    dplyr::select(formula, depth, Site, tzero)
  
  tzero_diff = 
    fticr_tzero_temp %>% 
    full_join(fticr_trt_temp, by = c("formula", "depth", "Site")) %>% 
    pivot_longer(-c(formula, depth, Site, tzero), names_to = "assignment", values_to = "trt") %>% 
    separate(assignment, sep = "-", into = c("length", "drying", "saturation")) %>% 
    dplyr::select(formula, depth, Site, length, drying, saturation, trt, tzero) %>% 
    mutate(trt = replace_na(trt, 0),
           tzero = replace_na(tzero, 0),
           diff = trt-tzero,
           loss_gain = recode(diff, `-1` = "loss", `1` = "gain", `0` = NA_character_)) %>% 
    filter(!(Site=="CPCRW" & length=="30d" & saturation=="instant chemistry"))
    
  tzero_diff_hcoc = 
    tzero_diff %>% 
    filter(!is.na(loss_gain)) %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula") %>% 
    reorder_length(.)
  
  ## create plots ----
  tz_diff_c_instant = 
    tzero_diff_hcoc %>% 
    filter(Site == "CPCRW" & saturation == "instant chemistry") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = loss_gain))+
    stat_ellipse(level = 0.90, show.legend = FALSE)+
    labs(title = "compared to time zero",
         subtitle = "CPCRW, instant chemistry")+
    facet_grid(depth ~ drying + length)+
    theme_kp()
  
  tz_diff_c_saturated = 
    tzero_diff_hcoc %>% 
    filter(Site == "CPCRW") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = loss_gain))+
    stat_ellipse(level = 0.90, show.legend = FALSE)+
    labs(title = "compared to time zero",
         subtitle = "CPCRW, saturated")+
    facet_grid(saturation + depth ~ drying + length)+
    theme_kp()
    
  tz_diff_s_instant = 
    tzero_diff_hcoc %>% 
    filter(Site == "SR" & saturation == "instant chemistry") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = loss_gain))+
    stat_ellipse(level = 0.90, show.legend = FALSE)+
    labs(title = "compared to time zero",
         subtitle = "SR, instant chemistry")+
    facet_grid(depth ~ drying + length)+
    theme_kp()
  
  tz_diff_s_saturated = 
    tzero_diff_hcoc %>% 
    filter(Site == "SR") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = loss_gain))+
    stat_ellipse(level = 0.90, show.legend = FALSE)+
    labs(title = "compared to time zero",
         subtitle = "SR, saturated")+
    facet_grid(saturation + depth ~ drying + length)+
    theme_kp()
  
  list(#tz_diff_c_instant = tz_diff_c_instant,
       tz_diff_c_saturated = tz_diff_c_saturated,
       #tz_diff_s_instant = tz_diff_s_instant,
       tz_diff_s_saturated = tz_diff_s_saturated
       )
}

