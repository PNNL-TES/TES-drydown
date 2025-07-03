# rm(list=ls())


library(funrar)
library(data.table)
library(RColorBrewer)
library(GUniFrac)
library(vegan)
library(devtools)
library(microViz)
# install.packages("microViz", repos = c(davidbarnett = "https://david-barnett.r-universe.dev", getOption("repos")))
# BiocManager::install(c("phyloseq", "microbiome", "ComplexHeatmap"), update = FALSE)
library(phyloseq)
library(pairwiseAdonis)
# install_github("pmartinezarbizu/pairwiseAdonis/pairwiseAdonis")
library(microbiome)
library(ape)


# Stacked barplot -- phylum level -----------------------------------------

compute_relabund_phylum_by_core = function(){
  # this function needs to be run only once, to compute relative abundances of taxa
  # the output is saved as .txt, so it does not need to be run again
  
  phyla = read.table("data/microbiome/taxtable2_transposed.txt", sep="\t", header=TRUE,row.names=1)
  
  NAMES = rownames(phyla)
  g_matrix = phyla[,9:67]
  rownames(g_matrix) = NAMES
  g_matrix = as.matrix(g_matrix)
  
  
  NAMES = rownames(phyla)
  g_sample = phyla[,1:8]
  rownames(g_sample) = NAMES
  
  # relative abundance normalization
  
  g_rel = make_relative(g_matrix)
  phyla_merged = merge(g_sample, g_rel, by="row.names")
  
  #write.table(phyla_merged, "phyla_relative_abundance.txt",sep="\t")
}

compute_relabund_phylum_by_trt = function(phyla_dat){
  # phyla = read.table("data/microbiome/phyla_relative_abundance.txt", sep="\t", header=TRUE, na = "") 
  
  phyla = phyla_dat %>% filter(!is.na(Sample))
  phyla_long = gather(phyla, phyla, counts, k__Archaea.p__Crenarchaeota:Other, factor_key=TRUE)
  
  phyla_long_clean = 
    phyla_long %>% 
    mutate(phyla = str_remove_all(phyla, "k__Bacteria.p__"),
           phyla = dplyr::recode(phyla, "k__Archaea.p__Crenarchaeota" = "Archaea_Crenarchaeota")) %>% 
    refactor_saturation_levels(.)
  
  
  relabund_phyla_treatment = 
    phyla_long_clean %>% 
    group_by(Site, depth, length, drying, saturation, phyla) %>% 
    dplyr::summarise(relabund = mean(counts),
                     se = sd(counts)/sqrt(n())) %>% 
    refactor_saturation_levels(.)
  
  list(phyla_long_clean = phyla_long_clean,
       relabund_phyla_treatment = relabund_phyla_treatment)
  
}

plot_barplot_phylum = function(phyla_relabund_by_trt){
  ### Create a stacked barplot at the Phylum level
  # use the output from the previous function here
  
  ggplot(phyla_relabund_by_trt, aes(fill = phyla, y = relabund, x = saturation))+
    geom_bar(position = "fill", stat = "identity")+
    facet_grid(. ~ Site + depth)+
    # scale_fill_viridis_d()+
    scale_fill_manual(values = PNWColors::pnw_palette("Bay", 17))+
    # scale_fill_manual(values = soilpalettes::soil_palette("redox2", 17))+
    labs(y = "Proportion",
         x = "")+
    theme_kp()
  
}

fad_plot_barplot_phylum = function(phyla_relabund_by_trt){
  ### Create a stacked barplot at the Phylum level
  # use the output from the previous function here
  
  ggplot(phyla_relabund_by_trt, aes(fill = phyla, y = relabund, x = drying))+
    geom_bar(position = "fill", stat = "identity")+
    facet_grid(saturation ~ Site + depth)+
    # scale_fill_viridis_d()+
    scale_fill_manual(values = PNWColors::pnw_palette("Bay", 17))+
    # scale_fill_manual(values = soilpalettes::soil_palette("redox2", 17))+
    labs(y = "Proportion",
         x = "")+
    theme_kp()
  
}

#

# PERMANOVA overall --------------------------------------------------------
##### Permanova analysis with time removed (since it has no drying factor)

