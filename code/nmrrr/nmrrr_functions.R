## TES Drydown
## NMRRR functions
## Kaizad F. Patel
## 06 May, 2021

## Functions to process NMR peaks and spectra data, obtained from MestreNova.
## Do not run this script.
## This script will be sourced from the drake plan.

########################
########################


# I. NMR SPECTRA ----------------------------------------------------------
# this function will import NMR spectra data, combine, and clean 
import_nmr_spectra_data = function(SPECTRA_FILES, doc_key){
  filePaths_spectra <- list.files(path = SPECTRA_FILES,pattern = "*.csv", full.names = TRUE)
  spectra_dat <- do.call(rbind, lapply(filePaths_spectra, function(path) {
    # the files are tab-delimited, so read.csv will not work. import using read.table
    # there is no header. so create new column names
    # then add a new column `source` to denote the file name
    df <- read.table(path, header=FALSE, col.names = c("ppm", "intensity"))
    df[["source"]] <- rep(path, nrow(df))
    df}))
  
  process_spectra_data = function(spectra_dat, doc_key){
    doc_key2 = 
      doc_key %>% 
      recode_depth() %>% recode_saturation() %>% recode_sites()
    
    spectra_dat %>% 
      # retain only values 0-10ppm
      filter(ppm >= 0 & ppm <= 10) %>% 
      mutate(source = str_remove(source, paste0(SPECTRA_FILES, "/"))) %>% 
      mutate(source = str_remove(source, ".csv")) %>% 
      mutate(source = paste0("DOC-",source)) %>% 
      dplyr::rename(DOC_ID = source) %>% 
      left_join(doc_key2, by = "DOC_ID") %>% 
      filter(!is.na(coreID))
  }
  process_spectra_data(spectra_dat, doc_key)
}
plot_nmr_spectra = function(nmr_spectra_processed){
  spectra_tzero =   
    gg_nmr2 +
    geom_path(data = nmr_spectra_processed %>% 
                filter(length == "timezero"),
              aes(x = ppm, y = intensity, color = DOC_ID))+
    ylim(0,2.5)+
    facet_grid(saturation + depth  ~ Site)+
    theme(legend.position = "none",
          plot.caption = element_text(hjust = 0))+
    annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = 0, ymax = 2.5,
             fill = "grey90", alpha = 0.5)+
    labs(title = "NMR spectra: time zero",
         caption = "grey = solvent region,
       1, 2 = aliphatic,
       3 = o-alkyl (carb),
       4 = alpha-H (protein),
       5 = aromatic,
       6 = amide")+
    NULL
  
  spectra_cpcrw =   
    gg_nmr2 +
    geom_path(data = nmr_spectra_processed %>% 
                filter(length != "timezero" & Site == "Alaska"),
              aes(x = ppm, y = intensity, color = DOC_ID))+
    ylim(0,2.5)+
    facet_grid(depth ~ saturation + drying)+
    theme(legend.position = "none",
          plot.caption = element_text(hjust = 0))+
    annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = 0, ymax = 2.5,
             fill = "grey90", alpha = 0.5)+
    labs(title = "NMR spectra: CPCRW",
         caption = "grey = solvent region,
       1, 2 = aliphatic,
       3 = o-alkyl (carb),
       4 = alpha-H (protein),
       5 = aromatic,
       6 = amide")+
    NULL
  
  spectra_sr =
      gg_nmr2 +
      geom_path(data = nmr_spectra_processed %>% 
                  filter(length != "timezero" & Site == "Washington"),
                aes(x = ppm, y = intensity, color = DOC_ID))+
      ylim(0,2.5)+
      facet_grid(depth ~ saturation + drying)+
      theme(legend.position = "none",
            plot.caption = element_text(hjust = 0))+
      annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = 0, ymax = 2.5,
               fill = "grey90", alpha = 0.5)+
      labs(title = "NMR spectra: SR",
           caption = "grey = solvent region,
       1, 2 = aliphatic,
       3 = o-alkyl (carb),
       4 = alpha-H (protein),
       5 = aromatic,
       6 = amide")+
      NULL
 
  list(spectra_tzero = spectra_tzero,
       spectra_cpcrw = spectra_cpcrw,
       spectra_sr = spectra_sr) 
}

