source("code/0-drydown_functions.R")


#
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



# -------------------------------------------------------------------------
# -------------------------------------------------------------------------

filePaths_tctn <- list.files(path = "data/TCTN",pattern = "*.csv", full.names = TRUE)

tctn_data <-
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
  left_join(corekey_full %>% dplyr::select(coreID, Site, drying, length, location, saturation))


pom_key = read.csv("data/pom_key.csv")
corekey = read.csv("data/processed/corekey.csv", na = "")



pom_data_cleaned %>% 
  ggplot(aes(x = length, y = TC_perc, color = POM))+
  geom_point(position = position_dodge(width = 0.3))+
  facet_grid(drying ~ Site + Depth)



# clean corekey -----------------------------------------------------------
dockey = read.csv("data/doc_analysis_key.csv", na = "")

corekey_full = 
  full_join(corekey, dockey) %>% 
  mutate(location = recode(location, "up" = "upland", 
                           low = "lowland"),
         drying = recode(drying, "forced" = "FAD", 
                         "constant weight" = "CW"),
         length = str_replace(length, "day", "d"),
         DOC_analysis = !is.na(DOC_ID)) %>% 
  distinct(coreID, Site, location, drying, length, saturation, DOC_analysis) %>% 
  group_by(coreID) %>% 
  mutate(n = n()) %>% 
  filter(n == 1 | (n == 2 & DOC_analysis == TRUE)) %>% 
  dplyr::select(-n) %>% 
  mutate(saturation = if_else(DOC_analysis == FALSE, "saturated", saturation))
  
