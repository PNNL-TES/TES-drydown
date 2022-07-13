
source("code/0-drydown_functions.R")
library(googlesheets4)


# dockey = read.csv("data/doc_analysis_key.csv") 

process_weoc_data = function(dockey){
  
  core_weights = read.csv("data/processed/core_weights_depth.csv") 
 # weoc_subsampling = read.csv("data/weoc_subsampling_weights.csv") %>% 
 #   mutate(coreID = case_when(Site == "CPCRW" ~ paste0("C", Core),
 #                             Site == "SR" ~ paste0("S", Core)))
  
  weoc_subsampling = read_sheet("1Ld-oTByerCn_C506_E1h8Kcnb5wpTVMxfPZh8bCoBwY") %>% 
    mutate(coreID = case_when(Site == "CPCRW" ~ paste0("C", Core),
                              Site == "SR" ~ paste0("S", Core)),
           depth = str_remove_all(depth, " "))
  
  filePaths_npoc <- list.files(path = "data/npoc",pattern = "*.csv", full.names = TRUE)
  
  npoc_data <-
    lapply(filePaths_npoc, read.csv, stringsAsFactors = FALSE, na.string = "") %>% 
    bind_rows() %>% 
    filter(is.na(notes))
  
  npoc_data_processed = 
    npoc_data %>% 
    # clean the sample IDs, currently in weird format
    # extract the numbers, then add leading zeroes to make three digits
    # then add "DOC-" and merge with DOC key
    mutate(id = parse_number(sample),
           id = as.integer(str_remove_all(id, "-")),
           id = sprintf("%03d", id),
           DOC_ID = paste0("DOC-", id)) %>% 
    dplyr::select(DOC_ID, npoc_mg_l) %>% 
    left_join(dockey %>% dplyr::select(DOC_ID, coreID, depth)) %>% 
    left_join(weoc_subsampling %>% dplyr::select(coreID, depth, moisture_perc, fticr_wt_g), by = c("coreID", "depth")) %>% 
    mutate(ode_g = fticr_wt_g/((moisture_perc/100) + 1),
           soilwater_mL = fticr_wt_g - ode_g,
           npoc_mg_g = npoc_mg_l * (40 + soilwater_mL) * (1/1000) * (1/ode_g)) %>% 
    left_join(dockey) %>% 
    mutate(saturation = factor(saturation, levels = c("timezero", "instant chemistry", "saturated"))) %>% 
    filter(!is.na(npoc_mg_g))
  
  npoc_data_processed2 = 
    npoc_data_processed %>% 
    dplyr::select(DOC_ID, coreID, depth, Site, drying, saturation, npoc_mg_g) %>% 
    recode_saturation() %>% 
    recode_sites() %>% 
    recode_depth()
  
}


weoc_stats = function(weoc_processed){
  
  l = lm(npoc_mg_g ~ (Site + depth + saturation)^2, data = weoc_processed) 
  car::Anova(l)  
  
}

plot_weoc = function(weoc_processed){
  
  # get Tukey HSD letters
  fit_hsd <- function(dat) {
    a <-aov(npoc_mg_g ~ saturation, data = dat)
    h <-agricolae::HSD.test(a,"saturation")
    h$groups %>% mutate(type = row.names(.)) %>% 
      rename(label = groups,
             saturation = type) %>%  
      dplyr::select(saturation, label)
  }
  
  weoc_hsd = 
    weoc_processed %>% 
    group_by(Site, depth) %>% 
    do(fit_hsd(.)) %>% 
    refactor_saturation_levels()    
  
  weoc_processed %>% 
    filter(!is.na(npoc_mg_g)) %>% 
    ggplot(aes(x = Site, y = npoc_mg_g, color = saturation))+
    geom_point(size = 2.5, position = position_dodge(width = 0.7))+
    geom_text(data = weoc_hsd, aes(y = 2.2, label = label, group = saturation), 
              position = position_dodge(width = 0.7), color = "black", size = 5, 
              show.legend = F)+
    labs(x = "", y = "WEOC, mg/g", color = "")+
    scale_color_manual(values = pal_saturation)+
    facet_grid(depth ~ .)
  }


misc_weoc_script = function(){
  npoc_summary = 
    npoc_data_processed %>% 
    filter(saturation != "timezero") %>% 
    group_by(Site, depth, length, drying, saturation) %>% 
    dplyr::summarise(npoc_mean = mean(npoc_mg_g),
                     se = sd(npoc_mg_g)/sqrt(n()),
                     npoc_mean = round(npoc_mean, 2),
                     se = round(se, 2),
                     relabund = paste(npoc_mean, "\u00b1", se)) %>% 
    dplyr::select(-npoc_mean, -se)
  
  npoc_summary %>% 
    pivot_wider(names_from = "length", values_from = "relabund") %>% 
    knitr::kable()
  
  
  ## LME for WEOC
  npoc_data_processed %>% 
    filter(saturation != "timezero") %$% 
    nlme::lme(npoc_mg_g ~ saturation + length + drying + depth, random = ~1|Site,
              na.action = na.omit) %>% 
    anova()
  
  
}



