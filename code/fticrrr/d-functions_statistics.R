# pca functions -----------------------------------------------------------
library(ggbiplot)
library(vegan)
library(patchwork)

fit_pca_function = function(dat){
  relabund_pca=
    dat %>% 
    filter(!is.na(CoreID)) %>% 
    ungroup %>% 
    dplyr::select(-c(abund, total)) %>% 
    spread(Class, relabund) %>% 
    replace(.,is.na(.),0)  %>% 
    dplyr::select(-1)
  
  num = 
    relabund_pca %>% 
    dplyr::select(c(aliphatic, aromatic, `condensed aromatic`, `unsaturated/lignin`))
  
  grp = 
    relabund_pca %>% 
    dplyr::select(-c(aliphatic, aromatic, `condensed aromatic`, `unsaturated/lignin`)) %>% 
    dplyr::mutate(row = row_number())
  
  pca_int = prcomp(num, scale. = T)
  
  list(num = num,
       grp = grp,
       pca_int = pca_int)
}

compute_fticr_pca = function(relabund_cores){
  ## PCA input files ----
  relabund_CPCRW = relabund_cores %>% filter(Site == "CPCRW")
  relabund_SR = relabund_cores %>% filter(Site == "SR")
  
  pca_timezero = fit_pca_function(relabund_cores %>% filter(length == "timezero"))
  pca_cpcrw_top = fit_pca_function(relabund_CPCRW %>% filter(depth == "0-5cm"))
  pca_cpcrw_bottom = fit_pca_function(relabund_CPCRW %>% filter(depth == "5cm-end"))
  pca_sr_top = fit_pca_function(relabund_SR %>% filter(depth == "0-5cm"))
  pca_sr_bottom = fit_pca_function(relabund_SR %>% filter(depth == "5cm-end"))
  pca_overall = fit_pca_function(relabund_cores)
  
  ## PCA plots overall ----
  gg_pca_overall1 = 
    ggbiplot(pca_overall$pca_int, obs.scale = 1, var.scale = 1,
           groups = as.character(pca_overall$grp$saturation), 
           ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
    geom_point(size=2,stroke=1, alpha = 0.5,
               aes(shape = groups,
                   color = groups))+
    scale_shape_manual(values = c(21, 21, 19), name = "", guide = "none")+
    #scale_color_manual(values = c("red", "blue"), name = "")+
    #scale_fill_manual(values = c("red", "blue"), name = "")+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         title = "all samples",
         subtitle = "separation by saturation type")+
    theme_kp()+
    NULL
  
  gg_pca_overall2 = 
    ggbiplot(pca_overall$pca_int, obs.scale = 1, var.scale = 1,
           groups = as.character(pca_overall$grp$Site), 
           ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
    geom_point(size=4,stroke=1, 
               aes(shape = interaction(pca_overall$grp$length, pca_overall$grp$drying),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,0,16,17,15, 5), name = "")+
    #scale_color_manual(values = c("red", "blue"), name = "")+
    #scale_fill_manual(values = c("red", "blue"), name = "")+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         title = "all samples",
         subtitle = "separation by site")+
    theme_kp()+
    NULL
  
  ## PCA plots CPCRW ----
  gg_pca_cpcrwtop = 
    ggbiplot(pca_cpcrw_top$pca_int, obs.scale = 1, var.scale = 1,
           groups = as.character(pca_cpcrw_top$grp$saturation), 
           ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
    geom_point(size=4,stroke=1, 
               aes(shape = interaction(pca_cpcrw_top$grp$length, pca_cpcrw_top$grp$drying),
                   fill = groups, color = groups))+
      scale_shape_manual(values = c(1,2,0,16,17,15, 5), name = "")+
      #scale_color_manual(values = c("red", "blue"), name = "")+
      #scale_fill_manual(values = c("red", "blue"), name = "")+
      xlim(-4,4)+
      ylim(-3.5,3.5)+
      labs(shape="",
           title = "CPCRW, 0-5cm")+
      theme_kp()+
      NULL
  
  gg_pca_cpcrwbottom = 
    ggbiplot(pca_cpcrw_bottom$pca_int, obs.scale = 1, var.scale = 1,
           groups = as.character(pca_cpcrw_bottom$grp$saturation), 
           ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
    geom_point(size=4,stroke=1, 
               aes(shape = interaction(pca_cpcrw_bottom$grp$length, pca_cpcrw_bottom$grp$drying),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,0,16,17,15, 5), name = "")+
    xlim(-6,6)+
    ylim(-6,6)+
    labs(shape="",
         title = "CPCRW, 5cm-end")+
    theme_kp()+
    NULL
  
  gg_pca_cpcrw = gg_pca_cpcrwtop + gg_pca_cpcrwbottom +
    plot_layout(guides = "collect") &
    theme(legend.position = "bottom")
  
  
  ## PCA plots SR ----
  gg_pca_srtop = 
    ggbiplot(pca_sr_top$pca_int, obs.scale = 1, var.scale = 1,
           groups = as.character(pca_sr_top$grp$saturation), 
           ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
    geom_point(size=4,stroke=1, 
               aes(shape = interaction(pca_sr_top$grp$length, pca_sr_top$grp$drying),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,0,16,17,15, 5), name = "")+
    #scale_color_manual(values = c("red", "blue"), name = "")+
    #scale_fill_manual(values = c("red", "blue"), name = "")+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         title = "SR, 0-5cm")+
    theme_kp()+
    NULL
  
  gg_pca_srbottom = 
    ggbiplot(pca_sr_bottom$pca_int, obs.scale = 1, var.scale = 1,
           groups = as.character(pca_sr_bottom$grp$saturation), 
           ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
    geom_point(size=4,stroke=1, 
               aes(shape = interaction(pca_sr_bottom$grp$length, pca_sr_bottom$grp$drying),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,0,16,17,15, 5), name = "")+
    xlim(-3,3)+
    ylim(-3,3)+
    labs(shape="",
         title = "SR, 5cm-end")+
    theme_kp()+
    NULL

  gg_pca_sr = gg_pca_srtop + gg_pca_srbottom +
    plot_layout(guides = "collect") &
    theme(legend.position = "bottom")
  
  list(gg_pca_overall1 = gg_pca_overall1,
       gg_pca_overall2 = gg_pca_overall2,
       gg_pca_cpcrw = gg_pca_cpcrw,
       gg_pca_sr = gg_pca_sr
       )
}
compute_fticr_pca2 = function(relabund_cores){
  ## PCA input files ----

  pca_timezero = fit_pca_function(relabund_cores %>% filter(length == "timezero"))
  pca_drought = fit_pca_function(relabund_cores %>% filter(length != "timezero"))
  
  gg_pca_saturation = 
    ggbiplot(pca_drought$pca_int, obs.scale = 1, var.scale = 1,
             groups = as.character(pca_drought$grp$saturation), 
             ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
    geom_point(size=2,stroke=1, shape = 21, alpha = 0.5, 
               aes(color = groups))+
    #scale_shape_manual(values = c(1,2,0,16,17,15, 5), name = "")+
    #scale_color_manual(values = c("red", "blue"), name = "")+
    #scale_fill_manual(values = c("red", "blue"), name = "")+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         title = "all samples",
         subtitle = "separation by saturation type")+
    theme_kp()+
    NULL
 
  gg_pca_depth = 
      ggbiplot(pca_drought$pca_int, obs.scale = 1, var.scale = 1,
               groups = as.character(pca_drought$grp$depth), 
               ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
      geom_point(size=2,stroke=1, shape = 21, alpha = 0.5, 
                 aes(color = groups))+
      xlim(-4,4)+
      ylim(-3.5,3.5)+
      labs(shape="",
           title = "all samples",
           subtitle = "separation by depth")+
      theme_kp()+
      NULL
  
  gg_pca_length = 
      ggbiplot(pca_drought$pca_int, obs.scale = 1, var.scale = 1,
               groups = as.character(pca_drought$grp$length), 
               ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
      geom_point(size=2,stroke=1, shape = 21, alpha = 0.5, 
                 aes(color = groups))+
      xlim(-4,4)+
      ylim(-3.5,3.5)+
      labs(shape="",
           title = "all samples",
           subtitle = "separation by length")+
      theme_kp()+
      NULL
  
  gg_pca_drying = 
      ggbiplot(pca_drought$pca_int, obs.scale = 1, var.scale = 1,
               groups = as.character(pca_drought$grp$drying), 
               ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
      geom_point(size=2,stroke=1, shape = 21, alpha = 0.5, 
                 aes(color = groups))+
      xlim(-4,4)+
      ylim(-3.5,3.5)+
      labs(shape="",
           title = "all samples",
           subtitle = "separation by drying intensity")+
      theme_kp()+
      NULL
  
  gg_pca_site = 
      ggbiplot(pca_drought$pca_int, obs.scale = 1, var.scale = 1,
               groups = as.character(pca_drought$grp$Site), 
               ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
      geom_point(size=2,stroke=1, shape = 21, alpha = 0.5, 
                 aes(color = groups))+
      xlim(-4,4)+
      ylim(-3.5,3.5)+
      labs(shape="",
           title = "all samples",
           subtitle = "separation by site")+
      theme_kp()+
      NULL
  
  
  
  list(gg_pca_saturation = gg_pca_saturation,
       gg_pca_depth = gg_pca_depth,
       gg_pca_length = gg_pca_length,
       gg_pca_drying = gg_pca_drying,
       gg_pca_site = gg_pca_site
  )
}

compute_fticr_pca_tzero = function(relabund_cores){
  ## PCA input files ----
  pca_timezero = fit_pca_function(relabund_cores %>% filter(length == "timezero"))
  
  ## PCA plots timezero ----
  gg_pca_tzero = 
    ggbiplot(pca_timezero$pca_int, obs.scale = 1, var.scale = 1,
             groups = as.character(pca_timezero$grp$Site), 
             ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
    geom_point(size=4,stroke=1, 
               aes(shape = pca_timezero$grp$depth,
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,0,16,17,15, 5), name = "")+
    #scale_color_manual(values = c("red", "blue"), name = "")+
    #scale_fill_manual(values = c("red", "blue"), name = "")+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         title = "time zero")+
    theme_kp()+
    NULL
  
  
}  


compute_fticr_pca_drying_vs_dw = function(relabund_cores){
  ## PCA function ----
  fit_pca_function = function(dat){
    relabund_pca=
      dat %>% 
      filter(!is.na(CoreID)) %>% 
      ungroup %>% 
      dplyr::select(-c(abund, total)) %>% 
      spread(Class, relabund) %>% 
      replace(.,is.na(.),0)  %>% 
      dplyr::select(-1)
    
    num = 
      relabund_pca %>% 
      dplyr::select(c(aliphatic, aromatic, `condensed aromatic`, `unsaturated/lignin`))
    
    grp = 
      relabund_pca %>% 
      dplyr::select(-c(aliphatic, aromatic, `condensed aromatic`, `unsaturated/lignin`)) %>% 
      dplyr::mutate(row = row_number())
    
    pca_int = prcomp(num, scale. = T)
    
    list(num = num,
         grp = grp,
         pca_int = pca_int)
  }
  
  #
  ## PCA input files ----
  pca_drying_vs_dw = fit_pca_function(relabund_cores)
  pca_drying_vs_dw_cpcrw = fit_pca_function(relabund_cores %>% filter(Site == "CPCRW"))
  pca_drying_vs_dw_sr = fit_pca_function(relabund_cores %>% filter(Site == "SR"))
  
  gg_pca_drying_vs_dw = 
    ggbiplot(pca_drying_vs_dw$pca_int, obs.scale = 1, var.scale = 1,
             groups = as.character(pca_drying_vs_dw$grp$saturation), 
             ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
    geom_point(size=4,stroke=1, 
               aes(shape = interaction(pca_drying_vs_dw$grp$depth, pca_drying_vs_dw$grp$Site),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,16,17,15, 5), name = "")+
    #scale_color_manual(values = c("red", "blue"), name = "")+
    #scale_fill_manual(values = c("red", "blue"), name = "")+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         title = "FTICR PCA")+
    theme_kp()+
    theme(legend.position = "right")+
    NULL
  
  gg_pca_drying_vs_dw_c = 
    ggbiplot(pca_drying_vs_dw_cpcrw$pca_int, obs.scale = 1, var.scale = 1,
             groups = as.character(pca_drying_vs_dw_cpcrw$grp$saturation), 
             ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
    geom_point(size=4,stroke=1, 
               aes(shape = (pca_drying_vs_dw_cpcrw$grp$depth),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,16,17,15, 5), name = "")+
    #scale_color_manual(values = c("red", "blue"), name = "")+
    #scale_fill_manual(values = c("red", "blue"), name = "")+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         title = "time zero")+
    theme_kp()+
    NULL
  
  
  gg_pca_drying_vs_dw_s = 
    ggbiplot(pca_drying_vs_dw_sr$pca_int, obs.scale = 1, var.scale = 1,
             groups = as.character(pca_drying_vs_dw_sr$grp$saturation), 
             ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
    geom_point(size=4,stroke=1, 
               aes(shape = (pca_drying_vs_dw_sr$grp$depth),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,16,17,15, 5), name = "")+
    #scale_color_manual(values = c("red", "blue"), name = "")+
    #scale_fill_manual(values = c("red", "blue"), name = "")+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         title = "time zero")+
    theme_kp()+
    NULL
  
  # list ----
  list(gg_pca_drying_vs_dw = gg_pca_drying_vs_dw
       #gg_pca_drying_vs_dw_c = gg_pca_drying_vs_dw_c,
       #gg_pca_drying_vs_dw_s = gg_pca_drying_vs_dw_s
       )
}  




# permanova -----------------------------------------------------------

compute_permanova = function(relabund_cores){
  relabund_wide = 
    relabund_cores %>% 
    filter(length != "timezero") %>% 
    ungroup() %>% 
    mutate(Class = factor(Class, 
                          levels = c("aliphatic", "unsaturated/lignin", 
                                     "aromatic", "condensed aromatic"))) %>% 
    dplyr::select(-c(abund, total)) %>% 
    spread(Class, relabund) %>% 
    replace(is.na(.), 0)
  
  permanova_fticr_all = 
    adonis(relabund_wide %>% dplyr::select(aliphatic:`condensed aromatic`) ~ 
             (depth+Site+length+drying+saturation)^2, 
           data = relabund_wide)
  broom::tidy(permanova_fticr_all$aov.tab)
}

compute_permanova_tzero = function(relabund_cores){
  relabund_wide = 
    relabund_cores %>% 
    filter(length == "timezero") %>% 
    ungroup() %>% 
    dplyr::select(-drying, -saturation) %>% 
    mutate(Class = factor(Class, 
                          levels = c("aliphatic", "unsaturated/lignin", 
                                     "aromatic", "condensed aromatic"))) %>% 
    dplyr::select(-c(abund, total)) %>% 
    spread(Class, relabund) %>% 
    replace(is.na(.), 0)
  
  permanova_fticr_all = 
    adonis(relabund_wide %>% dplyr::select(aliphatic:`condensed aromatic`) ~ 
             (depth+Site)^2, 
           data = relabund_wide)
  broom::tidy(permanova_fticr_all$aov.tab)
}

compute_permanova_drought = function(relabund_cores){
  relabund_wide = 
    relabund_cores %>% 
    filter(saturation != "instant chemistry") %>% 
    mutate(drought = if_else(saturation == "timezero", "timezero", "drought")) %>% 
    ungroup() %>% 
#    dplyr::select(-drying, -saturation) %>% 
    mutate(Class = factor(Class, 
                          levels = c("aliphatic", "unsaturated/lignin", 
                                     "aromatic", "condensed aromatic"))) %>% 
    dplyr::select(-c(abund, total)) %>% 
    spread(Class, relabund) %>% 
    replace(is.na(.), 0)
  
  permanova_fticr_all = 
    adonis(relabund_wide %>% dplyr::select(aliphatic:`condensed aromatic`) ~ 
             (drought+depth+drying)^2, 
           data = relabund_wide)
  broom::tidy(permanova_fticr_all$aov.tab)
}


##  variables = c("sat_level", "treatment")
##  indepvar = paste(variables, collapse = " + ")
##  compute_permanova(indepvar)



# relabund anova ----------------------------------------------------------
compute_relabund_anova = function(relabund_cores){
  fit_anova = function(dat){
    l = lm(relabund ~ (length + saturation + drying)^2, data = dat, singular.ok = TRUE)
    a = car::Anova(l)
    broom::tidy((a)) %>% filter(term != "Residuals") %>% 
      mutate(`p.value` = round(`p.value`,4))
    
  }
  
  x = relabund_cores %>% 
    filter(Class != "other" & saturation != "timezero") %>% 
    group_by(Class) %>% 
    do(fit_anova(.)) %>% 
    dplyr::select(Class, `p.value`, term) %>% 
    pivot_wider(names_from = "Class", values_from = "p.value")
  
  
  
}