compute_permanova_phyla = function(phyla_long_clean){

  phyla_relabund_wide = 
    phyla_long_clean %>% 
    dplyr::select(Sample, coreID, depth, Site, saturation, phyla, counts) %>% 
    pivot_wider(names_from = "phyla", values_from = "counts")
    

  phyla_permanova = 
    adonis(phyla_relabund_wide %>% dplyr::select(Archaea_Crenarchaeota:Other) ~ (depth + Site + saturation)^2, 
         data = phyla_relabund_wide)
    
  broom::tidy(phyla_permanova$aov.tab)
}

fad_compute_permanova_phyla = function(phyla_long_clean){
  
  phyla_relabund_wide = 
    phyla_long_clean %>% 
    dplyr::select(Sample, coreID, depth, Site, saturation, drying, phyla, counts) %>% 
    pivot_wider(names_from = "phyla", values_from = "counts")
  
  
  phyla_permanova = 
    adonis(phyla_relabund_wide %>% dplyr::select(Archaea_Crenarchaeota:Other) ~ (depth + Site + saturation + drying)^2, 
           data = phyla_relabund_wide)
  
  broom::tidy(phyla_permanova$aov.tab)
}

#
# PCA: drying-vs-wetting overall -----------------------------------------
compute_pca_drying_vs_rewet = function(phyla_long_clean){
  
  fit_pca_function = function(dat){
    relabund_pca =
      dat %>% 
      filter(!is.na(coreID)) %>% 
      dplyr::select(-starts_with("X")) %>% 
      ungroup %>% 
      spread(phyla, counts) %>% 
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
  
  
    ## PCA input files ----

    pca_phyla_tz = fit_pca_function(phyla_long_clean %>% filter(length == "timezero"))
    pca_phyla_drying_wet = fit_pca_function(phyla_long_clean %>% filter(length %in% c("timezero", "90d") & !drying %in% "FAD"))
    pca_phyla_overall = fit_pca_function(phyla_long_clean)
    
    
    ## PCA plots ----
    gg_pca_tz = 
      ggbiplot(pca_phyla_tz$pca_int, obs.scale = 1, var.scale = 1,
               groups = as.character(pca_phyla_tz$grp$Site), 
               ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
      geom_point(size=2,stroke=1, alpha = 1,
                 aes(shape = pca_phyla_tz$grp$depth,
                     color = groups))+
      #scale_shape_manual(values = c(21, 21, 19), name = "", guide = "none")+
      #scale_color_manual(values = c("red", "blue"), name = "")+
      #scale_fill_manual(values = c("red", "blue"), name = "")+
      #xlim(-4,4)+
      #ylim(-3.5,3.5)+
      labs(shape="",
           title = "time zero",
           subtitle = "separation by site")+
      theme_kp()+
      NULL
  
    
    (gg_pca_dry_wet = 
      ggbiplot(pca_phyla_drying_wet$pca_int, obs.scale = 1, var.scale = 1,
               groups = as.character(pca_phyla_drying_wet$grp$saturation), 
               ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
      geom_point(size=5,stroke=1, alpha = 1,
                 aes(shape = interaction(pca_phyla_drying_wet$grp$depth, pca_phyla_drying_wet$grp$Site),
                     color = groups))+
      scale_shape_manual(values = c(2, 1, 17, 19), name = "")+
      #scale_color_manual(values = c("red", "blue"), name = "")+
      #scale_fill_manual(values = c("red", "blue"), name = "")+
      xlim(-4,4)+
      ylim(-3.5,3.5)+
      labs(shape="",
           title = "90d, CW",
           subtitle = "separation by saturation type")+
        scale_color_manual(values = pal_saturation,
                           breaks = c("timezero", "drought", "d+rewet"))+
      theme_kp()+
        theme(legend.position = "right")+
      NULL)
  
    
    
    # overall plots ----
    (gg_pca_overall_site = 
        ggbiplot(pca_phyla_overall$pca_int, obs.scale = 1, var.scale = 1,
                 groups = as.character(pca_phyla_overall$grp$Site), 
                 ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
        geom_point(size=2,stroke=1, alpha = 1, show.legend = FALSE, 
                   aes(shape = groups,
                       color = groups))+
        #scale_shape_manual(values = c(21, 21, 19), name = "", guide = "none")+
        #scale_color_manual(values = c("red", "blue"), name = "")+
        #scale_fill_manual(values = c("red", "blue"), name = "")+
        xlim(-4,4)+
        ylim(-3.5,3.5)+
        labs(shape="",
             title = "all samples",
             subtitle = "separation by site")+
        theme_kp()+
        NULL)
    
    (gg_pca_overall_depth = 
        ggbiplot(pca_phyla_overall$pca_int, obs.scale = 1, var.scale = 1,
                 groups = as.character(pca_phyla_overall$grp$depth), 
                 ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
        geom_point(size=2,stroke=1, alpha = 1, show.legend = FALSE, 
                   aes(shape = groups,
                       color = groups))+
        #scale_shape_manual(values = c(21, 21, 19), name = "", guide = "none")+
        #scale_color_manual(values = c("red", "blue"), name = "")+
        #scale_fill_manual(values = c("red", "blue"), name = "")+
        xlim(-4,4)+
        ylim(-3.5,3.5)+
        labs(shape="",
             title = "all samples",
             subtitle = "separation by depth")+
        theme_kp()+
        NULL)
    
    (gg_pca_overall_length = 
        ggbiplot(pca_phyla_overall$pca_int, obs.scale = 1, var.scale = 1,
                 groups = as.character(pca_phyla_overall$grp$length), 
                 ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
        geom_point(size=2,stroke=1, alpha = 1, show.legend = FALSE, 
                   aes(shape = groups,
                       color = groups))+
        #scale_shape_manual(values = c(21, 21, 19), name = "", guide = "none")+
        #scale_color_manual(values = c("red", "blue"), name = "")+
        #scale_fill_manual(values = c("red", "blue"), name = "")+
        xlim(-4,4)+
        ylim(-3.5,3.5)+
        labs(shape="",
             title = "all samples",
             subtitle = "separation by length")+
        theme_kp()+
        NULL)
  
    (gg_pca_overall_saturation = 
        ggbiplot(pca_phyla_overall$pca_int, obs.scale = 1, var.scale = 1,
                 groups = as.character(pca_phyla_overall$grp$saturation), 
                 ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
        geom_point(size=2,stroke=1, alpha = 1, show.legend = FALSE, 
                   aes(shape = groups,
                       color = groups))+
        #scale_shape_manual(values = c(21, 21, 19), name = "", guide = "none")+
        #scale_color_manual(values = c("red", "blue"), name = "")+
        #scale_fill_manual(values = c("red", "blue"), name = "")+
        xlim(-4,4)+
        ylim(-3.5,3.5)+
        labs(shape="",
             title = "all samples",
             subtitle = "separation by saturation type")+
        theme_kp()+
        NULL)
    
    gg_pca_overall_combined = 
      cowplot::plot_grid(gg_pca_overall_site,
                         gg_pca_overall_depth,
                         gg_pca_overall_length,
                         gg_pca_overall_saturation)
    
    
    
    list(gg_pca_tz = gg_pca_tz,
         gg_pca_dry_wet = gg_pca_dry_wet,
         gg_pca_overall_combined = gg_pca_overall_combined)
}


compute_pca_cw_vs_fad = function(phyla_long_clean){
  
  fit_pca_function = function(dat){
    relabund_pca =
      dat %>% 
      filter(!is.na(coreID)) %>% 
      dplyr::select(-starts_with("X")) %>% 
      ungroup %>% 
      spread(phyla, counts) %>% 
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
  
  
  ## PCA input files ----
  
  pca = fit_pca_function(phyla_long_clean)
  
  
  ## PCA plots ----
  
  (gg_pca_dry_wet = 
      ggbiplot(pca$pca_int, obs.scale = 1, var.scale = 1,
               groups = as.character(pca$grp$drying), 
               ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
      geom_point(size=5,stroke=1, alpha = 1,
                 aes(shape = interaction(pca$grp$depth, pca$grp$Site),
                     color = groups))+
      scale_shape_manual(values = c(2, 1, 17, 19), name = "")+
      #scale_color_manual(values = c("red", "blue"), name = "")+
      #scale_fill_manual(values = c("red", "blue"), name = "")+
      xlim(-4,4)+
      ylim(-3.5,3.5)+
      labs(shape="",
           title = "90d, CW",
           subtitle = "separation by drying type")+
    #  scale_color_manual(values = pal_saturation,
    #                     breaks = c("timezero", "drought", "d+rewet"))+
      theme_kp()+
      theme(legend.position = "right")+
      NULL)
  
  
}

#
