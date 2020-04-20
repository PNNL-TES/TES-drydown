## 3b-Picarro graphs
## doing this without drake
## use drake only to read the Picarro data


source("0-drydown_functions.R")
#source("3a-picarro_functions.R")
source("2-picarro_data.R")

#devtools::install_github("jakelawlor/PNWColors") 
#library(PNWColors)

plan <- drake_plan(

core_key = read.csv("data/processed/corekey.csv"),
  
core_dry_weights = read.csv("data/processed/core_weights.csv") %>% dplyr::mutate(Core = as.character(Core)),

core_masses = read.csv("data/cpcrw_valve_map.csv", stringsAsFactors = FALSE) %>%
  filter(Start_Time != "" & Stop_Time != "" & Stop_Date != "") %>% 
  dplyr::mutate(Start_datetime = ymd_hm(paste(Start_Date, Start_Time), tz = "America/Los_Angeles"),
                Stop_datetime = ymd_hm(paste(Stop_Date, Stop_Time), tz = "America/Los_Angeles")) %>% 
  
  left_join(core_key, by = c("Site","Core")) %>% 
  left_join(core_dry_weights, by = c("Site","Core")),

valve_key = filter(core_masses, !Seq.Program == "mass_only"),



  # Picarro data
  # Using the 'trigger' argument below means we only re-read the Picarro raw
  # data when necessary, i.e. when the files change
  picarro_raw = target(process_directory("data/picarro_data/"),
                       trigger = trigger(change = list.files("data/picarro_data/", pattern = "dat$", recursive = TRUE))),

# this next line is for running it without Drake
# picarro_raw = sapply(list.files(path = "data/picarro_data/",pattern = "dat$", recursive = TRUE,full.names = TRUE),
#                                read.table,header=TRUE, simplify = FALSE) %>% bind_rows(),  

picarro_clean = clean_picarro_data(picarro_raw),

  # Match Picarro data with the valve key data
  pcm = match_picarro_data(picarro_clean, valve_key),
  picarro_clean_matched = pcm$pd,
  picarro_match_count = pcm$pmc,
  valve_key_match_count = pcm$vkmc,
  
  qc1 = qc_match(picarro_clean, picarro_clean_matched, valve_key, picarro_match_count, valve_key_match_count),
  qc2 = qc_concentrations(picarro_clean_matched, valve_key),
  
  ghg_fluxes = compute_ghg_fluxes(picarro_clean_matched, valve_key),
  qc3 = qc_fluxes(ghg_fluxes, valve_key),
  
gf = 
  ghg_fluxes %>% 
  left_join(valve_key, by = "Core") %>% 
  mutate(Sand = if_else(grepl("sand", Core_assignment), "Soil_sand", "Soil"),
         Status = case_when(grepl("_D$", Core_assignment) ~ "Dry",
                            grepl("_W$", Core_assignment) ~ "Wet",
                            grepl("_fm$", Core_assignment) ~ "FM")) %>% 
  filter(flux_co2_umol_g_s>=0) %>% 
  left_join(select(core_key, Core,moisture_lvl,trt),by = "Core") %>% 
  # remove outliers
  group_by(Core_assignment) %>% 
  dplyr::mutate(mean = mean(flux_co2_umol_g_s),
                median = median(flux_co2_umol_g_s),
                sd = sd(flux_co2_umol_g_s)) %>% 
  ungroup %>% 
  dplyr::mutate(outlier = if_else((flux_co2_umol_g_s - mean) > 4*sd,"y",as.character(NA))) %>% 
  dplyr::filter(is.na(outlier)),

#summarizing  
  cum_flux = 
    gf %>%
    group_by(Core) %>% 
    dplyr::summarise(cum = sum(flux_co2_umol_g_s),
                     max = max(flux_co2_umol_g_s),
                     cumC = sum(flux_co2_umol_gC_s),
                     maxC = max(flux_co2_umol_gC_s),
                     mean = mean(flux_co2_umol_g_s),
                     meanC = mean(flux_co2_umol_gC_s),
                     median = median(flux_co2_umol_g_s),
                     medianC = median(flux_co2_umol_gC_s),
                     sd = sd(flux_co2_umol_g_s),
                     sdC = sd(flux_co2_umol_gC_s),
                     cv = sd/mean,
                     cvC = sdC/meanC,
                     se = sd/sqrt(n()),
                     n = n()) %>% 
  left_join(core_key, by = "Core"),  

#testing for outliers  
  gf_test = gf %>% group_by(Core_assignment) %>% 
  dplyr::mutate(mean_grp = mean(flux_co2_umol_g_s),
                sd_grp = sd(flux_co2_umol_g_s)) %>% 
  ungroup %>% 
  dplyr::mutate(outlier = if_else((flux_co2_umol_g_s - mean_grp) > 4*sd_grp,"y",as.character(NA))) %>% 
  dplyr::filter(is.na(outlier)),
#  

  meanflux = 
    cum_flux %>% 
    group_by(soil_type,moisture_lvl,trt) %>% 
    dplyr::summarize(cum = mean(cum),
                     max = mean(max),
                     cumC = mean(cumC),
                     maxC = mean(maxC),
                     mean = mean(mean),
                     meanC = mean(meanC),
                     median = mean(median),
                     medianC = mean(medianC)),
  
  mean_percsat = 
    cum_flux %>% 
    group_by(soil_type,perc_sat,trt) %>% 
    dplyr::summarize(cum = mean(cum),
                     max = mean(max),
                     cumC = mean(cumC),
                     maxC = mean(maxC),
                     mean = mean(mean),
                     meanC = mean(meanC))
  
  
  )
  
      ##  gf = readd(gf)
      ##  
      ##  gf %>% 
      ##    dplyr::select(Core, Core_assignment,Moisture_perc, Sand, Status, soil_type, moisture_lvl,trt,
      ##                  DATETIME, flux_co2_umol_g_s, flux_co2_umol_gC_s) %>% 
      ##    group_by(Core_assignment) %>% 
      ##    dplyr::mutate(mean = mean(flux_co2_umol_g_s),
      ##                  sd = sd(flux_co2_umol_g_s),
      ##                  outlier = if_else((flux_co2_umol_g_s-mean)/sd > 3,"y",as.character(NA)))->gf_test
      ##  
      ##  
      ##  
      ##  ggplot(gf_test, aes(x = as.character(Core),y = flux_co2_umol_g_s*1000, color = outlier, shape = soil_type))+
      ##    geom_point()+
      ##    facet_wrap(~Core_assignment, scale = "free_x")
      ##  





