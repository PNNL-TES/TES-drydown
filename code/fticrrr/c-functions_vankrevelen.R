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
    facet_grid(length + depth ~ Site + saturation)+
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
  
  gg_tzero = 
    tzero %>% 
    gg_vankrev(aes(x = OC, y = HC, color = depth))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(. ~ Site)+
    labs(title = "time zero peaks",
         subtitle = "")+
    scale_color_manual(values = PNWColors::pnw_palette("Bay",2))+
    theme_kp()+
    NULL
  
  tzero_unique = 
    tzero %>% 
    distinct(formula, HC, OC, Site, saturation) %>% 
    group_by(formula) %>% 
    dplyr::mutate(n = n())
  
  (gg_tzero_unique = 
    tzero_unique %>% 
    filter(n == 1) %>% 
    gg_vankrev(aes(x = OC, y = HC, color = Site))+
    labs(title = "unique peaks per site")+
    #stat_ellipse(level = 0.90, show.legend = F)+
    annotate("text", label = "aliphatic", x = 1.0, y = 1.8, size = 3)+
      annotate("text", label = "unsaturated/\nlignin", x = 1.0, y = 1.2, size = 3)+
      annotate("text", label = "aromatic", x = 1.0, y = 0.5, size = 3)+
      annotate("text", label = "condensed \naromatic", x = 1.0, y = 0.2, size = 3)+
      
      facet_grid(. ~ Site)+
    theme_kp()+
    NULL)
  
  list(gg_tzero = gg_tzero,
       gg_tzero_unique = gg_tzero_unique)
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
           loss_gain = recode(diff, `-1` = "lost", `1` = "gained", `0` = NA_character_)) %>% 
    filter(!(Site=="CPCRW" & length=="30d" & saturation=="instant chemistry"))
    
  tzero_diff_hcoc = 
    tzero_diff %>% 
    filter(!is.na(loss_gain)) %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula") %>% 
    reorder_length(.)
  
  label_tzero_diff = 
    tzero_diff_hcoc %>% 
    group_by(depth, Site, length, drying, saturation, loss_gain) %>% 
    dplyr::summarise(n = n()) %>% 
    ungroup() %>% 
    pivot_wider(names_from = loss_gain, values_from = n) %>% 
    mutate(label = paste0("lost: ", lost, "; gained: ", gained)) %>% 
    reorder_length(.)
  
  ## create plots ----
  tz_diff_c_instant = 
    tzero_diff_hcoc %>% 
    filter(Site == "CPCRW" & saturation == "instant chemistry") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = loss_gain))+
    stat_ellipse(level = 0.90, show.legend = FALSE)+
    geom_text(data = label_tzero_diff %>% 
                filter(Site == "CPCRW" & saturation == "instant chemistry"), 
              aes(x = 0.6, y = 0.2, label = label), color = "black", size = 3)+
    labs(title = "compared to time zero",
         subtitle = "CPCRW, instant chemistry")+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    facet_grid(depth ~ drying + length)+
    theme_kp()
  
  tz_diff_c_saturated = 
    tzero_diff_hcoc %>% 
    filter(Site == "CPCRW") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = loss_gain))+
    stat_ellipse(level = 0.90, show.legend = FALSE)+
    geom_text(data = label_tzero_diff %>% 
                filter(Site == "CPCRW"), 
              aes(x = 0.6, y = 0.2, label = label), color = "black", size = 3)+
    labs(title = "compared to time zero",
         subtitle = "CPCRW")+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    facet_grid(saturation + depth ~ drying + length)+
    theme_kp()
    
  tz_diff_s_instant = 
    tzero_diff_hcoc %>% 
    filter(Site == "SR" & saturation == "instant chemistry") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = loss_gain))+
    stat_ellipse(level = 0.90, show.legend = FALSE)+
    geom_text(data = label_tzero_diff %>% 
                filter(Site == "SR" & saturation == "instant chemistry"), 
              aes(x = 0.6, y = 0.2, label = label), color = "black", size = 3)+
    labs(title = "compared to time zero",
         subtitle = "SR, instant chemistry")+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    facet_grid(depth ~ drying + length)+
    theme_kp()
  
  tz_diff_s_saturated = 
    tzero_diff_hcoc %>% 
    filter(Site == "SR") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = loss_gain))+
    stat_ellipse(level = 0.90, show.legend = FALSE)+
    geom_text(data = label_tzero_diff %>% 
                filter(Site == "SR"), 
              aes(x = 0.6, y = 0.2, label = label), color = "black", size = 3)+
    labs(title = "compared to time zero",
         subtitle = "SR")+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    facet_grid(saturation + depth ~ drying + length)+
    theme_kp()
  
  list(#tz_diff_c_instant = tz_diff_c_instant,
       tz_diff_c_saturated = tz_diff_c_saturated,
       #tz_diff_s_instant = tz_diff_s_instant,
       tz_diff_s_saturated = tz_diff_s_saturated
       )
}

################################################## #
plot_vk_saturation2 = function(fticr_data_trt, fticr_meta){
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

  
  
  ##  peakslossgain_saturation_nosc = 
  ##    peakslossgain_saturation %>% 
  ##    left_join(fticr_meta %>% dplyr::select(formula, NOSC), by = "formula")
  ##  
  ##  peakslossgain_saturation_nosc %>% 
  ##    distinct(lossgain, formula, HC, OC, NOSC, depth, drying) %>% 
  ##    ggplot(aes(x = NOSC, fill = lossgain, color = lossgain)) +
  ##    geom_histogram(alpha = 0.3, position = "identity")+
  ##    facet_grid(drying ~ depth)+
  ##    theme_kp()
  
  
  peakslossgain_saturation %>% 
    distinct(lossgain, formula, HC, OC, depth) %>% 
    gg_vankrev(aes(x = OC, y = HC, color = lossgain))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(depth ~ .)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    labs(subtitle = "instant chemistry vs. saturated")+
    theme_kp()+
    NULL

  
}
plot_vk_drying2 = function(fticr_data_trt, fticr_meta){
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
  
  ##  peakslossgain_drying_nosc = 
  ##    peakslossgain_drying %>% 
  ##    left_join(fticr_meta %>% dplyr::select(formula, NOSC), by = "formula")
  ##  
  ##  peakslossgain_drying_nosc %>% 
  ##    distinct(lossgain, formula, HC, OC, NOSC, depth, saturation) %>% 
  ##    ggplot(aes(x = NOSC, fill = lossgain, color = lossgain)) +
  ##    geom_histogram(alpha = 0.3, position = "identity")+
  ##    facet_grid(saturation ~ depth)+
  ##    theme_kp()
  
  
  peakslossgain_drying %>% 
    gg_vankrev(aes(x = OC, y = HC, color = lossgain))+
    stat_ellipse(level = 0.90, show.legend = F)+
    #geom_text(data = label_drying, aes(x = 0.6, y = 0.2, label = label), color = "black", size = 3)+
    facet_grid(depth ~ saturation)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    labs(title = "CW vs. FAD",
         subtitle = "peaks lost/gained during the forced drying")+
    theme_kp()+
    NULL 
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
