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
    geom_point(size=4,stroke=1.5, 
               aes(shape = interaction(pca_drying_vs_dw$grp$depth, pca_drying_vs_dw$grp$Site),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,16,17,15, 5), name = "")+
    scale_color_manual(breaks = c("timezero", "instant chemistry", "saturated"),
                       values = pal_saturation)+
    scale_fill_manual(breaks = c("timezero", "instant chemistry", "saturated"),
                       values = pal_saturation)+
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
    #filter(length != "timezero") %>% 
    ungroup() %>% 
    mutate(Class = factor(Class, 
                          levels = c("aliphatic", "unsaturated/lignin", 
                                     "aromatic", "condensed aromatic"))) %>% 
    filter(!is.na(Class)) %>% 
    filter(!is.na(CoreID)) %>% 
    dplyr::select(-c(abund, total)) %>% 
    spread(Class, relabund) %>% 
    replace(is.na(.), 0)
  
  permanova_fticr_all = 
    adonis(relabund_wide %>% dplyr::select(aliphatic:`condensed aromatic`) ~ 
             (depth+Site+saturation)^2, 
           data = relabund_wide)
  broom::tidy(permanova_fticr_all$aov.tab)
}


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
