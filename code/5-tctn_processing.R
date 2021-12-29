source("code/0-drydown_functions.R")
library(googlesheets4)

#
old_script = function(){
# -------------------------------------------------------------------------

tctn_data = read.csv("data/combined_site_tctn.csv", na.strings = "")
corekey = read.csv("data/processed/corekey.csv")
tctn_processed = 
  tctn_data %>% 
  filter(is.na(flag)) %>% 
  separate(sample, sep = " ", into = c("coreID", "depth")) %>% 
  mutate(coreID = str_remove_all(coreID, ","),
         depth = recode(depth, "5-end" = "5cm-end")) %>% 
  left_join(corekey)


tctn_processed %>% 
 # drop_na() %>% 
  ggplot(aes(x = length, y = TC_perc))+
  geom_point(aes(color = location, shape = drying),
             position = position_dodge(width = 0.5))+
  facet_grid(depth ~ Site)+
  theme_kp()+
  NULL

tctn_processed %>% 
  filter(!is.na(Core)) %>% 
  mutate(length = factor(length, levels = c("30 day",
                                            "90 day",
                                            "150 day",
                                            "1000 day"))) %>%
  # drop_na() %>% 
  ggplot(aes(x = length, y = TN_perc))+
  geom_point(aes(color = location, shape = drying),
             position = position_dodge(width = 0.5))+
  facet_grid(depth ~ Site)+
  theme_kp()+
  NULL


na = tctn_processed %>% 
  filter(is.na(Core_assignment))

tctn_summary = 
  tctn_processed %>% 
  group_by(Site, depth, drying, length) %>% 
  dplyr::summarise(TC = mean(TC_perc))


tctn_summary %>% 
  mutate(TC = round(TC,2),
         length = factor(length, levels = c("30 day",
                                            "90 day",
                                            "150 day",
                                            "1000 day"))) %>%
  drop_na() %>% 
  pivot_wider(names_from = "drying",
              values_from = "TC") %>% 
  arrange(Site, depth, length) %>% 
  knitr::kable()



# POM ---------------------------------------------------------------------

pom_data = read.csv("data/combined_site_pom.csv")
pom_key = read.csv("data/pom_key.csv")
corekey = read.csv("data/processed/corekey.csv")




}

# -------------------------------------------------------------------------
# -------------------------------------------------------------------------

pom_key = read.csv("data/pom_key.csv")
corekey = read.csv("data/processed/corekey.csv", na = "")


process_tctn_data = function(pom_key){
  # this function will process all TC-TN data from the Elemental Analyzer
  # this includes total C-N % as well as POM-nonPOM data
  
  filePaths_tctn <- list.files(path = "data/TCTN",pattern = "*.csv", full.names = TRUE)
  
  tctn_data =
    lapply(filePaths_tctn, read.delim, sep = ",",  na.string = "") %>% 
    bind_rows() %>% 
    dplyr::select(Info, Name, `N.....`, `C.....`, Memo, `Date.......Time`) %>% 
    rename(TN_perc = `N.....`,
           TC_perc = `C.....`,
           datetime = `Date.......Time`)
  
  tctn_data_processed = 
    tctn_data %>% 
    filter(grepl("S[0-9]", Name) | grepl("C[0-9]", Name) | grepl("POM", Name)) %>% 
    filter(is.na(Memo)) %>% 
    mutate(analysis = if_else(grepl("POM", Name), "POM-nonPOM", "totalCN"))
  
  
  totalcn_data = 
    tctn_data_processed %>% 
    filter(analysis == "totalCN")
  
  pom_data = 
    tctn_data_processed %>% 
    filter(analysis == "POM-nonPOM") %>% 
    mutate(Name = str_remove(Name, " ")) %>% 
    left_join(pom_key, by = c("Name" = "POM_ID"))
 
   
  list(totalcn_data = totalcn_data,
       pom_data = pom_data)
}

totalcn_data = process_tctn_data(pom_key)$totalcn_data
pom_data = process_tctn_data(pom_key)$pom_data

pom_weights = read_sheet("1rPYSz0JfPWs7tXVETTOM7t1vt8-jUwDH1CPT5U3lEvM")  
# pom_key = read_sheet("1rPYSz0JfPWs7tXVETTOM7t1vt8-jUwDH1CPT5U3lEvM", sheet = "pom_key")  


