## FTICR-MS DRAKE PLAN
## USE THIS SCRIPT/PLAN TO PROCESS, ANALYZE, AND GRAPH FTICR-MS DATA
## KAIZAD F. PATEL
## OCT-06-2020

##############################
##############################

## SOURCE THE FUNCTION FILES FIRST, AND THEN RUN THE DRAKE PLAN
## DON'T RUN THE PROCESSING PLAN MULTIPLE TIMES. ONCE IS ENOUGH.

##############################
##############################


# 0. load packages --------------------------------------------------------
library(drake)
library(tidyverse)

# 1. SET input file paths -------------------------------
COREKEY = "data/processed/corekey.csv"
REPORT1 = "data/fticr/TES_drought_soil_Report1_2020-11-05.csv"
REPORT2 = "data/fticr/TES_drought_soil_Report2_timezero_2021-01-20.csv"
DOCKEY = "data/doc_analysis_key.csv"

## SET the treatment variables
TREATMENTS = quos(depth, Site, length, drying, saturation)

# 2. source the functions --------------------------------------------------------
source("code/fticrrr/a-functions_processing.R")
source("code/fticrrr/b-functions_relabund.R")
source("code/fticrrr/c-functions_vankrevelen.R")
source("code/fticrrr/d-functions_statistics.R")

# 3. load drake plans -----------------------------------------------------
fticr_processing_plan = drake_plan(
  # a. PROCESSING ---- 
  report1 = read.csv(file_in(REPORT1)),
  report2 = read.csv(file_in(REPORT2)),
  
  corekey = read.csv(file_in(COREKEY)),
  dockey = read.csv(file_in(DOCKEY)),
  
  datareport = combine_fticr_reports(report1, report2),
  fticr_meta = make_fticr_meta(datareport)$meta2,
  fticr_data_longform = make_fticr_data(datareport, dockey, depth, Site, length, drying, saturation)$data_long_key_repfiltered,
  fticr_data_trt = make_fticr_data(datareport, dockey, depth, Site, length, drying, saturation)$data_long_trt,
  
  # b. RELATIVE ABUNDANCE ---- 
  relabund_cores = fticr_data_longform %>% 
    compute_relabund_cores(fticr_meta, depth, Site, length, drying, saturation),
  
  gg_relabund_bar = relabund_cores %>% plot_relabund(TREATMENTS),
  
  ## create relabund table
  
  # c. VAN KREVELEN PLOTS ---- 
  gg_vankrevelen_domains = plot_vankrevelen_domains(fticr_meta),
  gg_vankrevelens = plot_vankrevelens(fticr_data_trt, fticr_meta),
  gg_vk_newpeaks_saturation = plot_vk_saturation(fticr_data_trt, fticr_meta),
  gg_vk_newpeaks_drying = plot_vk_drying(fticr_data_trt, fticr_meta),
  gg_vk_timezero = plot_vk_timezero(fticr_data_trt, fticr_meta),
  
  # d. STATISTICS ---- 
  ## PERMANOVA
  fticr_permanova = compute_permanova(relabund_cores),
  fticr_permanova_tzero = compute_permanova_tzero(relabund_cores),
  
  ## PCA
  gg_pca = compute_fticr_pca(relabund_cores), 
  gg_pca_tzero = compute_fticr_pca_tzero(relabund_cores),
  
  # e. OUTPUT FILES ----
  #  fticr_meta %>% write.csv(),
  #  fticr_data_trt %>% write.csv(),
  #  fticr_data_longform %>% write.csv() 
  
  # REPORT
  outputreport = rmarkdown::render(
    knitr_in("markdown/report_fticr.Rmd"),
    output_format = rmarkdown::github_document())
)


# 4. make plans -------------------------------------------------------------------------
make(fticr_processing_plan, lock_cache = F)

