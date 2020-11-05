## TES DRYDOWN
## script name: 3d-picarro_output_split.R
## Kaizad F. Patel
## 2020-05-04 (Cinco de Cuatro)

## use this to control the 3c script
## we have too many data points, and the computer cannot handle it.
## so we use this script to run each month at a time
## and then combine all using rbind
## JFC.

## clean and restart session after each round.


library(drake)
source("code/3c2-picarro_output_ppm.R")
#
# FLUXES ------------------------------------------------------------------

#
## months -- CPCRW -- dec 2018 to dec 2019 ----
# DEC-2018
PICARROPATH = "data/picarro_data/2018/12"
make(cpcrw_plan)
gf_2018_12 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_2018_12.csv", row.names = FALSE)

# JAN-2019
PICARROPATH = "data/picarro_data/2019/01"
make(cpcrw_plan)
gf_01 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_01.csv", row.names = FALSE)

# FEB-2019
PICARROPATH = "data/picarro_data/2019/02"
make(cpcrw_plan)
gf_02 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_02.csv", row.names = FALSE)

# MAR-2019
PICARROPATH = "data/picarro_data/2019/03/"
make(cpcrw_plan)
gf_03 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_03.csv", row.names = FALSE)

# APR-2019
PICARROPATH = "data/picarro_data/2019/04"
make(cpcrw_plan)
gf_04 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_04.csv", row.names = FALSE)

# MAY-2019
PICARROPATH = "data/picarro_data/2019/05"
make(cpcrw_plan)
gf_05 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_05.csv", row.names = FALSE)

# JUN-2019
PICARROPATH = "data/picarro_data/2019/06"
make(cpcrw_plan)
gf_06 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_06.csv", row.names = FALSE)

# JUL-2019
PICARROPATH = "data/picarro_data/2019/07"
make(cpcrw_plan)
gf_07 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_07.csv", row.names = FALSE)

# AUG-2019
PICARROPATH = "data/picarro_data/2019/08"
make(cpcrw_plan)
gf_08 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_08.csv", row.names = FALSE)

# SEP-2019
PICARROPATH = "data/picarro_data/2019/09"
make(cpcrw_plan)
gf_09 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_09.csv", row.names = FALSE)

# OCT-2019
PICARROPATH = "data/picarro_data/2019/10"
make(cpcrw_plan)
gf_10 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_10.csv", row.names = FALSE)

# NOV-2019
PICARROPATH = "data/picarro_data/2019/11"
make(cpcrw_plan)
gf_11 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_11.csv", row.names = FALSE)

# DEC-2019
PICARROPATH = "data/picarro_data/2019/12"
make(cpcrw_plan)
gf_12 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/cpcrw_gf/gf_12.csv", row.names = FALSE)


#
## months -- SR -- dec 2018 to dec 2019 ----
# JUL-2019
PICARROPATH = "data/picarro_data/2019/07"
make(sr_plan)
gf_07 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/sr_gf/sr_gf_07.csv", row.names = FALSE)

# AUG-2019
PICARROPATH = "data/picarro_data/2019/08"
make(sr_plan)
gf_08 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/sr_gf/sr_gf_08.csv", row.names = FALSE)

# SEP-2019
PICARROPATH = "data/picarro_data/2019/09"
make(sr_plan)
gf_09 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/sr_gf/sr_gf_09.csv", row.names = FALSE)

# OCT-2019
PICARROPATH = "data/picarro_data/2019/10"
make(sr_plan)
gf_10 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/sr_gf/sr_gf_10.csv", row.names = FALSE)

# NOV-2019
PICARROPATH = "data/picarro_data/2019/11"
make(sr_plan)
gf_11 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/sr_gf/sr_gf_11.csv", row.names = FALSE)

# DEC-2019
PICARROPATH = "data/picarro_data/2019/12"
make(sr_plan)
gf_12 = readd(gf_output) %>% write.csv("data/processed/respiration/monthly/sr_gf/sr_gf_12.csv", row.names = FALSE)




#
## combine all ----
picarro_processed_combined_cpcrw = 
  sapply(list.files(path = "data/processed/respiration/monthly/cpcrw_gf/",pattern = "*.csv",full.names = TRUE),
         read.csv, simplify = FALSE) %>% bind_rows()  

crunch::write.csv.gz(picarro_processed_combined_cpcrw, "data/processed/picarro_processed_cpcrw.csv.gz", row.names = F)                     


picarro_processed_combined_sr = 
  sapply(list.files(path = "data/processed/respiration/monthly/sr_gf/",pattern = "*.csv",full.names = TRUE),
         read.csv, simplify = FALSE) %>% bind_rows()  

crunch::write.csv.gz(picarro_processed_combined_sr, "data/processed/picarro_processed_sr.csv.gz", row.names = F)                     




###############################
###############################
###############################
# CONCENTRATIONS -- PPM ---------------------------------------------------
source("code/3c2-picarro_output_ppm.R")
#
## months -- CPCRW -- dec 2018 to dec 2019 ----
# DEC-2018
PICARROPATH = "data/picarro_data/2018/12"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_2018_12 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_2018_12.csv", row.names = FALSE)

