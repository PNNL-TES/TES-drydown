
source("0-drydown_functions.R")

picarro_c = read.csv("data/processed/picarro_processed.csv.gz")                     
valve_c = read.csv("data/cpcrw_valve_map2.csv")


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
  