fad_plot_nmr_spectra = function(nmr_spectra_processed){
  
  spectra_cpcrw =   
    gg_nmr2 +
    geom_path(data = nmr_spectra_processed %>% 
                filter(length != "timezero" & Site == "Alaska"),
              aes(x = ppm, y = intensity, color = DOC_ID))+
    ylim(0,2.5)+
    facet_grid(depth ~ saturation + drying)+
    theme(legend.position = "none",
          plot.caption = element_text(hjust = 0))+
    annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = 0, ymax = 2.5,
             fill = "grey90", alpha = 0.5)+
    labs(title = "NMR spectra: CPCRW",
         caption = "grey = solvent region,
       1, 2 = aliphatic,
       3 = o-alkyl (carb),
       4 = alpha-H (protein),
       5 = aromatic,
       6 = amide")+
    NULL
  
  spectra_sr =
    gg_nmr2 +
    geom_path(data = nmr_spectra_processed %>% 
                filter(length != "timezero" & Site == "Washington"),
              aes(x = ppm, y = intensity, color = DOC_ID))+
    ylim(0,2.5)+
    facet_grid(depth ~ saturation + drying)+
    theme(legend.position = "none",
          plot.caption = element_text(hjust = 0))+
    annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = 0, ymax = 2.5,
             fill = "grey90", alpha = 0.5)+
    labs(title = "NMR spectra: SR",
         caption = "grey = solvent region,
       1, 2 = aliphatic,
       3 = o-alkyl (carb),
       4 = alpha-H (protein),
       5 = aromatic,
       6 = amide")+
    NULL
  
  list(
       spectra_cpcrw = spectra_cpcrw,
       spectra_sr = spectra_sr) 
}

plot_nmr_spectra_clean = function(nmr_spectra_processed){
  
  nmr_spectra_subset = 
    nmr_spectra_processed %>% 
    filter(coreID %in% c("C81", "C84", "C61", "S58", "S84", "S53"))
  
  gg_alaska = 
    gg_nmr2 +
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Alaska" & saturation == "timezero"),
              aes(x = ppm, y = intensity), color = "#f9ad2a")+
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Alaska" & saturation == "drought"),
              aes(x = ppm, y = intensity+0.5), color = "#cc5c76")+
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Alaska" & saturation == "d+rewet"),
              aes(x = ppm, y = intensity+1), color = "#1d457f")+
    annotate("text", label = "timezero", x = 9, y = 0.1, color = "#f9ad2a")+
    annotate("text", label = "drought", x = 9, y = 0.6, color = "#cc5c76")+
    annotate("text", label = "d+rewet", x = 9, y = 1.1, color = "#1d457f")+
    ylim(-0.1, 2.5)+
    
    annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = -0.1, ymax = 2.5,
             fill = "white", alpha = 0.85)+
    labs(title = "Alaska")+
    theme(plot.title = element_text(hjust = 0.5, size = 18, vjust = 1))+
    NULL
  
  
  gg_washington = 
    gg_nmr2 +
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Washington" & saturation == "timezero"),
              aes(x = ppm, y = intensity), color = "#f9ad2a")+
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Washington" & saturation == "drought"),
              aes(x = ppm, y = intensity+0.5), color = "#cc5c76")+
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Washington" & saturation == "d+rewet"),
              aes(x = ppm, y = intensity+1), color = "#1d457f")+
    annotate("text", label = "timezero", x = 9, y = 0.1, color = "#f9ad2a")+
    annotate("text", label = "drought", x = 9, y = 0.6, color = "#cc5c76")+
    annotate("text", label = "d+rewet", x = 9, y = 1.1, color = "#1d457f")+
    ylim(-0.1,2.5)+
    
    annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = -0.1, ymax = 2.5,
             fill = "white", alpha = 0.85)+
    labs(title = "Washington")+
    theme(plot.title = element_text(hjust = 0.5, size = 18, vjust = 1))+
    NULL
  
  cowplot::plot_grid(gg_alaska, gg_washington)
  
  #  geom_rect(data = nmr_spectra_subset %>% filter(Site == "Washington" & saturation == "timezero"), 
  #            aes(xmin = DMSO_start, xmax = WATER_stop, ymin = 0.0, ymax = 2.5),
  #            fill = "grey90", alpha = 0.015)
  
  
 ##   gg_nmr2 +
 ##   geom_path(data = nmr_spectra_subset %>% 
 ##               filter(Site == "Washington"),
 ##             aes(x = ppm, y = intensity, color = DOC_ID))+
 ##   ylim(0,2.5)+
 ##   facet_grid(. ~ saturation)+
 ##   theme(legend.position = "none",
 ##         plot.caption = element_text(hjust = 0))+
 ##   annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = 0, ymax = 2.5,
 ##            fill = "grey90", alpha = 0.5)+
 ##   labs(title = "NMR spectra: SR",
 ##        caption = "grey = solvent region,
 ##      1, 2 = aliphatic,
 ##      3 = o-alkyl (carb),
 ##      4 = alpha-H (protein),
 ##      5 = aromatic,
 ##      6 = amide")+
 ##   NULL
  
  
}