process_pom_data = function(pom_data, pom_weights, corekey_full){
  
  # first, clean up the POM/nonPOM data
  pom_data_temp1 = 
    pom_data %>% 
    filter(!is.na(coreID))
  
  pom_data_temp2 = 
    pom_data %>% 
    filter(is.na(coreID)) %>% 
    mutate(POM = case_when(grepl("NPOM", Name) ~ "non-POM",
                           grepl("POM", Name) ~ "POM"),
           Depth = case_when(grepl("0-5", Name) ~ "0-5 cm",
                             grepl("5-end", Name) ~ "5cm-end"),
           Name = str_remove(Name, "NPOM"),
           Name = str_remove(Name, "POM"),
           Name = str_remove(Name, "0-5"),
           Name = str_remove(Name, "5-end"),
           Name = str_remove(Name, " "),
           Name = str_remove(Name, "-"),
           coreID = Name)
  
  pom_data_cleaned = 
    bind_rows(pom_data_temp1, pom_data_temp2) %>% 
    dplyr::select(Info, Name, coreID, Depth, POM, TC_perc, TN_perc) %>% 
    mutate(Depth = str_remove(Depth, " ")) %>% 
    #left_join(corekey_full %>% dplyr::select(coreID, Site, drying, length, location, saturation)) %>% 
    force()
  
  # next, clean up the POM/nonPOM weights
  pom_weights_clean = 
    pom_weights %>% 
    filter(is.na(notes)) %>% 
    # fix depth values
    mutate(depth = str_remove(depth, " "),
           depth = dplyr::recode(depth, "5cm-endg" = "5cm-end"),
           Site_abbr = dplyr::recode(Site, "CPCRW" = "C", "SR" = "S"),
           coreID = paste0(Site_abbr, Core)) %>% 
    # calculate POM and nonPOM soil weights
    mutate(wt_POM_g = wt_al_drysoil_g - wt_al_tray_empty_g, # al
           wt_nonPOM_g = wt_plastic_drysoil_g - wt_plastic_tray_empty_g# plastic
    ) %>% 
    dplyr::select(Site, coreID, depth, wt_POM_g, wt_nonPOM_g) %>% 
    pivot_longer(-c(Site, coreID, depth), names_to = "POM", values_to = "wt_POM_g") %>% 
    mutate(POM = dplyr::recode(POM, "wt_POM_g" = "POM", "wt_nonPOM_g" = "non-POM")) %>% 
    group_by(coreID, depth) %>% 
    dplyr::mutate(wt_soil_g = sum(wt_POM_g)) %>% 
    ungroup()
  
  # finally, calcualte POC/nonPOC normalized to soil weight
  # pom_data_processed = 
    pom_data_cleaned %>% 
    rename(depth = Depth) %>% 
    left_join(pom_weights_clean) %>% 
    mutate(TC_mg = (TC_perc/100) * wt_POM_g * 1000,
           TC_mg_g = TC_mg/wt_soil_g,
           TC_mg_g = round(TC_mg_g, 2)) %>% 
    dplyr::select(Info, coreID, depth, POM, Site, TC_mg_g) %>% 
    left_join(corekey_full)
  
  
}


make_pom_graphs = function(pom_data_processed){
  pom_data_processed %>% 
    ggplot(aes(x = length, y = TC_mg_g, color = POM))+
    geom_point(position = position_dodge(width = 0.3))+
    facet_grid(drying ~ Site + depth)
  
}

# clean corekey -----------------------------------------------------------

more_script = function(){

dockey = read.csv("data/doc_analysis_key.csv", na = "")

corekey_full = 
  full_join(corekey, dockey) %>% 
  mutate(location = dplyr::recode(location, "up" = "upland", 
                           low = "lowland"),
         drying = dplyr::recode(drying, "forced" = "FAD", 
                         "constant weight" = "CW"),
         length = str_replace(length, "day", "d"),
         length = str_remove(length, " "),
         DOC_analysis = !is.na(DOC_ID)) %>% 
  distinct(coreID, Site, location, drying, length, saturation, DOC_analysis) %>% 
  group_by(coreID) %>% 
  mutate(n = n()) %>% 
  filter(n == 1 | (n == 2 & DOC_analysis == TRUE)) %>% 
  dplyr::select(-n) %>% 
  mutate(saturation = if_else(DOC_analysis == FALSE, "saturated", saturation))
  

corekey_full %>% write.csv("data/processed/corekey_v2.csv", row.names = FALSE)
}