# JAN-2019
PICARROPATH = "data/picarro_data/2019/01"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_01 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_01.csv", row.names = FALSE)

# FEB-2019
PICARROPATH = "data/picarro_data/2019/02"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_02 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_02.csv", row.names = FALSE)

# MAR-2019
PICARROPATH = "data/picarro_data/2019/03/"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_03 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_03.csv", row.names = FALSE)

# APR-2019
PICARROPATH = "data/picarro_data/2019/04"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_04 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_04.csv", row.names = FALSE)

# MAY-2019
PICARROPATH = "data/picarro_data/2019/05"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_05 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_05.csv", row.names = FALSE)

# JUN-2019
PICARROPATH = "data/picarro_data/2019/06"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_06 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_06.csv", row.names = FALSE)

# JUL-2019
PICARROPATH = "data/picarro_data/2019/07"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_07 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_07.csv", row.names = FALSE)

# AUG-2019
PICARROPATH = "data/picarro_data/2019/08"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_08 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_08.csv", row.names = FALSE)

# SEP-2019
PICARROPATH = "data/picarro_data/2019/09"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_09 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_09.csv", row.names = FALSE)

## # OCT-2019
## PICARROPATH = "data/picarro_data/2019/10"
## make(cpcrw_plan_ppm, lock_cache = F)
## ppm_10 = readd(picarro_clean_matched) %>% write.csv("data/processed/respiration/monthly/monthly_ppm/ppm_cpcrw_10.csv", row.names = FALSE)

# NOV-2019
PICARROPATH = "data/picarro_data/2019/11"
make(cpcrw_plan_ppm, lock_cache = F)
ppm_11 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_11.csv", row.names = FALSE)

## # DEC-2019
## PICARROPATH = "data/picarro_data/2019/12"
## make(cpcrw_plan_ppm, lock_cache = F)
## ppm_12 = readd(picarro_clean_matched) %>% write.csv("data/processed/respiration/monthly/monthly_ppm/ppm_cpcrw_12.csv", row.names = FALSE)


#
## months -- SR -- dec 2018 to dec 2019 ----
# JUL-2019
PICARROPATH = "data/picarro_data/2019/07"
make(sr_plan_ppm, lock_cache = F)
ppm_07 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_sr/ppm_sr_07.csv", row.names = FALSE)

# AUG-2019
PICARROPATH = "data/picarro_data/2019/08"
make(sr_plan_ppm, lock_cache = F)
ppm_08 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_sr/ppm_sr_08.csv", row.names = FALSE)

# SEP-2019
PICARROPATH = "data/picarro_data/2019/09"
make(sr_plan_ppm, lock_cache = F)
ppm_09 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_sr/ppm_sr_09.csv", row.names = FALSE)

# OCT-2019
PICARROPATH = "data/picarro_data/2019/10"
make(sr_plan_ppm, lock_cache = F)
ppm_10 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_sr/ppm_sr_10.csv", row.names = FALSE)

# NOV-2019
PICARROPATH = "data/picarro_data/2019/11"
make(sr_plan_ppm, lock_cache = F)
ppm_11 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_sr/ppm_sr_11.csv", row.names = FALSE)

# DEC-2019
PICARROPATH = "data/picarro_data/2019/12"
make(sr_plan_ppm, lock_cache = F)
ppm_12 = readd(output) %>% write.csv("data/processed/respiration/monthly/monthly_ppm_sr/ppm_sr_12.csv", row.names = FALSE)




#
## combine all ----
picarro_processed_combined_sr = 
  sapply(list.files(path = "data/processed/respiration/monthly/monthly_ppm_sr",pattern = "*.csv",full.names = TRUE),
         read.csv, simplify = FALSE) %>% bind_rows()  

crunch::write.csv.gz(picarro_processed_combined_sr, "data/processed/respiration/picarro_processed_ppm_sr.csv.gz", row.names = F)                     


## CPCRW files cannot be combined as above because of f*****g issues with Core column format.
## So, load all files, make sure column formats are consistent, and then combine.

  ## picarro_processed_combined_cpcrw = 
  ##   sapply(list.files(path = "data/processed/respiration/monthly/monthly_ppm_cpcrw",pattern = "*.csv",full.names = TRUE),
  ##          read.csv, simplify = FALSE) %>% bind_rows()  
  ## 
  ## crunch::write.csv.gz(picarro_processed_combined_cpcrw, "data/processed/picarro_processed_cpcrw.csv.gz", row.names = F)                     

file01 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_01.csv")
file02 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_02.csv")
file03 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_03.csv")
file04 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_04.csv")
file05 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_05.csv")
file06 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_06.csv")
file07 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_07.csv")
file08 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_08.csv")
file09 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_09.csv") %>% mutate(Core = as.character(Core))
file11 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_11.csv")
file12_2018 = read.csv("data/processed/respiration/monthly/monthly_ppm_cpcrw/ppm_cpcrw_2018_12.csv")

picarro_ppm_combined_cpcrw = vctrs::vec_rbind(file01, file02, file03, file04, file05, file06, file07, file08, file09, file11, file12_2018)
crunch::write.csv.gz(picarro_ppm_combined_cpcrw, "data/processed/respiration/picarro_processed_ppm_cpcrw.csv.gz", row.names = F)                     
