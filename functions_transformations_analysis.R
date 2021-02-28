library(PNWColors)


# format the transformations output 

clean_transformations = function(transformation_count_long){
  transformation_count_long %>% 
    separate(sample, sep = "_", into = c("depth", "site", "length", "drying", "saturation"))
}
transformations_cleaned = clean_transformations(transformation_count_long)


# which were the top 10 transformations per sample?
compute_top_transformations = function(transformations_cleaned){
  transformations_cleaned %>% 
    group_by(depth, site, length, drying, saturation) %>% 
    #group_by(sample) %>% 
    top_n(20, percentage) %>% 
    #dplyr::select(-count, -total) %>% 
    #pivot_wider(names_from = "sample", values_from = "percentage") %>% 
    force()
    
}

top_transformations = compute_top_transformations(transformations_cleaned)

make_transformations_heatmap = function(top_transformations){
  top_transformations %>% 
    mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d")),
           saturation = recode(saturation, "instant chemistry" = "instant")) %>% 
    #filter(site == "CPCRW") %>% 
    ggplot(aes(x = drying, y = reorder(Trans_name, percentage), fill = percentage))+
    geom_tile(color = "white", size = 0)+
    facet_grid(depth ~ site + length + saturation, scales = "free_x")+
    scale_fill_gradientn(colours = pnw_palette("Sunset2"))+
    labs(title = "top 10 transformations",
         x = "",
         y = "",
         fill = "% occurrence",
         caption = "blank spaces = transformation was not seen")+
    theme_bw()+
    theme(panel.grid = element_blank())+
    NULL
  
  ggsave("data/processed/fticr/transformations_heatmap.png")
  top_transformations %>% 
    filter(site == "SR") %>% 
    ggplot(aes(x = drying, y = reorder(Trans_name, percentage), fill = percentage))+
    geom_tile(color = "white", size = 0.5)+
    facet_grid(. ~ length + saturation, scales = "free_x")+
    scale_fill_gradientn(colours = pnw_palette("Sunset2"))+
    theme_bw()+
    NULL
  
}

summarize_biotic_abiotic = function(transformations_cleaned){
  transformations_cleaned %>% 
    group_by(depth, site, length, drying, saturation, Biotic_abiotic) %>% 
    dplyr::summarise(n = n()) %>% 
    group_by(depth, site, length, drying, saturation) %>% 
    mutate(total = sum(n),
           percentage = (n/total)*100)
}
summary_biotic_abiotic = summarize_biotic_abiotic(transformations_cleaned)

summary_biotic_abiotic %>% 
  mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d")),
         saturation = recode(saturation, "instant chemistry" = "instant")) %>% 
  ggplot(aes(x = drying, y = percentage, fill = Biotic_abiotic))+
  geom_bar(stat = "identity")+
  labs(title = "biotic vs. abiotic transformations",
       x = "",
       y = "%",
       fill = "")+
  scale_fill_manual(values = soilpalettes::soil_palette("redox2", 3))+
  facet_grid(depth ~ site + length + saturation, scales = "free_x")+
  theme_bw()+
  NULL
ggsave("data/processed/fticr/transformations_biotic_abiotic.png")



# IMPORT FILES -- BOB'S OUTPUT ----------------------------------------------
filePaths <- list.files(path = "Transformation Peak Comparisons/drought_fullset/",pattern = "*.csv", full.names = TRUE)

# rbind.fill binds all rows and fills in missing columns
all_data <- do.call(rbind, lapply(filePaths, function(path) {
  df <- read.csv(path, header=TRUE)
  df}))


all_data_clean =
  all_data %>% 
  rename(Name = `Trans.name`) %>% 
  dplyr::select(sample, Name) 

all_data_counts = 
  all_data_clean %>% 
  group_by(sample, Name) %>% 
  dplyr::summarise(count = n())

all_data_normalized = 
  all_data_counts %>% 
  pivot_wider(names_from = "sample", values_from = "count") %>% 
  replace(is.na(.), 0) %>% 
  heatmaply::normalize() %>% 
  pivot_longer(-Name, values_to = "normalized", names_to = "sample") %>% 
  mutate(sample = str_remove_all(sample, "Sample_")) %>% 
  separate(sample, sep = "_", into = c("depth", "site", "length", "drying", "saturation"))

all_data_relabund = 
  all_data_counts %>% 
  group_by(sample) %>% 
  dplyr::mutate(total = sum(count)) %>% 
  ungroup() %>% 
  mutate(relabund = (count/total)*100) %>% 
  mutate(sample = str_remove_all(sample, "Sample_")) %>% 
  separate(sample, sep = "_", into = c("depth", "site", "length", "drying", "saturation"))



all_data_relabund %>% 
  mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d")),
       saturation = recode(saturation, "instant chemistry" = "instant")) %>% 
  #filter(site == "CPCRW") %>% 
  #filter(saturation == "timezero") %>% 
  ggplot(aes(x = drying, y = reorder(Name, relabund), fill = relabund))+
  geom_tile(color = "white", size = 0)+
  facet_grid(. ~ depth + site + length + saturation, scales = "free_x")+
  scale_fill_gradientn(colours = pnw_palette("Sunset2"))+
  labs(#title = "top 10 transformations",
       x = "",
       y = "",
       fill = "% occurrence",
       caption = "blank spaces = transformation was not seen")+
  theme_bw()+
  theme(panel.grid = element_blank())+
  NULL



all_data_normalized %>% 
  mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d")),
         saturation = recode(saturation, "instant chemistry" = "instant")) %>% 
  #filter(site == "CPCRW") %>% 
  #filter(saturation == "timezero") %>% 
  ggplot(aes(x = drying, y = reorder(Name, normalized), fill = normalized))+
  geom_tile(color = "white", size = 0)+
  facet_grid(depth ~ site + length + saturation, scales = "free_x")+
  scale_fill_gradientn(colours = pnw_palette("Sunset2"))+
  labs(#title = "top 10 transformations",
    x = "",
    y = "",
    fill = "occurrence (normalized)")+
  theme_bw()+
  theme(panel.grid = element_blank())+
  NULL






transformations_cleaned = 
  all_data %>% 
  rename(Name = `Trans.name`) %>% 
  dplyr::select(sample, Name) %>% 
  mutate(sample = str_remove_all(sample, "Sample_")) %>% 
  do(clean_transformations(.))










all_data_trans = 
  all_data %>% 
  dplyr::select(sample, `Trans.name`) %>% 
  rename(Name = `Trans.name`) %>% 
  left_join(trans.full)

biotic_abiotic_counts = 
  all_data_trans %>% 
  group_by(sample, Biotic_abiotic) %>% 
  dplyr::summarise(n = n()) %>% 
  group_by(sample) %>% 
  mutate(total = sum(n),
         percentage = (n/total)*100)




all_data_relabund_wide = 
  all_data_relabund %>% 
  #filter(length == "timezero") %>% 
  ungroup() %>% 
#  dplyr::select(-drying, -saturation) %>% 
  spread(Name, relabund) %>% 
  replace(is.na(.), 0)

permanova_fticr_all = 
  adonis(all_data_relabund_wide %>% dplyr::select(-c(depth:total)) ~ 
           (depth+site)^2, 
         data = all_data_relabund_wide)
broom::tidy(permanova_fticr_all$aov.tab)