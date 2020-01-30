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
  group_by(Core, Depth) %>% 
  dplyr::summarise(moisture_pc = mean(`Moisture, %`))
###  **** currently not working because of badly formatted source file. ****


# ii. then, get "wet" weight for each depth and use gravimetric moisture to calculate OD weight for each depth.
# then add 0-5cm and 5cm-end to get OD weight for the entire core


