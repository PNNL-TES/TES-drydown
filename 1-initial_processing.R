### Jan 30, 2020

source("0-drydown_functions.R")

# 1. clean the corekey ----
cpcrw_key = read.csv("data/cpcrw_corekey.csv")

cpcrw_corekey = 
  cpcrw_key %>% 
  dplyr::mutate(coreID = paste0("C",Core),
                site="CPCRW",
                location = case_when(grepl("_up_",Core_assignment)~"upland",
                                     grepl("_low_",Core_assignment)~"lowland"),
                drying = case_when(grepl("_CW_",Core_assignment)~"constant weight",
                                     grepl("_FAD_",Core_assignment)~"forced"),
                length = case_when(grepl("_30d_",Core_assignment)~"30 day",
                                   grepl("_90d_",Core_assignment)~"90 day",
                                   grepl("_150d_",Core_assignment)~"150 day",
                                   grepl("_1000d_",Core_assignment)~"1000 day"),
                replicate = case_when(grepl("_r1",Core_assignment)~1,
                                      grepl("_r2",Core_assignment)~2,
                                      grepl("_r3",Core_assignment)~3,
                                      grepl("_r4",Core_assignment)~4))

## OUTPUT
write_csv(cpcrw_corekey, COREKEY)


# 2. get core/soil weights ----

## empty core weight
empty = read.csv("data/empty_core_weights.csv")
EMPTY = round(mean(empty$weight_sleeve_cap_nylon_label_g),2)

## initial field moisture
initial_weight_temp = read.csv("data/cpcrw_valve_map.csv") 

initial_weight = 
  initial_weight_temp %>% 
  filter(Notes1=="KP: initial weight") %>% 
  dplyr::select(Site, Core, Mass_g) %>% 
  dplyr::mutate(soil_fm_g = Mass_g - EMPTY)

## dry soil weights

### since these are intact cores, we have to back-calculate using data from core deconstruction.

# i. first, get gravimetric moisture data after core deconstruction
# the cores were split into two pieces (0-5cm, 5cm-end)

moisture_temp = read_excel("data/CPCRW_CW_subsampling_weights_6.26.xlsx", sheet = "CW moisture (2)")

moisture = 
  moisture_temp %>% 
  rename(Core = `Core #`) %>%
  filter(!is.na(Core)) %>% 
  filter(is.na(Flag)) %>% 
  group_by(Core, Depth) %>% 
  dplyr::summarise(moisture_pc = round(mean(`Moisture, %`, na.rm = TRUE),2),
                   moisture_cv = round((sd(`Moisture, %`, na.rm = TRUE)/mean(`Moisture, %`, na.rm = TRUE))*100,2)) %>% 
  dplyr::mutate(flag = case_when(moisture_cv>15~"highly variable moisture")) %>% 
  # RECODE ALL 5cm-endg AS 5cm-end. WTF
  dplyr::mutate(Depth = if_else(Depth=="5cm-endg","5cm-end",Depth))
###  **** currently not working because of badly formatted source file. ****


# ii. then, get "wet" weight for each depth and use gravimetric moisture to calculate OD weight for each depth.
# then add 0-5cm and 5cm-end to get OD weight for the entire core

raw_weight_temp = read_excel("data/CPCRW_CW_subsampling_weights_6.26.xlsx", sheet = "raw weights")

raw_weight = 
  raw_weight_temp[,1:8] %>% 
  dplyr::mutate(`0-5cm` = `soil_pan_weight_0-5cm_g` - `pan_weight_0-5cm_g`,
                `5cm-end` = `soil_pan_weight_5-end_cm_g` - `pan_weight_5-end_cm_g`) %>% 
  dplyr::rename(Core = `core #`) %>% 
  dplyr::select(Site, Core, `0-5cm`, `5cm-end`) %>% 
  tidyr::gather(Depth, wet_soil_g,`0-5cm`:`5cm-end`) %>% 
  left_join(moisture, by = c("Core","Depth")) %>% 
  dplyr::mutate(dry_soil_g = round(wet_soil_g/((moisture_pc/100)+1),2))

core_weight = 
  raw_weight %>% 
  group_by(Site, Core) %>% 
  dplyr::summarise(dry_soil_g = sum(dry_soil_g))


### OUTPUT
write.csv(raw_weight,"data/processed/core_weights_depth.csv", na = "", row.names = FALSE)
write.csv(core_weight,"data/processed/core_weights.csv", na = "", row.names = FALSE)
