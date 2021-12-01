


# 0. load packages --------------------------------------------------------
library(drake)
library(tidyverse)
library(PNWColors)
library(soilpalettes)

# 1. SET input file paths -------------------------------
COREKEY = "data/processed/corekey.csv"
REPORT1 = "data/fticr/TES_drought_soil_Report1_2020-11-05.csv"
REPORT2 = "data/fticr/TES_drought_soil_Report2_timezero_2021-01-20.csv"
DOCKEY = "data/doc_analysis_key.csv"

## SET the treatment variables
TREATMENTS = quos(depth, Site, saturation)

# 2. source the functions --------------------------------------------------------
source("code/fticrrr/a-functions_processing.R")
source("code/fticrrr/b-functions_relabund.R")
source("code/fticrrr/c-functions_vankrevelen.R")
source("code/fticrrr/d-functions_statistics.R")

source("code/nmrrr/0-nmr_setup.R")
source("code/nmrrr/nmrrr_functions.R")

# 3. load drake plans -----------------------------------------------------
plan_drying_vs_wetting = drake_plan(
  
 # FTICR ----
  # a. PROCESSING
  report1 = read.csv(file_in(REPORT1)),
  report2 = read.csv(file_in(REPORT2)),
  
  corekey = read.csv(file_in(COREKEY)),
  dockey = read.csv(file_in(DOCKEY)) %>% 
    filter((length == "90d" & drying == "CW" )| length == "timezero"),
  
  datareport = combine_fticr_reports(report1, report2),
  fticr_meta = make_fticr_meta(datareport)$meta2,
  fticr_data_longform = make_fticr_data(datareport, dockey, 
                                        depth, Site, saturation)$data_long_key_repfiltered,
  fticr_data_trt = make_fticr_data(datareport, dockey, 
                                   depth, Site, saturation)$data_long_trt,
  
  # b. RELATIVE ABUNDANCE
  relabund_cores = fticr_data_longform %>% 
    compute_relabund_cores(fticr_meta, 
                           depth, Site, saturation),
  
  gg_relabund_bar = relabund_cores %>% plot_relabund_drying_vs_dw(TREATMENTS),
  
  ## create relabund table
  
  # c. VAN KREVELEN PLOTS
  gg_vankrevelen_domains = plot_vankrevelen_domains(fticr_meta),
  gg_vankrevelens = plot_vk_drying_vs_dw(fticr_data_trt, fticr_meta),


  # d. STATISTICS
  ## PERMANOVA

  ## PCA
  gg_pca = compute_fticr_pca_drying_vs_dw(relabund_cores), 


 
 
 
 #
 # REPORT ----
   outputreport = rmarkdown::render(
     knitr_in("markdown/report-drying_vs_wetting.Rmd"),
     output_format = rmarkdown::github_document())
)


# 4. make plans -------------------------------------------------------------------------
make(plan_drying_vs_wetting, lock_cache = F)