fad_plot_nmr_spectra_clean = function(nmr_spectra_processed){
  
  nmr_spectra_subset = 
    nmr_spectra_processed %>% 
    filter(coreID %in% c("C84", "C61", "C83", "C37", "C70", "C71", "S84", "S53", "S21", "S72")) %>% 
    filter(saturation == "drought")
  
  gg_alaska = 
    gg_nmr2 +
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Alaska" & drying == "CW"),
              aes(x = ppm, y = intensity+0.5), color = "#cc5c76")+
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Alaska" & drying == "FAD"),
              aes(x = ppm, y = intensity), color = "#1d457f")+
    annotate("text", label = "FAD", x = 9, y = 0.1, color = "#1d457f")+
    annotate("text", label = "CW", x = 9, y = 0.6, color = "#cc5c76")+
   # annotate("text", label = "d+rewet", x = 9, y = 1.1, color = "#1d457f")+
    ylim(-0.1, 2.5)+
    
    annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = -0.1, ymax = 2.5,
             fill = "white", alpha = 0.85)+
    labs(title = "Alaska")+
    theme(plot.title = element_text(hjust = 0.5, size = 18, vjust = 1))+
    NULL
  
  
  gg_washington = 
    gg_nmr2 +
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Washington" & drying == "CW"),
              aes(x = ppm, y = intensity+0.5), color = "#cc5c76")+
    geom_path(data = nmr_spectra_subset %>% filter(Site == "Washington" & drying == "FAD"),
              aes(x = ppm, y = intensity), color = "#1d457f")+
    annotate("text", label = "FAD", x = 9, y = 0.1, color = "#1d457f")+
    annotate("text", label = "CW", x = 9, y = 0.6, color = "#cc5c76")+
    # annotate("text", label = "d+rewet", x = 9, y = 1.1, color = "#1d457f")+
    ylim(-0.1, 2.5)+
    
    annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = -0.1, ymax = 2.5,
             fill = "white", alpha = 0.85)+
    labs(title = "Washington")+
    theme(plot.title = element_text(hjust = 0.5, size = 18, vjust = 1))+
    NULL
  
  cowplot::plot_grid(gg_alaska, gg_washington)
  
  #  geom_rect(data = nmr_spectra_subset %>% filter(Site == "Washington" & saturation == "timezero"), 
  #            aes(xmin = DMSO_start, xmax = WATER_stop, ymin = 0.0, ymax = 2.5),
  #            fill = "grey90", alpha = 0.015)
  
  
 # gg_nmr2 +
 #   geom_path(data = nmr_spectra_subset %>% 
 #               filter(Site == "Washington"),
 #             aes(x = ppm, y = intensity, color = DOC_ID))+
 #   ylim(0,2.5)+
 #   facet_grid(. ~ saturation)+
 #   theme(legend.position = "none",
 #         plot.caption = element_text(hjust = 0))+
 #   annotate("rect", xmin = DMSO_start, xmax = WATER_stop, ymin = 0, ymax = 2.5,
 #            fill = "grey90", alpha = 0.5)+
 #   labs(title = "NMR spectra: SR",
 #        caption = "grey = solvent region,
 #      1, 2 = aliphatic,
 #      3 = o-alkyl (carb),
 #      4 = alpha-H (protein),
 #      5 = aromatic,
 #      6 = amide")+
 #   NULL
  
  
}

