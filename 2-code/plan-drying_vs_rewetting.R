


# 0. load packages --------------------------------------------------------
library(drake)
library(tidyverse)
library(PNWColors)
library(soilpalettes)

# 1. SET input file paths -------------------------------
COREKEY = "data/corekey_90d.csv"
REPORT1 = "data/fticr/TES_drought_soil_Report1_2020-11-05.csv"
REPORT2 = "data/fticr/TES_drought_soil_Report2_timezero_2021-01-20.csv"
DOCKEY = "data/doc_analysis_key_90d_fad.csv"

## SET the treatment variables
TREATMENTS = quos(depth, Site, saturation, drying)

# 2. source the functions --------------------------------------------------------
source("code/fticrrr/a-functions_processing.R")
source("code/fticrrr/c-functions_graphs.R")
source("code/fticrrr/d-functions_statistics.R")

source("code/nmrrr/0-nmr_setup.R")
source("code/nmrrr/nmrrr_functions.R")

source("code/0-drydown_functions.R")
source("code/5-tctn_processing.R")
source("code/6-weoc.R")
source("code/7-microbiome.R")


# set color palettes ------------------------------------------------------

pal_saturation = rev(PNWColors::pnw_palette("Sunset2", 3))
theme_set(theme_kp())

# 3. load drake plans -----------------------------------------------------

## plan -- Drying vs. wetting ----


