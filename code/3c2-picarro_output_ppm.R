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
  valve_key_match_count = pcm$vkmc
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
  valve_key_match_count = pcm$vkmc
)




