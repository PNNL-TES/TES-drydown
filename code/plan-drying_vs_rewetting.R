


# 0. load packages --------------------------------------------------------
library(drake)
library(tidyverse)
library(PNWColors)
library(soilpalettes)

# 1. SET input file paths -------------------------------
COREKEY = "data/processed/corekey_v2.csv"
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

source("code/0-drydown_functions.R")
source("code/5-tctn_processing.R")
source("code/6-weoc.R")
source("code/7-microbiome.R")

library(tidyverse)

# 3. load drake plans -----------------------------------------------------
plan_drying_vs_wetting = drake_plan(
  
  corekey = read.csv(file_in(COREKEY)),
  dockey = read.csv(file_in(DOCKEY)) %>% 
    filter((length == "90d" & drying == "CW" )| length == "timezero"),
  
  
  #
  # FTICR ----
  # a. PROCESSING
  report1 = read.csv(file_in(REPORT1)),
  report2 = read.csv(file_in(REPORT2)),
  
  
  datareport = combine_fticr_reports(report1, report2),
  fticr_meta = make_fticr_meta(datareport)$meta2,
  fticr_data_longform = make_fticr_data(datareport, dockey, 
                                        depth, Site, saturation)$data_long_key_repfiltered,
  fticr_data_trt = make_fticr_data(datareport, dockey, 
                                   depth, Site, saturation)$data_long_trt,
  
  # b. RELATIVE ABUNDANCE
  fticr_relabund_cores = fticr_data_longform %>% 
    compute_relabund_cores(fticr_meta, 
                           depth, Site, saturation),
  
  gg_relabund_bar = fticr_relabund_cores %>% plot_relabund_drying_vs_dw(TREATMENTS),
  
  ## create relabund table
  
  # c. VAN KREVELEN PLOTS
  gg_vankrevelen_domains = plot_vankrevelen_domains(fticr_meta),
  gg_vankrevelens = plot_vk_drying_vs_dw(fticr_data_trt, fticr_meta),
  
  
  # d. STATISTICS
  ## PERMANOVA
  
  ## PCA
  gg_pca_fticr = compute_fticr_pca_drying_vs_dw(fticr_relabund_cores), 
  
  # e. NOSC
  # gg_nosc = make_nosc_figures(fticr_data_trt, fticr_meta),
  
  # e. OUTPUT FILES
  # fticr_meta %>% write.csv("data/processed/fticr/fticr_meta.csv", row.names = FALSE),
  # fticr_data_trt %>% write.csv("data/processed/fticr/fticr_data_by_treatment.csv", row.names = FALSE),
  # fticr_data_longform %>% write.csv() 
  
  #
  # NMR ----
  dockey_nmr = dockey %>% filter(depth == "0-5cm"),
  
  nmr_spectra_processed = import_nmr_spectra_data(SPECTRA_FILES, dockey_nmr), 
  gg_nmr_spectra = plot_nmr_spectra(nmr_spectra_processed),
  nmr_peaks_processed = import_nmr_peaks(PEAKS_FILES),
  nmr_relabund_cores = compute_nmr_relabund(nmr_peaks_processed, bins2, dockey_nmr)$rel_abund_cores %>% filter(!is.na(coreID)),
  nmr_relabund_wide = compute_nmr_relabund(nmr_peaks_processed, bins2, dockey_nmr)$rel_abund_wide %>% filter(!is.na(coreID)),
  gg_nmr_relabund_barplot = plot_relabund_bargraphs_drying_vs_dw(nmr_relabund_cores),
  gg_pca_nmr = compute_nmr_pca_drying_dw(nmr_relabund_wide),
  nmr_permanova = compute_nmr_permanova_drying_dw(nmr_relabund_wide),
  
  #
  
  # WEOC --------------------------------------------------------------------
  weoc_processed = process_weoc_data(dockey),
  gg_weoc = plot_weoc(weoc_processed),
  
  #
  # POM-nonPOM --------------------------------------------------------------
  pom_data_processed = process_pom_data(pom_data, pom_weights, corekey_full = corekey),
  gg_pom = make_pom_graphs(pom_data_processed),
  
  #
  # Microbiome --------------------------------------------------------------
  # relative abundance
  phyla_dat = read.table("data/microbiome/phyla_relative_abundance.txt", sep="\t", header=TRUE, na = "") %>% 
    filter((length == "90d" & drying == "CW" )| length == "timezero"),
  phyla_relabund_by_trt = compute_relabund_phylum_by_trt(phyla_dat)$relabund_phyla_treatment,
  phyla_long_clean = compute_relabund_phylum_by_trt(phyla_dat)$phyla_long_clean,
  
  gg_barplot_phyla = plot_barplot_phylum(phyla_relabund_by_trt),
  
  # PERMANOVA
  
  
  # PCA
  gg_pca_phyla = compute_pca_drying_vs_rewet(phyla_long_clean)$gg_pca_dry_wet,
  
  
  #
  # REPORT ----
  outputreport = rmarkdown::render(
    knitr_in("markdown/report-drying_vs_wetting.Rmd"),
    output_format = rmarkdown::github_document())
)


# 4. make plans -------------------------------------------------------------------------
make(plan_drying_vs_wetting, lock_cache = F)

