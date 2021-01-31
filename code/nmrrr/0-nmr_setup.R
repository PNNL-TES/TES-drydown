
# PART I. LOAD PACKAGES ----
library(readxl)
library(readr)
library(tidyverse)
library(data.table)
library(plyr)
library(tidyr)
library(dplyr)
library(ggplot2)


#

# PART II. SET FILE PATHS ----
SPECTRA_FILES = "data/nmr-data/nmr_spectra/"
PEAKS_FILES = "data/peaks/"
BINS = "data/0-NMR_BINS.csv"

COREKEY = "data/processed/corekey.csv"
DOCKEY = "data/doc_analysis_key.csv"

PROCESSED_PEAKS = "processed/peaks.csv"

RELABUND_CORES = "processed/relabund_cores.csv"
RELABUND_TRT = "processed/relabund_trt.csv"
RELABUND_SUMMARY = "processed/relabund_summary.csv"

#
# PART III. SETTING UP THE PARAMETERS ----
## 1. set up bins ----

## choose which set of BINS SET to use
cat("ACTION: choose correct value of BINSET
      a.> Clemente2012
      b.> Lynch2019
      c.> Mitchell2018
  type this into the code
  e.g.: BINSET = [quot]Clemente2012[quot]")

BINSET = "Clemente2012"

bins = read_csv(BINS)
bins2 = 
  bins %>% 
  # here we select only the BINSET we chose above
  dplyr::select(group,startstop,BINSET) %>% 
  na.omit %>% 
  spread(startstop,BINSET) %>% 
  arrange(start) %>% 
  dplyr::mutate(number = row_number())


#
## 2. bins for water and DMSO solvent ----
WATER_start = 3
WATER_stop = 4

DMSO_start = 2.25
DMSO_stop = 2.75

#
