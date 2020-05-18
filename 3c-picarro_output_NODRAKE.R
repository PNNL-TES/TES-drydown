# use this script only for troubleshooting the drake plan

## 3b-Picarro graphs
## doing this without drake
## use drake only to read the Picarro data


source("0-drydown_functions.R")
#source("3a-picarro_functions.R")
source("2-picarro_data.R")

#devtools::install_github("jakelawlor/PNWColors") 
#library(PNWColors)

## cpcrw ----
  core_key = read.csv("data/processed/corekey.csv", stringsAsFactors = FALSE)
  
  core_dry_weights = read.csv("data/processed/core_weights.csv", stringsAsFactors = FALSE) %>%
    dplyr::mutate(Core = as.character(Core))
  
  core_masses = read.csv("data/cpcrw_valve_map.csv", stringsAsFactors = FALSE) %>%
    filter(Start_Time != "" & Stop_Time != "" & Stop_Date != "") %>% 
    dplyr::mutate(Start_datetime = ymd_hm(paste(Start_Date, Start_Time), tz = "America/Los_Angeles"),
                  Stop_datetime = ymd_hm(paste(Stop_Date, Stop_Time), tz = "America/Los_Angeles")) %>% 
    
    left_join(core_key, by = c("Site","Core")) %>% 
    left_join(core_dry_weights, by = c("Site","Core"))
  
  valve_key = filter(core_masses, !Seq.Program == "mass_only") %>% filter(Site=="CPCRW")
  
  
  
  # Picarro data
  # Using the 'trigger' argument below means we only re-read the Picarro raw
  # data when necessary, i.e. when the files change
  #picarro_raw = target(process_directory(PICARROPATH),
  #                     trigger = trigger(change = list.files(PICARROPATH, pattern = "dat$", recursive = TRUE))),
  
  # this next line is for running it without Drake
   picarro_raw = sapply(list.files(path = PICARROPATH, pattern = "dat$", recursive = TRUE,full.names = TRUE),
                                  read.table,header=TRUE, simplify = FALSE) %>% bind_rows()  
  
  picarro_clean = clean_picarro_data(picarro_raw)
  
  # Match Picarro data with the valve key data
  pcm = match_picarro_data(picarro_clean, valve_key)
  picarro_clean_matched = pcm$pd
  picarro_match_count = pcm$pmc
  valve_key_match_count = pcm$vkmc
  
  qc1 = qc_match(picarro_clean, picarro_clean_matched, valve_key, picarro_match_count, valve_key_match_count)
  qc2 = qc_concentrations(picarro_clean_matched, valve_key)
  
  ghg_fluxes = compute_ghg_fluxes(picarro_clean_matched, valve_key)
  qc3 = qc_fluxes(ghg_fluxes, valve_key)
  
  gf = 
    ghg_fluxes %>% 
    left_join(core_key, by = "Core") %>% 
    filter(flux_co2_umol_g_s >= 0) %>% 
    # remove outliers
    group_by(Core_assignment) %>% 
    dplyr::mutate(mean = mean(flux_co2_umol_g_s),
                  median = median(flux_co2_umol_g_s),
                  sd = sd(flux_co2_umol_g_s)) %>% 
    ungroup %>% 
    dplyr::mutate(outlier = flux_co2_umol_g_s - mean > 4 * sd)
  
  gf_no_outliers = dplyr::filter(gf, !outlier)
  
  #summarizing  
  cum_flux = 
    gf_no_outliers %>%
    group_by(Core) %>% 
    dplyr::summarise(cum = sum(flux_co2_umol_g_s),
                     max = max(flux_co2_umol_g_s),
                     #cumC = sum(flux_co2_umol_gC_s),
                     #maxC = max(flux_co2_umol_gC_s),
                     mean = mean(flux_co2_umol_g_s),
                     #meanC = mean(flux_co2_umol_gC_s),
                     median = median(flux_co2_umol_g_s),
                     #medianC = median(flux_co2_umol_gC_s),
                     sd = sd(flux_co2_umol_g_s),
                     #sdC = sd(flux_co2_umol_gC_s),
                     cv = sd/mean,
                     #cvC = sdC/meanC,
                     se = sd/sqrt(n()),
                     n = n()) %>% 
    left_join(core_key, by = "Core"
    )
  
  meanflux = 
    cum_flux %>% 
    group_by(Site, drying, length) %>% 
    dplyr::summarize(cum = mean(cum),
                     max = mean(max),
                     #cumC = mean(cumC),
                     #maxC = mean(maxC),
                     mean = mean(mean),
                     #meanC = mean(meanC),
                     median = mean(median),
                     #medianC = mean(medianC)
    )

