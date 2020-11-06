source("code/0-drydown_functions.R")
corekey = read.csv(COREKEY)

# tctn --------------------------------------------------------------------

tctn_data = read.csv("data/combined_site_tctn.csv")

tctn_data_processed = 
  tctn_data %>% 
  # remove flagged rows
  # but first, change blank cells to NA for easy filtering
  mutate_all(na_if,"") %>% 
  filter(is.na(flag)) %>% 
  # split sample column into two columns for coreID and depth
  # but first, clean the column to remove unnecessary commas and to fix C69 entry
  mutate(sample = str_replace_all(sample, ",", ""),
         sample = str_replace_all(sample, "695", "69 5")) %>% 
  separate(sample, sep = " ", into = c("coreID", "depth")) %>% 
  # 5cm-end values are coded in at least two ways. make them consistent
  mutate(depth = if_else(grepl("end", depth), "5cm-end", "0-5cm")) %>% 
  # combine with the corekey
  left_join(corekey, by = "coreID") %>% 
  # not all samples have a Site assigned (???), so use the coreID to assign Site
  mutate(Site = case_when(grepl("C", coreID) ~ "CPCRW", 
                          grepl("S", coreID) ~ "SR")) %>% 
  # subset only the columns we need
  dplyr::select(Info, flag, coreID, depth, TN_perc, TC_perc, C_N, Site, location, drying, length)






# POM-nonPOM --------------------------------------------------------------

pom_data = read.csv("data/combined_site_pom.csv")



# WEOC --------------------------------------------------------------------



weoc_data = read_excel("data/Sarah_Alaska_Extr_NPOC_Sept17-Sept21_2020.xlsx", sheet = "ave NPOC no stds listed", skip=3) 

weoc_cleaned = 
  weoc_data %>% 
  rename(sample = `Sample Name`) %>% 
  separate(sample, sep = "-", into = c("colA", "DOCID")) %>% 
  mutate(DOCID = as.integer(DOCID))

weoc_key = read.csv("data/doc_analysis_key.csv")
weoc_key2 = 
  weoc_key %>% 
  separate(DOC_ID, sep = "-", into = c("colB", "DOCID")) %>% 
  mutate(DOCID = as.integer(DOCID))

weoc = 
  weoc_cleaned %>% 
  left_join(weoc_key2, by = "DOCID")

