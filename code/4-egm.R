
source("code/0-drydown_functions.R")

egm_data = read.csv("data/respiration_egm_jul2020.csv")

egm_data_cleaned = 
  egm_data %>% 
  mutate(date = dmy(date)) %>% 
  select(date, Site, Core, PPM_CO2, Mass_g)


# output ------------------------------------------------------------------

write.csv(egm_data_cleaned, "data/processed/egm_concentrations.csv", row.names = F)
