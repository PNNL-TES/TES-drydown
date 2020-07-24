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
source("3c-picarro_output.R")
#
## months -- CPCRW -- dec 2018 to dec 2019 ----
# DEC-2018
PICARROPATH = "data/picarro_data/2018/12"
make(cpcrw_plan)
gf_2018_12 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_2018_12.csv", row.names = FALSE)

# JAN-2019
PICARROPATH = "data/picarro_data/2019/01"
make(cpcrw_plan)
gf_01 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_01.csv", row.names = FALSE)

# FEB-2019
PICARROPATH = "data/picarro_data/2019/02"
make(cpcrw_plan)
gf_02 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_02.csv", row.names = FALSE)

# MAR-2019
PICARROPATH = "data/picarro_data/2019/03/"
make(cpcrw_plan)
gf_03 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_03.csv", row.names = FALSE)

# APR-2019
PICARROPATH = "data/picarro_data/2019/04"
make(cpcrw_plan)
gf_04 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_04.csv", row.names = FALSE)

# MAY-2019
PICARROPATH = "data/picarro_data/2019/05"
make(cpcrw_plan)
gf_05 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_05.csv", row.names = FALSE)

# JUN-2019
PICARROPATH = "data/picarro_data/2019/06"
make(cpcrw_plan)
gf_06 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_06.csv", row.names = FALSE)

# JUL-2019
PICARROPATH = "data/picarro_data/2019/07"
make(cpcrw_plan)
gf_07 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_07.csv", row.names = FALSE)

# AUG-2019
PICARROPATH = "data/picarro_data/2019/08"
make(cpcrw_plan)
gf_08 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_08.csv", row.names = FALSE)

# SEP-2019
PICARROPATH = "data/picarro_data/2019/09"
make(cpcrw_plan)
gf_09 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_09.csv", row.names = FALSE)

# OCT-2019
PICARROPATH = "data/picarro_data/2019/10"
make(cpcrw_plan)
gf_10 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_10.csv", row.names = FALSE)

# NOV-2019
PICARROPATH = "data/picarro_data/2019/11"
make(cpcrw_plan)
gf_11 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_11.csv", row.names = FALSE)

# DEC-2019
PICARROPATH = "data/picarro_data/2019/12"
make(cpcrw_plan)
gf_12 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/cpcrw_gf/gf_12.csv", row.names = FALSE)


#
## months -- SR -- dec 2018 to dec 2019 ----
# JUL-2019
PICARROPATH = "data/picarro_data/2019/07"
make(sr_plan)
gf_07 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/sr_gf/sr_gf_07.csv", row.names = FALSE)

# AUG-2019
PICARROPATH = "data/picarro_data/2019/08"
make(sr_plan)
gf_08 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/sr_gf/sr_gf_08.csv", row.names = FALSE)

# SEP-2019
PICARROPATH = "data/picarro_data/2019/09"
make(sr_plan)
gf_09 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/sr_gf/sr_gf_09.csv", row.names = FALSE)

# OCT-2019
PICARROPATH = "data/picarro_data/2019/10"
make(sr_plan)
gf_10 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/sr_gf/sr_gf_10.csv", row.names = FALSE)

# NOV-2019
PICARROPATH = "data/picarro_data/2019/11"
make(sr_plan)
gf_11 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/sr_gf/sr_gf_11.csv", row.names = FALSE)

# DEC-2019
PICARROPATH = "data/picarro_data/2019/12"
make(sr_plan)
gf_12 = readd(gf_output) %>% write.csv("data/processed/picarro/monthly/sr_gf/sr_gf_12.csv", row.names = FALSE)




#
## combine all ----
picarro_processed_combined_cpcrw = 
  sapply(list.files(path = "data/processed/picarro/monthly/cpcrw_gf/",pattern = "*.csv",full.names = TRUE),
         read.csv, simplify = FALSE) %>% bind_rows()  

crunch::write.csv.gz(picarro_processed_combined_cpcrw, "data/processed/picarro_processed_cpcrw.csv.gz", row.names = F)                     


picarro_processed_combined_sr = 
  sapply(list.files(path = "data/processed/picarro/monthly/sr_gf/",pattern = "*.csv",full.names = TRUE),
         read.csv, simplify = FALSE) %>% bind_rows()  

crunch::write.csv.gz(picarro_processed_combined_sr, "data/processed/picarro_processed_sr.csv.gz", row.names = F)                     
