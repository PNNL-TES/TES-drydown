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

## months -- dec 2018 to dec 2019 ----
# DEC-2018
PICARROPATH = "data/picarro_data/2018/12"
make(plan)
cum_flux_2018_12 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_2018_12.csv", row.names = FALSE)
mean_flux_2018_12 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_2018_12.csv", row.names = FALSE)
gf_2018_12 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_2018_12.csv", row.names = FALSE)

# JAN-2019
PICARROPATH = "data/picarro_data/2019/01"
make(plan)
cum_flux_01 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_01.csv", row.names = FALSE)
mean_flux_01 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_01.csv", row.names = FALSE)
gf_01 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_01.csv", row.names = FALSE)

# FEB-2019
PICARROPATH = "data/picarro_data/2019/02"
make(plan)
cum_flux_02 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_02.csv", row.names = FALSE)
mean_flux_02 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_02.csv", row.names = FALSE)
gf_02 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_02.csv", row.names = FALSE)

# MAR-2019
PICARROPATH = "data/picarro_data/2019/03/"
make(plan)
cum_flux_03 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_03.csv", row.names = FALSE)
mean_flux_03 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_03.csv", row.names = FALSE)
gf_03 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_03.csv", row.names = FALSE)

# APR-2019
PICARROPATH = "data/picarro_data/2019/04"
make(plan)
cum_flux_04 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_04.csv", row.names = FALSE)
mean_flux_04 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_04.csv", row.names = FALSE)
gf_04 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_04.csv", row.names = FALSE)

# MAY-2019
PICARROPATH = "data/picarro_data/2019/05"
make(plan)
cum_flux_05 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_05.csv", row.names = FALSE)
mean_flux_05 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_05.csv", row.names = FALSE)
gf_05 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_05.csv", row.names = FALSE)

# JUN-2019
PICARROPATH = "data/picarro_data/2019/06"
make(plan)
cum_flux_06 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_06.csv", row.names = FALSE)
mean_flux_06 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_06.csv", row.names = FALSE)
gf_06 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_06.csv", row.names = FALSE)

# JUL-2019
PICARROPATH = "data/picarro_data/2019/07"
make(plan)
cum_flux_07 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_07.csv", row.names = FALSE)
mean_flux_07 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_07.csv", row.names = FALSE)
gf_07 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_07.csv", row.names = FALSE)

# AUG-2019
PICARROPATH = "data/picarro_data/2019/08"
make(plan)
cum_flux_08 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_08.csv", row.names = FALSE)
mean_flux_08 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_08.csv", row.names = FALSE)
gf_08 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_08.csv", row.names = FALSE)

# SEP-2019
PICARROPATH = "data/picarro_data/2019/09"
make(plan)
cum_flux_09 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_09.csv", row.names = FALSE)
mean_flux_09 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_09.csv", row.names = FALSE)
gf_09 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_09.csv", row.names = FALSE)

# OCT-2019
PICARROPATH = "data/picarro_data/2019/10"
make(plan)
cum_flux_10 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_10.csv", row.names = FALSE)
mean_flux_10 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_10.csv", row.names = FALSE)
gf_10 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_10.csv", row.names = FALSE)

# NOV-2019
PICARROPATH = "data/picarro_data/2019/11"
make(plan)
cum_flux_11 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_11.csv", row.names = FALSE)
mean_flux_11 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_11.csv", row.names = FALSE)
gf_11 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_11.csv", row.names = FALSE)

# DEC-2019
PICARROPATH = "data/picarro_data/2019/12"
make(plan)
cum_flux_12 = readd(cum_flux) %>% write.csv("data/processed/picarro/monthly/cum/cum_flux_12.csv", row.names = FALSE)
mean_flux_12 = readd(meanflux) %>% write.csv("data/processed/picarro/monthly/mean/mean_flux_12.csv", row.names = FALSE)
gf_12 = readd(gf) %>% write.csv("data/processed/picarro/monthly/gf/gf_12.csv", row.names = FALSE)


#
## combine all ----
picarro_processed_combined = 
  sapply(list.files(path = "data/processed/picarro/monthly/gf/",pattern = "*.csv",full.names = TRUE),
         read.csv, simplify = FALSE) %>% bind_rows()  

crunch::write.csv.gz(picarro_processed_combined, "data/processed/picarro_processed.csv.gz", row.names = F)                     