#
# II. NMR PEAKS -----------------------------------------------------------
# this function will import NMR peaks data, align and combine, 
# and then process and clean the dataset.
import_nmr_peaks = function(PEAKS_FILES){
  filePaths_peaks <- list.files(path = PEAKS_FILES,pattern = "*.csv", full.names = TRUE)
  peaks_rawdat <- do.call(bind_rows, lapply(filePaths_peaks, function(path) {
    # this function will import all the data files and combine for all samples
    # first, we run the function to clean a single file
    # the input data are spread across multiple columns, so use this function to align columns
    
    align_columns = function(path){
      # Step 1. import file. 
      # check.names=FALSE because columns have duplicate names, and we want to leave as is
      df <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
      
      # Step 2. confirm that the data are in 9-column groups
      noname_cols <- which(names(df) == "")
      if(!all(diff(noname_cols) == 9)) {
        stop("Formatting problem: data don't appear to be in 9-column groups")
      }
      names(df)[noname_cols] <- "Obs"  # give them a name
      
      # Step 3. Extract each group in turn and store temporarily in a list
      nmr_list <- lapply(noname_cols, function(x) df[x:(x + 8)])
      
      # Step 4. Finally, bind everything into a single data frame
      # This uses dplyr but we could also use base R: do.call("rbind", nmr_list)
      nmr_dat <- dplyr::bind_rows(nmr_list)
      
      # Step 5. Create a new column that includes source sample name
      nmr_dat[["source"]] <- rep(path, nrow(df))
      
      nmr_dat
    }
    
    # now create an object from the function
    align_columns(path)
    # this will be repeated for each file in the input folder
    
  }))
  
  # process the dataset
  process_peaks_data = function(peaks_rawdat){
   # WATER_start = 3; WATER_stop = 4
   # DMSO_start = 2.25; DMSO_stop = 2.75
    
    peaks_rawdat %>% 
      filter(ppm>=0&ppm<=10) %>% 
      filter(Intensity > 0) %>% 
      # remove solvent regions
      filter(!(ppm>DMSO_start & ppm<DMSO_stop)) %>% 
      filter(!(ppm>WATER_start & ppm<WATER_stop)) %>% 
      filter(!is.na(ppm)) %>% 
      # remove peaks with 0 intensity, and peaks flagged as weak 
      filter(!Flags=="Weak") %>% 
      mutate(DOC_ID = str_remove(source, paste0(PEAKS_FILES, "/"))) %>% 
      mutate(DOC_ID = str_remove(DOC_ID, ".csv")) %>% 
      mutate(DOC_ID = paste0("DOC-", DOC_ID)) %>% 
      dplyr::select(-Obs, -source)
  }
  process_peaks_data(peaks_rawdat)
}

