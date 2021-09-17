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