##  picarro_clean_matched = readd(picarro_clean_matched)
##  
##  ghg_fluxes = compute_ghg_fluxes(picarro_clean_matched, valve_key)
##  qc3 = qc_fluxes(ghg_fluxes, valve_key)
##  
##  # compute fluxes per gram of C
##  
##  #summarizing  
##  ghg_fluxes %>%
##      group_by(Core) %>% 
##      dplyr::summarise(cum = sum(flux_co2_umol_g_s),
##                       max = max(flux_co2_umol_g_s),
##                       cumC = sum(flux_co2_umol_gC_s),
##                       maxC = max(flux_co2_umol_gC_s),
##                       mean = mean(flux_co2_umol_g_s),
##                       sd = sd(flux_co2_umol_g_s),
##                       se = sd/sqrt(n()),
##                       n = n()) %>% 
##      left_join(core_key, by = "Core")-> cum_flux
##    
##  cum_flux %>% 
##      group_by(soil_type,moisture_lvl,trt) %>% 
##      dplyr::summarize(cum = mean(cum),
##                       max = mean(max),
##                       cumC = mean(cumC),
##                       maxC = mean(maxC))->mean
##  
##  cum_flux %>% 
##    group_by(soil_type,perc_sat,trt) %>% 
##    dplyr::summarize(cum = mean(cum),
##                     max = mean(max),
##                     cumC = mean(cumC),
##                     maxC = mean(maxC))->mean_percsat
##  ghg_fluxes %>% 
##    left_join(valve_key, by = "Core") %>% 
##    mutate(Sand = if_else(grepl("sand", Core_assignment), "Soil_sand", "Soil"),
##           Status = case_when(grepl("_D$", Core_assignment) ~ "Dry",
##                              grepl("_W$", Core_assignment) ~ "Wet",
##                              grepl("_fm$", Core_assignment) ~ "FM")) ->
##    gf  
##    
  # preliminary plots
  