#
# III. RELATIVE ABUNDANCE -------------------------------------------------
# this function will compute relative abundance based on NMR peaks data
compute_nmr_relabund = function(nmr_peaks_processed, bins2, doc_key){
  rel_abund_cores1 = 
    subset(merge(nmr_peaks_processed, bins2), start <= ppm & ppm <= stop) %>% 
    #dplyr::select(source,ppm, Area, group) %>% 
    #filter(!(ppm>DMSO_start&ppm<DMSO_stop)) %>% 
    group_by(DOC_ID, group) %>% 
    filter(group != "oalkyl") %>% 
    dplyr::summarize(area = sum(Area)) %>% 
    group_by(DOC_ID) %>% 
    dplyr::mutate(total = sum(area),
                  relabund = round((area/total)*100,2)) %>% 
    dplyr::select(DOC_ID, group, relabund) %>% 
    replace(is.na(.), 0) %>% 
    left_join(doc_key, by = "DOC_ID")
  
  rel_abund_wide1 = 
    rel_abund_cores1 %>% 
    pivot_wider(names_from = "group", values_from = "relabund")
  
  rel_abund_cores = 
    rel_abund_wide1 %>% 
    pivot_longer(-c(DOC_ID:saturation), values_to = "relabund", names_to = "group") %>% 
    replace_na(list(relabund = 0))
  
  rel_abund_wide = 
    rel_abund_cores %>% 
    pivot_wider(names_from = "group", values_from = "relabund") %>% 
    ungroup()
  
  list(rel_abund_cores = rel_abund_cores,
       rel_abund_wide = rel_abund_wide)
}
compute_relabund_summary = function(rel_abund_cores){
  relabund_summary = 
    rel_abund_cores %>%
    group_by(Site, depth, length, drying, saturation, group) %>% 
    dplyr::summarize(relabund_mean = round(mean(relabund),2),
                     relabund_se = round(sd(relabund, na.rm = T)/sqrt(n()), 2)) 
  
  relabund_summarytable = 
    relabund_summary %>% 
    mutate(relabund = paste(relabund_mean, "\u00b1", relabund_se),
           relabund = str_remove_all(relabund, " \u00b1 NA")) 
  
  list(relabund_summary = relabund_summary,
       relabund_summarytable = relabund_summarytable)
}

plot_relabund_bargraphs_drying_vs_dw = function(nmr_relabund_cores){
  relabund_summary = compute_relabund_summary(nmr_relabund_cores)$relabund_summary %>% 
    refactor_saturation_levels(.)
  
  relabund_bar_cores = 
    nmr_relabund_cores %>% 
    ggplot(aes(x = DOC_ID, y = relabund, fill = group))+
    geom_bar(stat = "identity")+
    facet_grid(depth + saturation + length ~ Site + drying, scales = "free_x", space = "free_x")+
    labs(title = "NMR relative abundance")+
    theme_bw()+
    theme(axis.text.x = element_text(angle = 90))
  
  relabund_bar_top = 
    relabund_summary %>% 
    filter(depth == "0-5cm") %>% 
    ggplot(aes(x = saturation, y = relabund_mean, fill = group))+
    geom_bar(stat = "identity")+
    facet_grid(. ~ Site)+
    labs(title = "NMR: 0-5 cm only",
         x = "",
         y = "Relative abundance, %")+
    scale_fill_manual(values = PNWColors::pnw_palette("Sailboat", 5))+
    theme_kp()
  
  list(relabund_bar_cores = relabund_bar_cores,
       relabund_bar_top = relabund_bar_top)
}

plot_relabund_bargraphs_cw_vs_fad = function(nmr_relabund_cores){
  relabund_summary = compute_relabund_summary(nmr_relabund_cores)$relabund_summary %>% 
    refactor_saturation_levels(.)
  
  relabund_bar_cores = 
    nmr_relabund_cores %>% 
    ggplot(aes(x = DOC_ID, y = relabund, fill = group))+
    geom_bar(stat = "identity")+
    facet_grid(depth + saturation + length ~ Site + drying, scales = "free_x", space = "free_x")+
    labs(title = "NMR relative abundance")+
    theme_bw()+
    theme(axis.text.x = element_text(angle = 90))
  
  relabund_bar_top = 
    relabund_summary %>% 
    filter(depth == "0-5cm") %>% 
    ggplot(aes(x = saturation, y = relabund_mean, fill = group))+
    geom_bar(stat = "identity")+
    facet_grid(drying ~ Site)+
    labs(title = "NMR: 0-5 cm only",
         x = "",
         y = "Relative abundance, %")+
    scale_fill_manual(values = PNWColors::pnw_palette("Sailboat", 5))+
    theme_kp()
  
  list(relabund_bar_cores = relabund_bar_cores,
       relabund_bar_top = relabund_bar_top)
}


