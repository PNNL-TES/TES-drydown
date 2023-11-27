
## WEOC ----
x = 
  weoc_processed %>% 
  left_join(sample_key) %>% 
  filter(!is.na(length)) %>% 
  refactor_levels()

x %>% 
  ggplot(aes(x = length, y = npoc_mgg, color = depth))+
  geom_point()+
  facet_grid(Site ~ drying + saturation)

x %>% filter()

#
## FTICR ----

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
    fticr_trt %>% 
    #drop_na() %>% 
    left_join(dplyr::select(fticr_meta, formula, HC, OC), by = "formula")
  
  # time zero plot
  vk_timezero = 
    fticr_hcoc %>% 
    filter(saturation == "timezero") %>% 
    gg_vankrev(aes(x = OC, y = HC, color = depth))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(. ~ site)+
    scale_color_manual(values = rev(soil_palette("redox", 2)))+
    labs(subtitle = "timezero")+
    theme_kp()+
    NULL
  
  # plot of saturation treatments
  vk_drying_vs_rewet = 
    fticr_hcoc %>% 
    gg_vankrev(aes(x = OC, y = HC, color = saturation))+
    stat_ellipse(level = 0.90, show.legend = F)+
    facet_grid(site + depth ~ length)+
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





# stats ---- 
# permanova -----------------------------------------------------------
library(vegan)


relabund_wide = 
  fticr_relabund %>% 
  #filter(length != "timezero") %>% 
  ungroup() %>% 
  mutate(Class = factor(Class, 
                        levels = c("aliphatic", "unsaturated/lignin", 
                                   "aromatic", "condensed aromatic"))) %>% 
  dplyr::select(-c(abund, total)) %>% 
  pivot_wider(names_from = "Class", values_from = "relabund") %>% 
  drop_na() %>% 
  #    replace(is.na(.), 0) %>% 
  force()


compute_permanova = function(relabund_wide){

  
  permanova_fticr_all = 
    adonis2(relabund_wide %>% dplyr::select(where(is.numeric)) ~ 
              (site+depth+length+saturation+drying)^2, 
            data = relabund_wide)
  broom::tidy(permanova_fticr_all)
}

#
# hierarchical clusters ----

library(cluster)
library(factoextra)

data(iris)
scale(iris)

df <- USArrests 

df <- na.omit(df)
df <- scale(df)




df = iris %>%  dplyr::select(where(is.numeric))

d <- dist(df, method = "euclidean")
hc1 <- hclust(d, method = "complete" )
plot(hc1, cex = 0.6, hang = -1)
hc5 <- hclust(d, method = "ward.D2" )
sub_grp <- cutree(hc5, k = 5)
table(sub_grp)
plot(hc5, cex = 0.6)
rect.hclust(hc5, k = 5, border = 2:5)

fviz_cluster(list(data = df, cluster = sub_grp))


df = relabund_wide %>%  dplyr::select(where(is.numeric))
grp = relabund_wide %>%  dplyr::select(!where(is.numeric))

fviz_nbclust(df, FUN = hcut, method = "wss")
fviz_nbclust(df, FUN = hcut, method = "silhouette")
# three clusters

d <- dist(df, method = "euclidean")
hc1 <- hclust(d, method = "complete" )
plot(hc1, cex = 0.6, hang = -1)
hc5 <- hclust(d, method = "ward.D2" )
sub_grp <- cutree(hc5, k = 3)
table(sub_grp)
plot(hc5, cex = 0.6)
rect.hclust(hc5, k = 5, border = 2:5)

df_cl <- mutate(df, cluster = sub_grp) %>% cbind(grp)
count(df_cl,cluster)



df_cl %>% 
  filter(site == "CPCRW") %>% 
  ggplot(aes(y = cluster, x = length, fill = length))+
  geom_dotplot(binaxis = "y", stackdir = "centerwhole",
               dotsize = 0.4)+
  facet_wrap(~depth + saturation + drying, nrow = 1)+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
library(ggpubr)

df_cl %>% 
  filter(site == "CPCRW") %>% 
  mutate(drying_saturation = paste0(drying, "-", saturation)) %>% 
  ggdotplot(y = "saturation", x = "cluster", fill = "length", 
            position = position_jitter(0.05), dotsize = 2)+
#  scale_fill_manual(values = c("pink", "red", "lightblue", "blue"))+
  coord_flip()+
  facet_wrap(~depth + saturation, nrow = 1)
  
#  ggplot(aes(y = cluster, x = length, fill = length))+
#  geom_dotplot(binaxis = "y", stackdir = "centerwhole",
#               dotsize = 0.4)+
#  facet_wrap(~depth + saturation + drying, nrow = 1)+
#  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#


df_cl = df_cl %>% mutate(cluster = as.character(cluster))
df_cl_pca = fit_pca_function(df_cl %>% filter(site == "SR"))


