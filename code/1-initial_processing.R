### Jan 30, 2020

source("code/0-drydown_functions.R")

# SOIL 1: CPCRW ----
# 1. clean the corekey ----
cpcrw_key = read.csv("data/cpcrw_corekey.csv", stringsAsFactors = F)

cpcrw_corekey = 
  cpcrw_key %>% 
  dplyr::mutate(coreID = paste0("C",Core),
                Site="CPCRW",
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
# write_csv(cpcrw_corekey, COREKEY)


# 2. get core/soil weights ----

## empty core weight ----
## this empty weight includes: the sleeve; one (1) cap; a piece of nylon mesh; and a label from the label maker
empty = read.csv("data/empty_core_weights.csv")
EMPTY = round(mean(empty$weight_sleeve_cap_nylon_label_g),2)


## core weights ----
## initial field moisture
c_initial_weight_temp = read.csv("data/cpcrw_valve_map.csv") 

c_initial_weight = 
  c_initial_weight_temp %>% 
  filter(Notes1=="KP: initial weight") %>% 
  dplyr::select(Site, Core, Mass_g) %>% 
  dplyr::mutate(soil_fm_g = Mass_g - EMPTY)

## dry soil weights ----

### since these are intact cores, we have to back-calculate using data from core deconstruction.

# i. first, get gravimetric moisture data after core deconstruction
# the cores were split into two pieces (0-5cm, 5cm-end)

c_moisture_temp = read_excel("data/CPCRW_CW_subsampling_weights_6.26.xlsx", sheet = "CW moisture (2)")

c_moisture = 
  c_moisture_temp %>% 
  rename(Core = `Core #`) %>%
  filter(!is.na(Core)) %>% 
  filter(is.na(Flag)) %>% 
  group_by(Core, Depth) %>% 
  dplyr::summarise(moisture_pc = round(mean(`Moisture, %`, na.rm = TRUE),2),
                   moisture_cv = round((sd(`Moisture, %`, na.rm = TRUE)/mean(`Moisture, %`, na.rm = TRUE))*100,2)) %>% 
  dplyr::mutate(flag = case_when(moisture_cv>15~"highly variable moisture")) %>% 
  # RECODE ALL 5cm-endg AS 5cm-end. WTF
  dplyr::mutate(Depth = if_else(Depth=="5cm-endg","5cm-end",Depth))

# ii. then, get "wet" weight for each depth and use gravimetric moisture to calculate OD weight for each depth.
# then add 0-5cm and 5cm-end to get OD weight for the entire core

c_raw_weight_temp = read_excel("data/CPCRW_CW_subsampling_weights_6.26.xlsx", sheet = "raw weights")

C_PAN_WEIGHT = 
  c_raw_weight_temp %>% 
  dplyr::select(`pan_weight_0-5cm_g`, `pan_weight_5-end_cm_g`) %>% 
  reshape2::melt() %>% 
  dplyr::summarize(mean = round(mean(value),2)) %>% 
  pull(mean)

c_raw_weight = 
  c_raw_weight_temp %>% 
  #filter(is.na(flag)) %>%
  dplyr::rename(Core = `core #`) %>% 
  dplyr::mutate(wet_soil_0_5cm = `0-5 cm post sieving weight` - C_PAN_WEIGHT,
                wet_soil_5cm_end = `5cm-end post sieving weight` - C_PAN_WEIGHT,
                coarse_0_5cm = `soil_pan_weight_0-5cm_g` - `0-5 cm post sieving weight`,
                coarse_5cm_end = `soil_pan_weight_5-end_cm_g` - `5cm-end post sieving weight`) %>% 
  dplyr::select(Site, Core, wet_soil_0_5cm, wet_soil_5cm_end, coarse_0_5cm, coarse_5cm_end) %>% 
  reshape2::melt(id = c("Site", "Core")) %>% 
  dplyr::mutate(Depth = case_when(grepl("0_5", variable)~"0-5cm",
                                  grepl("5cm_end", variable)~"5cm-end"),
                type = case_when(grepl("wet", variable)~"wet_soil_g",
                                 grepl("coarse", variable)~"coarse_g")) %>% 
  dplyr::select(Site, Core, Depth, type, value) %>% 
  spread(type, value) %>% 
  
  left_join(dplyr::select(c_moisture, Core, Depth, moisture_pc), by = c("Core","Depth")) %>% 
  dplyr::mutate(dry_fine_g = round(wet_soil_g/((moisture_pc/100)+1),2)) %>% 
  filter(dry_fine_g>0)
## CHECK CORE 26. 5CM-END WEIGHT IS F-D UP. NEGATIVE ----

c_core_weight = 
  c_raw_weight %>% 
  group_by(Site, Core) %>% 
  dplyr::summarise(dry_fine_g = sum(dry_fine_g),
                   coarse_g = sum(coarse_g),
                   dry_soil_g = dry_fine_g+coarse_g)

    ## OLD CODE. DID NOT SEPARATE COARSE FROM FINE FRACTION. WRONG. 
    ## c_raw_weight = 
    ##   c_raw_weight_temp[,1:8] %>% 
    ##   dplyr::mutate(`0-5cm` = `soil_pan_weight_0-5cm_g` - `pan_weight_0-5cm_g`,
    ##                 `5cm-end` = `soil_pan_weight_5-end_cm_g` - `pan_weight_5-end_cm_g`) %>% 
    ##   dplyr::rename(Core = `core #`) %>% 
    ##   dplyr::select(Site, Core, `0-5cm`, `5cm-end`) %>% 
    ##   tidyr::gather(Depth, wet_soil_g,`0-5cm`:`5cm-end`) %>% 
    ##   left_join(moisture, by = c("Core","Depth")) %>% 
    ##   dplyr::mutate(dry_soil_g = round(wet_soil_g/((moisture_pc/100)+1),2))


### ugh. 12-May-2020 KP ----
# some core weights are not currently available on the Google Doc
# 30-day and 90-day CW cores
# so, use weights from drought incubation, assuming completely dry
# later, we will replace these with actual weights

# first, create a subset of the required cores
cpcrw_subset = 
  cpcrw_corekey %>% 
  filter(drying=="constant weight" & 
           (length=="30 day"|length=="90 day")) %>% 
  pull(Core)

# next, pull the corresponding weights from the valvekey file
core_key = read.csv("data/processed/corekey.csv", stringsAsFactors = FALSE)
core_masses = read.csv("data/cpcrw_valve_map.csv", stringsAsFactors = FALSE) %>%
  filter(Start_Time != "" & Stop_Time != "" & Stop_Date != "") %>% 
  dplyr::mutate(Start_datetime = ymd_hm(paste(Start_Date, Start_Time), tz = "America/Los_Angeles"),
                Stop_datetime = ymd_hm(paste(Stop_Date, Stop_Time), tz = "America/Los_Angeles")) %>% 
  
  left_join(core_key, by = c("Site","Core")) 

masses_subset = 
  core_masses %>% 
  filter(Site=="CPCRW" & !Seq.Program == "mass_only") %>% 
  filter(Core %in% cpcrw_subset) %>% 
  # find the lowest weight per core
  ungroup %>% 
  group_by(Core) %>% 
  dplyr::summarize(core_wt_g = min(Mass_g, na.rm = T),
                   dry_soil_g = core_wt_g - EMPTY,
                   Site="CPCRW") %>% 
  dplyr::select(Site, Core, dry_soil_g) %>% 
  dplyr::mutate(Core = as.numeric(Core))

c_core_weight2 = bind_rows(c_core_weight, masses_subset)

### OUTPUT ----
# write.csv(raw_weight,"data/processed/core_weights_depth.csv", na = "", row.names = FALSE)
# write.csv(core_weight2,"data/processed/core_weights.csv", na = "", row.names = FALSE)

#
##-------------------------## #### 
# SOIL 2: SECRET RIVER ----
# repeat the same steps as above, for the SR soils
# 1. clean the corekey ----
sr_key = read.csv("data/sr_corekey.csv", stringsAsFactors = F) %>% dplyr::select(1:3)

sr_corekey = 
  sr_key %>% 
  dplyr::mutate(coreID = paste0("S",Core),
                Core = as.character(Core),
                Site="SR",
                location = case_when(grepl("_up_",Core_assignment)~"upland",
                                     grepl("_low_",Core_assignment)~"lowland"),
                drying = case_when(grepl("_CW_",Core_assignment)~"constant weight",
                                   grepl("_FAD_",Core_assignment)~"forced"),
                length = case_when(grepl("_30d_",Core_assignment)~"30 day",
                                   grepl("_90d_",Core_assignment)~"90 day",
                                   grepl("_150d_",Core_assignment)~"150 day",
                                   grepl("_1000d_",Core_assignment)~"1000 day",
                                   grepl("time0",Core_assignment)~"time zero"),
                replicate = case_when(grepl("_r1",Core_assignment)~1,
                                      grepl("_r2",Core_assignment)~2,
                                      grepl("_r3",Core_assignment)~3,
                                      grepl("_r4",Core_assignment)~4)) %>% 
  filter(!is.na(length))

## OUTPUT
# write_csv(sr_corekey, COREKEY)

#

# 2. get core/soil weights ----
## core weights ---- 

## initial field moisture
s_initial_weight_temp = read.csv("data/sr_core_weights.csv") 

s_initial_weight = 
  s_initial_weight_temp %>% 
  dplyr::select(Site, Core, Mass_g = `Mass.with.both.end.caps..g.`) %>% 
  dplyr::mutate(soil_fm_g = Mass_g - (EMPTY+1.09))
## EMPTY was calculated using only 1 end cap. But the SR cores were weighed with 2 caps. So we add the weight of 1 cap (1.09g) to EMPTY
## dry soil weights ----

### since these are intact cores, we have to back-calculate using data from core deconstruction.

# i. first, get gravimetric moisture data after core deconstruction
# the cores were split into two pieces (0-5cm, 5cm-end)

s_moisture_temp = read_excel("data/sr-cores_picarro_mass_track.xlsx", sheet = "SR moisture (2)")

s_moisture = 
  s_moisture_temp %>% 
  rename(Core = `Core #`) %>%
  filter(!is.na(Core)) %>% 
  filter(is.na(Flag)) %>% 
  group_by(Core, Depth) %>% 
  dplyr::summarise(moisture_pc = round(mean(`Moisture, %`, na.rm = TRUE),2),
                   moisture_cv = round((sd(`Moisture, %`, na.rm = TRUE)/mean(`Moisture, %`, na.rm = TRUE))*100,2)) %>% 
  dplyr::mutate(flag = case_when(moisture_cv>15~"highly variable moisture")) %>% 
  # RECODE ALL 5cm-endg AS 5cm-end. WTF
  dplyr::mutate(Depth = if_else(grepl("end",Depth),"5cm-end", "0-5cm"))

# ii. then, get "wet" weight for each depth and use gravimetric moisture to calculate OD weight for each depth.
# then add 0-5cm and 5cm-end to get OD weight for the entire core

s_raw_weight_temp = read_excel("data/sr-cores_picarro_mass_track.xlsx", sheet = "raw weights (2)")

PAN_WEIGHT = 
  s_raw_weight_temp %>% 
  dplyr::select(`pan_weight_0-5cm_g`, `pan_weight_5-end_cm_g`) %>% 
  melt() %>% 
  dplyr::summarize(mean = round(mean(value),2)) %>% 
  pull(mean)

s_raw_weight = 
  s_raw_weight_temp %>% 
  filter(is.na(flag)) %>%
  dplyr::rename(Core = `core #`) %>% 
  dplyr::mutate(wet_soil_0_5cm = `0-5 cm post sieving weight` - PAN_WEIGHT,
                wet_soil_5cm_end = `5cm-end post sieving weight` - PAN_WEIGHT,
                coarse_0_5cm = `soil_pan_weight_0-5cm_g` - `0-5 cm post sieving weight`,
                coarse_5cm_end = `soil_pan_weight_5-end_cm_g` - `5cm-end post sieving weight`) %>% 
  dplyr::select(Site, Core, wet_soil_0_5cm, wet_soil_5cm_end, coarse_0_5cm, coarse_5cm_end) %>% 
  melt(id = c("Site", "Core")) %>% 
  dplyr::mutate(Depth = case_when(grepl("0_5", variable)~"0-5cm",
                                  grepl("5cm_end", variable)~"5cm-end"),
                type = case_when(grepl("wet", variable)~"wet_soil_g",
                                 grepl("coarse", variable)~"coarse_g")) %>% 
  dplyr::select(Site, Core, Depth, type, value) %>% 
  spread(type, value) %>% 
  
  left_join(dplyr::select(s_moisture, Core, Depth, moisture_pc), by = c("Core","Depth")) %>% 
  dplyr::mutate(dry_fine_g = round(wet_soil_g/((moisture_pc/100)+1),2))

s_core_weight = 
  s_raw_weight %>% 
  group_by(Site, Core) %>% 
  dplyr::summarise(dry_fine_g = sum(dry_fine_g),
                   coarse_g = sum(coarse_g),
                   dry_soil_g = dry_fine_g+coarse_g)


## OUTPUT ----
rbind(cpcrw_corekey, sr_corekey) %>% write_csv(COREKEY, na = "")
rbind(c_raw_weight, s_raw_weight) %>% write.csv("data/processed/core_weights_depth.csv", na = "", row.names = FALSE)
rbind(c_core_weight2, s_core_weight) %>% write.csv("data/processed/core_weights.csv", na = "", row.names = FALSE)