#
#
# III. PERMANOVA ----------------------------------------------------------
library(vegan)

compute_nmr_permanova_drying_dw = function(rel_abund_wide){
  relabund_permanova = rel_abund_wide  %>% filter(length != "timezero") 
  
  permanova_tzero = 
    adonis(rel_abund_wide %>% filter(length == "timezero") %>% dplyr::select(aliphatic1, aliphatic2, aromatic, alphah, amide)  ~ 
             (Site)^2,
           data = rel_abund_wide %>% filter(length == "timezero") )
  
  permanova_drying_vs_dw = 
    adonis(relabund_permanova %>% dplyr::select(aliphatic1, aliphatic2, aromatic, alphah, amide)  ~ 
             (Site  + saturation)^2,
           data = relabund_permanova)
  
  permanova_drought_toponly = 
    adonis(relabund_permanova %>% 
             filter(depth == "0-5cm") %>% 
             dplyr::select(aliphatic1, aliphatic2, aromatic, alphah, amide)  ~ 
             (Site + saturation)^2,
           data = relabund_permanova %>% filter(depth == "0-5cm"))
  
  broom::tidy(permanova_drought_toponly$aov.tab)
  
 # list(permanova_tzero = permanova_tzero,
 #      #permanova_drying_vs_dw = permanova_drying_vs_dw,
 #      permanova_drought_toponly = permanova_drought_toponly) 
}


compute_nmr_permanova_cw_fad = function(rel_abund_wide){
  relabund_permanova = rel_abund_wide  %>% filter(length != "timezero") 
  
  permanova = 
    adonis(relabund_permanova %>% dplyr::select(aliphatic1, aliphatic2, aromatic, alphah, amide)  ~ 
             (Site  + drying + saturation)^2,
           data = relabund_permanova)
  
  broom::tidy(permanova$aov.tab)
  
  # list(permanova_tzero = permanova_tzero,
  #      #permanova_drying_vs_dw = permanova_drying_vs_dw,
  #      permanova_drought_toponly = permanova_drought_toponly) 
}




#
# IV. PCA -----------------------------------------------------------------

fit_pca_function = function(dat){
  relabund_pca=
    dat %>% 
    ungroup %>% 
  #  dplyr::select(-c(abund, total)) %>% 
  #  spread(Class, relabund) %>% 
  #  replace(.,is.na(.),0)  %>% 
    dplyr::select(-1)
  
  num = 
    relabund_pca %>% 
    dplyr::select(c(aliphatic1, aliphatic2, aromatic, alphah, amide))
  
  grp = 
    relabund_pca %>% 
    dplyr::select(-c(aliphatic1, aliphatic2, aromatic, alphah, amide)) %>% 
    dplyr::mutate(row = row_number())
  
  pca_int = prcomp(num, scale. = T)
  
  list(num = num,
       grp = grp,
       pca_int = pca_int)
}