ggbiplot(df_cl_pca$pca_int, obs.scale = 1, var.scale = 1,
         groups = as.character(df_cl_pca$grp$cluster), 
         ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
  geom_point(size=3,stroke=1, alpha = 1,
             aes(shape = df_cl_pca$grp$depth,
                 color = groups))+ 
  #scale_color_manual(values = c("#16879C", "#BB281E" ))+
  scale_shape_manual(values = c(21, 19))+
  #scale_shape_manual(values = c(21, 21, 19), name = "", guide = "none")+
  # xlim(-4,20)+
  # ylim(-8,8)+
  labs(shape="",
       #title = "Overall PCA, both regions",
       #subtitle = "Surface horizons only"
  )+
  theme_kp()+
  NULL



#



#
# # pca functions -----------------------------------------------------------
library(ggbiplot)
library(vegan)
library(patchwork)

fit_pca_function = function(dat){
  
  dat %>% 
    drop_na()
  
  num = 
    dat %>%       
    dplyr::select(where(is.numeric)) %>%
    dplyr::mutate(row = row_number()) %>% 
    drop_na()
  
  num_row_numbers = num %>% dplyr::select(row)
  
  grp = 
    dat %>% 
    dplyr::select(where(is.character)) %>% 
    dplyr::mutate(row = row_number()) %>% 
    right_join(num_row_numbers)
  
  
  num = num %>% dplyr::select(-row)
  pca_int = prcomp(num, scale. = T)
  
  list(num = num,
       grp = grp,
       pca_int = pca_int)
}

pca_overall = fit_pca_function(relabund_wide) 

#gg_pca_overall = 
ggbiplot(pca_overall$pca_int, obs.scale = 1, var.scale = 1,
         groups = as.character(pca_overall$grp$site), 
         ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
  geom_point(size=3,stroke=1, alpha = 1,
             aes(shape = pca_overall$grp$saturation,
               color = groups))+ 
  #scale_color_manual(values = c("#16879C", "#BB281E" ))+
  #scale_shape_manual(values = c(21, 19))+
  #scale_shape_manual(values = c(21, 21, 19), name = "", guide = "none")+
  # xlim(-4,20)+
  # ylim(-8,8)+
  labs(shape="",
       #title = "Overall PCA, both regions",
       #subtitle = "Surface horizons only"
       )+
  theme_kp()+
  NULL

relabund_summary = 
  fticr_relabund %>% 
  group_by(Class, site, depth, length, drying, saturation) %>% 
  dplyr::summarise(relabund_mean = mean(relabund))


relabund_summary %>% 
  ggplot(aes(x = length, y = relabund_mean, fill = Class))+
  geom_bar(stat = "identity")+
  facet_grid(site+depth ~ drying + saturation)


compute_fticr_pca_drying_vs_dw = function(fticr_relabund_cores){
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
      dplyr::select(where(is.numeric))
    
    grp = 
      relabund_pca %>% 
      dplyr::select(-where(is.numeric)) %>% 
      dplyr::mutate(row = row_number())
    
    pca_int = prcomp(num, scale. = T)
    
    list(num = num,
         grp = grp,
         pca_int = pca_int)
  }
  
  #
  ## PCA input files ----
  pca_drying_vs_dw = fit_pca_function(fticr_relabund_cores)
  pca_drying_vs_dw_cpcrw = fit_pca_function(fticr_relabund_cores %>% filter(Site == "Alaska"))
  pca_drying_vs_dw_sr = fit_pca_function(fticr_relabund_cores %>% filter(Site == "Alaska"))
  
  gg_pca_drying_vs_dw = 
    ggbiplot(pca_drying_vs_dw$pca_int, obs.scale = 1, var.scale = 1,
             groups = as.character(pca_drying_vs_dw$grp$saturation), 
             ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
    geom_point(size=4,stroke=1.5, 
               aes(shape = interaction(pca_drying_vs_dw$grp$Site, pca_drying_vs_dw$grp$depth),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,16,17,15, 5), name = "",
                       labels = c("Alaska top", "Alaska bottom", "Washington top", "Washington bottom"))+
    scale_color_manual(breaks = c("timezero", "drought", "d+rewet"),
                       values = pal_saturation)+
    scale_fill_manual(breaks = c("timezero", "drought", "d+rewet"),
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

compute_fticr_pca_cw_vs_fad = function(relabund_cores){
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
  pca = fit_pca_function(relabund_cores)
  
  gg_pca = 
    ggbiplot(pca$pca_int, obs.scale = 1, var.scale = 1,
             groups = as.character(pca$grp$drying), 
             ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
    geom_point(size=4,stroke=1.5, 
               aes(shape = interaction(pca$grp$depth, pca$grp$Site),
                   fill = groups, color = groups))+
    scale_shape_manual(values = c(1,2,16,17,15, 5), name = "")+
    labs(shape="",
         title = "FTICR PCA: CW vs. FAD")+
    theme_kp()+
    theme(legend.position = "right")+
    NULL
  
  gg_pca
  
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