## sr ----
  core_key = read.csv("data/processed/corekey.csv", stringsAsFactors = FALSE)
  
  core_dry_weights = read.csv("data/processed/core_weights.csv", stringsAsFactors = FALSE) %>%
    dplyr::mutate(Core = as.character(Core))
  
  core_masses = read.csv("data/sr_valve_map.csv", stringsAsFactors = FALSE) %>%
    filter(Start_Time != "" & Stop_Time != "" & Stop_Date != "") %>% 
    dplyr::mutate(Start_datetime = ymd_hm(paste(Start_Date, Start_Time), tz = "America/Los_Angeles"),
                  Stop_datetime = ymd_hm(paste(Stop_Date, Stop_Time), tz = "America/Los_Angeles"),
                  Core = as.character(Core)) %>% 
    
    left_join(core_key, by = c("Site","Core")) %>% 
    left_join(core_dry_weights, by = c("Site","Core"))
  
  valve_key = filter(core_masses, !Seq.Program == "mass_only") %>% filter(Site=="SR")
  
  
  
  # Picarro data
  # Using the 'trigger' argument below means we only re-read the Picarro raw
  # data when necessary, i.e. when the files change
  #picarro_raw = target(process_directory(PICARROPATH),
  #                     trigger = trigger(change = list.files(PICARROPATH, pattern = "dat$", recursive = TRUE))),
  
  # this next line is for running it without Drake
  picarro_raw = sapply(list.files(path = PICARROPATH, pattern = "dat$", recursive = TRUE,full.names = TRUE),
                       read.table,header=TRUE, simplify = FALSE) %>% bind_rows()  
  
  picarro_clean = clean_picarro_data(picarro_raw)
  
  # Match Picarro data with the valve key data
  pcm = match_picarro_data(picarro_clean, valve_key)
  picarro_clean_matched = pcm$pd
  picarro_match_count = pcm$pmc
  valve_key_match_count = pcm$vkmc
  
  qc1 = qc_match(picarro_clean, picarro_clean_matched, valve_key, picarro_match_count, valve_key_match_count)
  qc2 = qc_concentrations(picarro_clean_matched, valve_key)
  
  ghg_fluxes = compute_ghg_fluxes(picarro_clean_matched, valve_key)
  qc3 = qc_fluxes(ghg_fluxes, valve_key)
  
  gf = 
    ghg_fluxes %>% 
    left_join(core_key, by = "Core") %>% 
    filter(flux_co2_umol_g_s >= 0) %>% 
    # remove outliers
    group_by(Core_assignment) %>% 
    dplyr::mutate(mean = mean(flux_co2_umol_g_s),
                  median = median(flux_co2_umol_g_s),
                  sd = sd(flux_co2_umol_g_s)) %>% 
    ungroup %>% 
    dplyr::mutate(outlier = flux_co2_umol_g_s - mean > 4 * sd)
  
  gf_no_outliers = dplyr::filter(gf, !outlier)
  
  #summarizing  
  cum_flux = 
    gf_no_outliers %>%
    group_by(Core) %>% 
    dplyr::summarise(cum = sum(flux_co2_umol_g_s),
                     max = max(flux_co2_umol_g_s),
                     #cumC = sum(flux_co2_umol_gC_s),
                     #maxC = max(flux_co2_umol_gC_s),
                     mean = mean(flux_co2_umol_g_s),
                     #meanC = mean(flux_co2_umol_gC_s),
                     median = median(flux_co2_umol_g_s),
                     #medianC = median(flux_co2_umol_gC_s),
                     sd = sd(flux_co2_umol_g_s),
                     #sdC = sd(flux_co2_umol_gC_s),
                     cv = sd/mean,
                     #cvC = sdC/meanC,
                     se = sd/sqrt(n()),
                     n = n()) %>% 
    left_join(core_key, by = "Core"
    )
  
  meanflux = 
    cum_flux %>% 
    group_by(Site, drying, length) %>% 
    dplyr::summarize(cum = mean(cum),
                     max = mean(max),
                     #cumC = mean(cumC),
                     #maxC = mean(maxC),
                     mean = mean(mean),
                     #meanC = mean(meanC),
                     median = mean(median),
                     #medianC = mean(medianC)
    )
  
# plot ----

ggplot(gf, aes(x = DATETIME, y = flux_co2_umol_g_s*1000, color = Core))+
  geom_point()+
  facet_grid(drying~length, scale = "free_x")
  