##  p_cum = ggplot(cum_flux, aes(x = moisture_lvl, y = cum*1000, color = trt))+
##      geom_point(position = position_dodge(width = 0.5))+
##      geom_smooth(data = mean, aes(x = as.numeric(moisture_lvl), y = cum*1000))+
##      geom_vline(xintercept = 6.5)+
##      ylab("cum flux_co2_nmol_g_s")+
##      facet_grid(soil_type~.)+
##      ggtitle("cumulative CO2 flux")
##    
##    p_max = ggplot(cum_flux, aes(x = moisture_lvl, y = max*1000, color = trt))+
##      geom_point(position = position_dodge(width = 0.5))+
##      geom_smooth(data = mean, aes(x = as.numeric(moisture_lvl), y = max*1000))+
##      geom_vline(xintercept = 6.5)+
##      ylab("maximum flux_co2_nmol_g_s")+
##      facet_grid(soil_type~.)+
##      ggtitle("maximum CO2 flux")
##    
##    p_num = ggplot(cum_flux, aes(x = Core, y = n))+
##      geom_point()+
##      ggtitle("no. of readings")
##    
##    p_cores = ggplot(gf, aes(DATETIME, flux_co2_umol_g_s*1000, color = Sand)) + 
##      geom_point() + geom_line() +
##      ylab("flux_co2_nmol_g_s")+
##      facet_wrap(~Core, scale = "free_x")+
##      geom_hline(yintercept = 0)+
##      theme(legend.position="none")
##    
##    p_trt = ggplot(gf, aes(DATETIME, flux_co2_umol_g_s*1000, color = Core_assignment)) + 
##      geom_point() + geom_line() +
##      ylab("flux_co2_nmol_g_s")+
##      facet_wrap(~Core_assignment, scale = "free_x")+
##      geom_hline(yintercept = 0)+
##      theme(legend.position="none")
##    
##    
##    p_cumC = ggplot(cum_flux, aes(x = moisture_lvl, y = cumC*1000, color = trt))+
##      geom_point(position = position_dodge(width = 0.5))+
##      geom_smooth(data = mean, aes(x = as.numeric(moisture_lvl), y = cumC*1000))+
##      geom_vline(xintercept = 6.5)+
##      ylab("cum flux_co2_nmol_gC_s")+
##      facet_grid(soil_type~.)+
##      ggtitle("cumulative CO2 flux per g C")
##    
##    p_maxC = ggplot(cum_flux, aes(x = moisture_lvl, y = maxC*1000, color = trt))+
##      geom_point(position = position_dodge(width = 0.5))+
##      geom_smooth(data = mean, aes(x = as.numeric(moisture_lvl), y = maxC*1000))+
##      geom_vline(xintercept = 6.5)+
##      ylab("maximum flux_co2_nmol_gC_s")+
##      facet_grid(soil_type~.)+
##      ggtitle("maximum CO2 flux - C")
##    
##    p_cumC_percsat = ggplot(cum_flux, aes(x = perc_sat, y = cumC*1000, color = trt))+
##      geom_point(position = position_dodge(width = 0.5))+
##      geom_smooth(data = mean_percsat, aes(x = as.numeric(perc_sat), y = cumC*1000))+
##     # geom_vline(xintercept = 6.5)+
##      ylab("cum flux_co2_nmol_gC_s")+
##      facet_grid(soil_type~.)+
##      scale_x_reverse(name = "percent saturation")+
##      ggtitle("cumulative CO2 flux per g C")
##    
##    p_maxC_percsat = ggplot(cum_flux, aes(x = perc_sat, y = maxC*1000, color = trt))+
##      geom_point(position = position_dodge(width = 0.5))+
##      geom_smooth(data = mean_percsat, aes(x = as.numeric(perc_sat), y = maxC*1000))+
##      # geom_vline(xintercept = 6.5)+
##      ylab("max flux_co2_nmol_gC_s")+
##      facet_grid(soil_type~.)+
##      scale_x_reverse(name = "percent saturation")+
##      ggtitle("max CO2 flux per g C")
##    
##    ggsave("outputs/fluxes_co2_cum.png", plot = p_cum, width = 8, height = 6)
##    ggsave("outputs/fluxes_co2_max.png", plot = p_max, width = 8, height = 6)
##    ggsave("outputs/fluxes_co2_count.png", plot = p_num, width = 8, height = 6)
##    ggsave("outputs/fluxes_co2_cores.png", plot = p_cores, width = 10, height = 10)
##    ggsave("outputs/fluxes_co2_trt.png", plot = p_trt, width = 15, height = 15)
##    ggsave("outputs/fluxes_co2_cumC.png", plot = p_cumC, width = 8, height = 6)
##    

  
  
