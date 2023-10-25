
source("code/0-drydown_functions.R")

picarro_c = read.csv("data/processed/picarro_processed.csv.gz")                     
valve_c = read.csv("data/cpcrw_valve_map.csv")


valve = 
  valve_c %>% 
  filter(!Seq.Program == "mass_only") %>% 
  filter(!Seq.Program == "mass only") %>% 
  filter((Notes2=="")) %>% 
  dplyr::mutate(Start_datetime = ymd_hm(paste(Start_Date, Start_Time), tz = "America/Los_Angeles"),
                Stop_datetime = ymd_hm(paste(Stop_Date, Stop_Time), tz = "America/Los_Angeles"),
                coreIDs = paste0("C",Core)) %>% 
  dplyr::select(coreIDs, Start_datetime, Stop_datetime, Treatment)

# now add the treatment column to the picarro dataset

new =
  subset(merge(picarro_c, valve), DATETIME <= Stop_datetime & DATETIME <= Start_datetime & CoreID == CoreIDs)
  



# -------------------------------------------------------------------------
# -------------------------------------------------------------------------

picarro_c = read.csv("data/processed/picarro_processed.csv.gz")
picarro_c_90d = 
  picarro_c %>% 
  filter(length == "90 day")

sample_list_c_90d = 
  picarro_c_90d %>% 
  distinct(coreID)

valve_c = read.csv("data/cpcrw_valve_map.csv")


valve_c2 = 
  valve_c %>% 
  filter(!Seq.Program == "mass_only") %>% 
  filter(!Seq.Program == "mass only") %>% 
  filter((Notes2=="")) %>% 
  dplyr::mutate(Start_datetime = ymd_hm(paste(Start_Date, Start_Time), tz = "America/Los_Angeles"),
                Stop_datetime = ymd_hm(paste(Stop_Date, Stop_Time), tz = "America/Los_Angeles"),
                coreID = paste0("C",Core)) %>% 
  dplyr::select(coreID, Start_datetime, Stop_datetime, Treatment) %>% 
  right_join(sample_list_c_90d)

# now add the treatment column to the picarro dataset

new =
  subset(merge(picarro_c_90d, valve_c2), DATETIME <= Stop_datetime & DATETIME >= Start_datetime & coreID == coreID)


new2 = 
  new %>% 
  mutate(DATETIME = ymd_hms(DATETIME))
  
  
new %>% 
  ggplot(aes(x = Treatment, y = flux_co2_umol_g_s, color = coreID))+
  geom_jitter()+
  facet_grid(. ~drying)

new2 %>% 
  ggplot(aes(x = DATETIME, y = flux_co2_umol_g_s, color = Treatment))+
  geom_point()+ geom_line()+
  facet_wrap(~ drying + coreID, scales = "free_x")

# ----------

picarro_s = read.csv("data/processed/picarro_processed_sr.csv.gz")
picarro_s_90d = 
  picarro_s %>% 
  filter(length == "90 day") %>% 
  mutate(DATETIME = ymd_hms(DATETIME))

sample_list_s_90d = 
  picarro_s_90d %>% 
  distinct(coreID)

valve_s = read.csv("data/sr_valve_map.csv")


valve_s2 = 
  valve_s %>% 
  filter(!Seq.Program == "mass_only") %>% 
  filter(!Seq.Program == "mass only") %>% 
  filter((Notes2=="")) %>% 
  dplyr::mutate(Start_datetime = ymd_hm(paste(Start_Date, Start_Time), tz = "America/Los_Angeles"),
                Stop_datetime = ymd_hm(paste(Stop_Date, Stop_Time), tz = "America/Los_Angeles"),
                coreID = paste0("S",Core)) %>% 
  dplyr::select(coreID, Start_datetime, Stop_datetime, Treatment) %>% 
  right_join(sample_list_s_90d)

# now add the treatment column to the picarro dataset

new_s =
  subset(merge(picarro_s_90d, valve_s2), DATETIME <= Stop_datetime & DATETIME >= Start_datetime & coreID == coreID)


new_s2 = 
  new_s %>% 
  mutate(DATETIME = ymd_hms(DATETIME))


new_s2 %>% 
  ggplot(aes(x = Treatment, y = flux_co2_umol_g_s, color = coreID))+
  geom_jitter()+
  facet_grid(. ~drying)

new_s2 %>% 
  ggplot(aes(x = DATETIME, y = flux_co2_umol_g_s, color = Treatment))+
  geom_point()+ geom_line()+
  facet_wrap(~ drying + coreID)


# ------
cpcrw_90d_subset = 
  new2 %>% 
  dplyr::select(coreID, Site, drying, length, DATETIME, starts_with("flux"), Treatment, outlier) %>% 
  filter(!outlier) %>% 
  dplyr::select(-outlier)

sr_90d_subset = 
  new_s2 %>% 
  dplyr::select(coreID, Site, drying, length, DATETIME, starts_with("flux"), Treatment)

combined = 
  bind_rows(cpcrw_90d_subset, sr_90d_subset)

combined %>% crunch::write.csv.gz("data/processed/picarro_90DAY_fluxes.csv.gz", row.names = FALSE, na = "")


# ----

combined2 = 
  combined %>% 
  group_by(coreID) %>% 
  mutate(time_elapsed_days = as.numeric(difftime(DATETIME, min(DATETIME), units = "days")))


combined2 %>% 
  ggplot(aes(x = time_elapsed_days, y = flux_co2_umol_g_s*1000))+
  geom_point(aes(color = Treatment))+ geom_smooth()+
  facet_wrap(~Site + drying + coreID, scales = "free_x")
