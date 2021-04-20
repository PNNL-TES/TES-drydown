source("code/0-drydown_functions.R")

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
  # drop_na() %>% 
  ggplot(aes(x = length, y = TN_perc))+
  geom_point(aes(color = location, shape = drying),
             position = position_dodge(width = 0.5))+
  facet_grid(depth ~ Site)+
  theme_kp()+
  NULL


na = tctn_processed %>% 
  filter(is.na(Core_assignment))
