## 3b-Picarro graphs
## doing this without drake
## use drake only to read the Picarro data


source("code/0-drydown_functions.R")
source("code/2-picarro_data.R")


## cpcrw ----
cpcrw_plan_ppm <- drake_plan(
  
  core_key = read.csv("data/processed/corekey.csv", stringsAsFactors = FALSE),
  
  core_dry_weights = read.csv("data/processed/core_weights.csv", stringsAsFactors = FALSE) %>%
    dplyr::mutate(Core = as.character(Core)),
  
  core_masses = read.csv("data/cpcrw_valve_map.csv", stringsAsFactors = FALSE) %>%
    filter(Start_Time != "" & Stop_Time != "" & Stop_Date != "") %>% 
    dplyr::mutate(Start_datetime = ymd_hm(paste(Start_Date, Start_Time), tz = "America/Los_Angeles"),
                  Stop_datetime = ymd_hm(paste(Stop_Date, Stop_Time), tz = "America/Los_Angeles")) %>% 
    
    left_join(core_key, by = c("Site","Core")) %>% 
    left_join(core_dry_weights, by = c("Site","Core")),
  
  valve_key = filter(core_masses, !Seq.Program == "mass_only") %>% filter(Site=="CPCRW"),
  
  # Picarro data
  # Using the 'trigger' argument below means we only re-read the Picarro raw
  # data when necessary, i.e. when the files change
  picarro_raw = target(process_directory(PICARROPATH),
                       trigger = trigger(change = list.files(PICARROPATH, pattern = "dat$", recursive = TRUE))),
  
  # this next line is for running it without Drake
  # picarro_raw = sapply(list.files(path = PICARROPATH, pattern = "dat$", recursive = TRUE,full.names = TRUE),
  #                                read.table,header=TRUE, simplify = FALSE) %>% bind_rows(),  
  
  picarro_clean = clean_picarro_data(picarro_raw),
  
  # Match Picarro data with the valve key data
  pcm = match_picarro_data(picarro_clean, valve_key),
  picarro_clean_matched = pcm$pd,
  picarro_match_count = pcm$pmc,
  valve_key_match_count = pcm$vkmc,
  
  # match valve key and core key
  output =
    subset(merge(picarro_clean_matched, 
                 valve_key %>% dplyr::select(Core, Start_datetime, Stop_datetime, Treatment)),
           DATETIME <= Stop_datetime & DATETIME >= Start_datetime & Core == Core) %>% 
    dplyr::select(-Start_datetime, -Stop_datetime) %>% 
    left_join(core_key %>% filter(Site=="CPCRW"), by = "Core") %>% 
    dplyr::select(Core, DATETIME, MPVPosition, CH4_dry, CO2_dry, Elapsed_seconds, 
                  Treatment, coreID, Site, location, drying, length, replicate, Core_assignment)
 # %>% 
 #   group_by(Core_assignment) %>% 
 #   dplyr::mutate(mean = mean(CO2_dry),
 #                 median = median(CO2_dry),
 #                 sd = sd(CO2_dry)) %>% 
 #   ungroup %>% 
 #   dplyr::mutate(outlier = CO2_dry - mean > 4 * sd)
    
)


#
## sr ----
sr_plan_ppm <- drake_plan(
  
  core_key = read.csv("data/processed/corekey.csv", stringsAsFactors = FALSE),
  
  core_dry_weights = read.csv("data/processed/core_weights.csv", stringsAsFactors = FALSE) %>%
    dplyr::mutate(Core = as.character(Core)),
  
  core_masses = read.csv("data/sr_valve_map.csv", stringsAsFactors = FALSE) %>%
    filter(Start_Time != "" & Stop_Time != "" & Stop_Date != "") %>% 
    dplyr::mutate(Start_datetime = ymd_hm(paste(Start_Date, Start_Time), tz = "America/Los_Angeles"),
                  Stop_datetime = ymd_hm(paste(Stop_Date, Stop_Time), tz = "America/Los_Angeles"),
                  Core = as.character(Core)) %>% 
    
    left_join(core_key, by = c("Site","Core")) %>% 
    left_join(core_dry_weights, by = c("Site","Core")),
  
  valve_key = filter(core_masses, !Seq.Program == "mass_only") %>% filter(Site=="SR"),
  
  # Picarro data
  # Using the 'trigger' argument below means we only re-read the Picarro raw
  # data when necessary, i.e. when the files change
  picarro_raw = target(process_directory(PICARROPATH),
                       trigger = trigger(change = list.files(PICARROPATH, pattern = "dat$", recursive = TRUE))),
  
  # this next line is for running it without Drake
  # picarro_raw = sapply(list.files(path = PICARROPATH, pattern = "dat$", recursive = TRUE,full.names = TRUE),
  #                                read.table,header=TRUE, simplify = FALSE) %>% bind_rows(),  
  
  picarro_clean = clean_picarro_data(picarro_raw),
  
  # Match Picarro data with the valve key data
  pcm = match_picarro_data(picarro_clean, valve_key),
  picarro_clean_matched = pcm$pd,
  picarro_match_count = pcm$pmc,
  valve_key_match_count = pcm$vkmc,
  
  # match valve key and core key
  output =
    subset(merge(picarro_clean_matched, 
                 valve_key %>% dplyr::select(Core, Start_datetime, Stop_datetime, Treatment)),
           DATETIME <= Stop_datetime & DATETIME >= Start_datetime & Core == Core) %>% 
    dplyr::select(-Start_datetime, -Stop_datetime) %>% 
    left_join(core_key %>% filter(Site=="SR"), by = "Core") %>% 
    dplyr::select(Core, DATETIME, MPVPosition, CH4_dry, CO2_dry, Elapsed_seconds, 
                  Treatment, coreID, Site, location, drying, length, replicate, Core_assignment)
  
)




