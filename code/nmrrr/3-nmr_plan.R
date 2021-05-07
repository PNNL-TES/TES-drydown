
source("code/0-drydown_functions.R")
source("code/nmrrr/0-nmr_setup.R")
source("code/nmrrr/nmrrr_functions.R")

nmrrr_plan = drake_plan(
  core_key = read.csv(COREKEY),
  doc_key = read.csv(DOCKEY, na.strings = ""),
  
  nmr_spectra_processed = import_nmr_spectra_data(SPECTRA_FILES, doc_key), 
  gg_spectra = plot_nmr_spectra(nmr_spectra_processed),
  nmr_peaks_processed = import_nmr_peaks(PEAKS_FILES),
  rel_abund_cores = compute_nmr_relabund(nmr_peaks_processed, bins2, doc_key)$rel_abund_cores,
  rel_abund_wide = compute_nmr_relabund(nmr_peaks_processed, bins2, doc_key)$rel_abund_wide,
  gg_relabund_barplot = plot_relabund_bargraphs(rel_abund_cores),
  gg_pca = compute_fticr_pca(rel_abund_wide),
  nmr_permanova = compute_nmr_permanova(rel_abund_wide),
  
  # REPORT
  outputreport = rmarkdown::render(
    knitr_in("markdown/report_nmr.Rmd"),
    output_format = rmarkdown::github_document())
)

make(nmrrr_plan, lock_cache = FALSE)


#####



# CLEANING

# remove water and DMSO regions
#  filter(!(ppm>DMSO_start&ppm<WATER_stop)) %>%  
#  filter(!(ppm>DMSO_start&ppm<DMSO_stop))

#

# PART III. PLOT THE SPECTRA ----
## ## using gg_nmr1
## gg_nmr1+
##   geom_path(data = spectra2, aes(x = ppm, y = intensity, color = source))+
##   ylim(0,3)
## ggsave("images/spectra_1.png", width = 10, height = 4)

## using gg_nmr2
gg_nmr2+
  geom_path(data = spectra2, aes(x = ppm, y = intensity, color = rep))+
  ylim(0,100)+
  facet_grid(length+saturation + depth  ~ Site + location + drying)+
  theme(legend.position = "none")+
  
  NULL

#ggsave("images/spectra_2.png", width = 10, height = 4)
