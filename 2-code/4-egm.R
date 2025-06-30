
source("code/0-drydown_functions.R")

egm_data = read.csv("data/respiration_egm_jul2020.csv")
core_weights = read.csv("data/processed/core_weights.csv") %>% mutate(Core = as.character(Core))

egm_data_cleaned = 
  egm_data %>% 
  mutate(date = dmy(date)) %>% 
  select(date, Site, Core, PPM_CO2, Mass_g) %>% 
## normalize to wt of soil
  left_join(core_weights %>% select(Site, Core, dry_soil_g), by = c("Site", "Core")) %>% 
  mutate(CO2_ppm_g = round(PPM_CO2/dry_soil_g,2))


# output ------------------------------------------------------------------

write.csv(egm_data_cleaned, "data/processed/egm_concentrations.csv", row.names = F)
