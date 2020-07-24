## comparing sample lists

library(tidyverse)


# 1. which samples have been run for TC-TN? ----
tctn_samples = read.csv("data/combined_site_tctn.csv") %>% 
  dplyr::mutate(coreID = str_replace(sample, " 0-5cm",""),
                coreID = str_replace(coreID, " 5-end",""))


corekey = read.csv("data/processed/corekey.csv")


matched_tctn = 
  corekey %>% 
  left_join(tctn_samples, by = "coreID") %>% 
  dplyr::mutate(tctn_run = !is.na(sample)) %>% 
  filter(!length == "1000 day") %>% 
  dplyr::select(coreID, sample, tctn_run) %>% 
  distinct(coreID, tctn_run)

#
# 2. which samples have been run for POM-non-POM? ----
pom_samples = read.csv("data/combined_site_pom.csv")
pom_key = read.csv("data/pom_key.csv") %>% 
  dplyr::select(-Sample)

pom_tctn = 
  pom_key %>% 
  left_join(pom_samples, by = "POM_ID") %>% 
  filter(!is.na(C.N..ratio))

matched_pom = 
  corekey %>% 
  left_join(pom_tctn, by = "coreID") %>% 
  dplyr::mutate(pom_run = !is.na(POM_ID)) %>% 
  dplyr::select(coreID, pom_run, POM_ID) %>% 
  distinct(coreID, pom_run)
  
#
# 3. combine all ----
samples_run = 
  left_join(matched_tctn, matched_pom, by = "coreID")