compute_nmr_pca_drying_dw = function(rel_abund_wide){
  
  fit_pca_function = function(dat){
    relabund_pca=
      dat %>% 
      ungroup %>% 
      #  dplyr::select(-c(abund, total)) %>% 
      #  spread(Class, relabund) %>% 
      #  replace(.,is.na(.),0)  %>% 
      dplyr::select(-1)
    
    num = 
      relabund_pca %>% 
      dplyr::select(c(aliphatic1, aliphatic2, aromatic, alphah))
    
    grp = 
      relabund_pca %>% 
      dplyr::select(-c(aliphatic1, aliphatic2, aromatic, alphah, amide)) %>% 
      dplyr::mutate(row = row_number())
    
    pca_int = prcomp(num, scale. = T)
    
    list(num = num,
         grp = grp,
         pca_int = pca_int)
  }
  
  ## PCA input files ----
  rel_abund_wide = rel_abund_wide %>% filter(depth == "0-5cm")
  
  #pca_timezero = fit_pca_function(rel_abund_wide %>% filter(length == "timezero"))
  pca_drought = fit_pca_function(rel_abund_wide %>% filter(length != "timezero"))
  pca_cpcrw_top = fit_pca_function(rel_abund_wide %>% filter(Site == "CPCRW" & depth == "0-5cm"))
  #pca_cpcrw_bottom = fit_pca_function(rel_abund_wide %>% filter(Site == "CPCRW" & depth == "5cm-end"))
  pca_sr_top = fit_pca_function(rel_abund_wide %>% filter(Site == "SR" & depth == "0-5cm" & length != "timezero"))
  #pca_sr_bottom = fit_pca_function(relabund_SR %>% filter(depth == "5cm-end"))
  pca_overall = fit_pca_function(rel_abund_wide)
  
  ## PCA plots overall ----
  gg_pca_overall1 = 
    ggbiplot(pca_overall$pca_int, obs.scale = 1, var.scale = 1,
             groups = as.character(pca_overall$grp$saturation), 
             ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
    geom_point(size=2,stroke=1, alpha = 0.5,
               aes(shape = groups,
                   color = groups))+
    scale_shape_manual(values = c(21, 21, 19), name = "", guide = "none")+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         title = "all samples",
         subtitle = "separation by saturation type")+
    theme_kp()+
    NULL
  
  (gg_pca_overall2 = 
    ggbiplot(pca_overall$pca_int, obs.scale = 1, var.scale = 1,
             groups = as.character(pca_overall$grp$saturation), 
             ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
    geom_point(size=2,stroke=1, alpha = 1,
               aes(shape = pca_overall$grp$Site,
                   color = groups))+
 
      scale_color_manual(values = pal_saturation,
                         breaks = c("timezero", "drought", "d+rewet"),
                         #labels = c("timezero", "drought", "rewet")
                         )+
    xlim(-4,4)+
    ylim(-3.5,3.5)+
    labs(shape="",
         #title = "all samples",
         #subtitle = "separation by saturation type"
         title = "NMR: 0-5 cm only")+
    theme_kp()+
    NULL)
  
  
  #

}

compute_nmr_pca_cw_fad = function(rel_abund_wide){
  
  fit_pca_function = function(dat){
    relabund_pca=
      dat %>% 
      ungroup %>% 
      #  dplyr::select(-c(abund, total)) %>% 
      #  spread(Class, relabund) %>% 
      #  replace(.,is.na(.),0)  %>% 
      dplyr::select(-1)
    
    num = 
      relabund_pca %>% 
      dplyr::select(c(aliphatic1, aliphatic2, aromatic, alphah))
    
    grp = 
      relabund_pca %>% 
      dplyr::select(-c(aliphatic1, aliphatic2, aromatic, alphah, amide)) %>% 
      dplyr::mutate(row = row_number())
    
    pca_int = prcomp(num, scale. = T)
    
    list(num = num,
         grp = grp,
         pca_int = pca_int)
  }
  
  ## PCA input files ----
  rel_abund_wide = rel_abund_wide %>% filter(depth == "0-5cm")
  
  pca_overall = fit_pca_function(rel_abund_wide)
  
  ## PCA plots overall ----
  (gg_pca_overall2 = 
      ggbiplot(pca_overall$pca_int, obs.scale = 1, var.scale = 1,
               groups = as.character(pca_overall$grp$drying), 
               ellipse = TRUE, circle = FALSE, var.axes = TRUE, alpha = 0) +
      geom_point(size=2,stroke=1, alpha = 1,
                 aes(shape = pca_overall$grp$Site,
                     color = groups))+
      
      scale_color_manual(values = pal_saturation,
                         #breaks = c("timezero", "drought", "d+rewet"),
                         #labels = c("timezero", "drought", "rewet")
      )+
      xlim(-4,4)+
      ylim(-3.5,3.5)+
      labs(shape="",
           #title = "all samples",
           #subtitle = "separation by saturation type"
           title = "NMR: 0-5 cm only")+
      theme_kp()+
      NULL)
  
  
  #
  
}