plan_drying_vs_wetting = drake_plan(
  
  # PART I: AIR-DRY ONLY ---------------------------------------------------
  corekey = read.csv(file_in(COREKEY)),
  dockey = read.csv(file_in(DOCKEY)) %>% 
    filter(!drying %in% "FAD") %>% 
    recode_saturation(),
  
  
  #
  # FTICR ----
  # a. PROCESSING
  report1 = read.csv(file_in(REPORT1)),
  report2 = read.csv(file_in(REPORT2)),
  
  
  datareport = combine_fticr_reports(report1, report2),
  fticr_meta = make_fticr_meta(datareport)$meta2,
  fticr_data_longform = make_fticr_data(datareport, dockey, 
                                        depth, Site, saturation)$data_long_key_repfiltered %>% 
    filter(!is.na(CoreID)),
  fticr_data_trt = make_fticr_data(datareport, dockey, 
                                   depth, Site, saturation)$data_long_trt %>% filter(!is.na(Site)),
  
  # b. RELATIVE ABUNDANCE
  fticr_relabund_cores = fticr_data_longform %>% 
    compute_relabund_cores(fticr_meta, TREATMENTS) %>% refactor_saturation_levels(.),
  
  gg_relabund_bar = fticr_relabund_cores %>% plot_relabund_drying_vs_dw(TREATMENTS),
  
  ## create relabund table
  
  # c. VAN KREVELEN PLOTS
  gg_vankrevelen_domains = plot_vankrevelen_domains(fticr_meta),
  gg_vankrevelens = plot_vk_drying_vs_dw(fticr_data_trt, fticr_meta),
  
  
  # d. STATISTICS
  ## PERMANOVA
  permanova_fticr = compute_permanova(fticr_relabund_cores),
  
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
  gg_nmr_spectra_clean = plot_nmr_spectra_clean(nmr_spectra_processed),
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
  stats_weoc = weoc_stats(weoc_processed),
  
  # Microbiome --------------------------------------------------------------
  # relative abundance
  phyla_dat = read.table("data/microbiome/phyla_relative_abundance.txt", sep="\t", header=TRUE, na = "") %>%
    recode_saturation() %>% 
    filter((length == "90d" & drying == "CW" )| length == "timezero"),
  phyla_relabund_by_trt = compute_relabund_phylum_by_trt(phyla_dat)$relabund_phyla_treatment,
  phyla_long_clean = compute_relabund_phylum_by_trt(phyla_dat)$phyla_long_clean,
  
  gg_barplot_phyla = plot_barplot_phylum(phyla_relabund_by_trt),
  
  # PERMANOVA
  phyla_permanova = compute_permanova_phyla(phyla_long_clean), 
  
  # PCA
  gg_pca_phyla = compute_pca_drying_vs_rewet(phyla_long_clean)$gg_pca_dry_wet,
  
  
  #
  # REPORT ----
  outputreport = rmarkdown::render(
    knitr_in("markdown/report-drying_vs_wetting.Rmd"),
    output_format = rmarkdown::github_document()),
  
  #
  #
  ## CW - vs - FAD -----
  
  fad_dockey = read.csv(file_in(DOCKEY)) %>% filter(!length %in% "timezero") %>% 
    recode_saturation(),
  
  # FTICR
  fad_fticr_data_longform = make_fticr_data(datareport, fad_dockey, depth, Site, drying, saturation)$data_long_key_repfiltered %>% 
    filter(!is.na(CoreID)),
  fad_fticr_data_trt = make_fticr_data(datareport, fad_dockey, depth, Site, drying, saturation)$data_long_trt %>% filter(!is.na(Site)),
  
  ## RELATIVE ABUNDANCE
  fad_fticr_relabund_cores = fad_fticr_data_longform %>% compute_relabund_cores(fticr_meta, TREATMENTS) %>% refactor_saturation_levels(.),
  fad_gg_relabund_bar = fad_fticr_relabund_cores %>% plot_relabund_cw_vs_fad(TREATMENTS),
  
  ## Van Krevelen
  fad_gg_vankrevelens = plot_vk_cw_vs_fad(fad_fticr_data_trt, fticr_meta),
  
  ## Stats
  fad_permanova_fticr = compute_permanova(fad_fticr_relabund_cores),
  fad_gg_pca_fticr = compute_fticr_pca_cw_vs_fad(fad_fticr_relabund_cores), 
  
  # NMR
  fad_dockey_nmr = fad_dockey %>% filter(depth == "0-5cm"),
  fad_nmr_spectra_processed = import_nmr_spectra_data(SPECTRA_FILES, fad_dockey_nmr), 
  fad_gg_nmr_spectra = fad_plot_nmr_spectra(fad_nmr_spectra_processed),
  fad_gg_nmr_spectra_clean = fad_plot_nmr_spectra_clean(fad_nmr_spectra_processed),
  fad_nmr_peaks_processed = import_nmr_peaks(PEAKS_FILES),
  fad_nmr_relabund_cores = compute_nmr_relabund(fad_nmr_peaks_processed, bins2, fad_dockey_nmr)$rel_abund_cores %>% filter(!is.na(coreID)),
  fad_nmr_relabund_wide = compute_nmr_relabund(fad_nmr_peaks_processed, bins2, fad_dockey_nmr)$rel_abund_wide %>% filter(!is.na(coreID)),
  fad_gg_nmr_relabund_barplot = plot_relabund_bargraphs_cw_vs_fad(fad_nmr_relabund_cores),
  fad_gg_pca_nmr = compute_nmr_pca_cw_fad(fad_nmr_relabund_wide),
  fad_nmr_permanova = compute_nmr_permanova_cw_fad(fad_nmr_relabund_wide),
  
  # WEOC
  fad_weoc_processed = process_weoc_data(fad_dockey),
  fad_gg_weoc = plot_weoc(fad_weoc_processed),
  fad_stats_weoc = weoc_stats(fad_weoc_processed),
  
  # Microbiome
  ## relative abundance
  fad_phyla_dat = read.table("data/microbiome/phyla_relative_abundance.txt", sep="\t", header=TRUE, na = "") %>%
    recode_saturation() %>% filter((length == "90d" & !length %in% "timezero")),
  fad_phyla_relabund_by_trt = compute_relabund_phylum_by_trt(fad_phyla_dat)$relabund_phyla_treatment,
  fad_phyla_long_clean = compute_relabund_phylum_by_trt(fad_phyla_dat)$phyla_long_clean,
  
  fad_gg_barplot_phyla = fad_plot_barplot_phylum(fad_phyla_relabund_by_trt),
  fad_phyla_permanova = fad_compute_permanova_phyla(fad_phyla_long_clean), 
  fad_gg_pca_phyla = compute_pca_cw_vs_fad(fad_phyla_long_clean)$gg_pca_dry_wet
  
  
  #
  
)





#
# 4. make plans -------------------------------------------------------------------------
make(plan_drying_vs_wetting, lock_cache = F)
