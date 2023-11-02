# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("tibble"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)


# Run the R scripts in the R/ folder with your custom functions:
source("code/0-packages.R")
source("code/1-functions_processing.R")
source("code/1b-fticrrr_processing.R")


# Replace the target list below with your own:
list(
  tar_target(sample_key_data, "data/sample_key.csv", format = "file"),
  tar_target(sample_key, read.csv(sample_key_data, na = "")),
  tar_target(doc_key_data, "data/doc_analysis_key.csv", format = "file"),
  tar_target(doc_key, read.csv(doc_key_data, na = "")),
  tar_target(subsampling_data, "data/subsampling.csv", format = "file"),
  tar_target(subsampling, read.csv(subsampling_data, na = "")),
  tar_target(dry_weights, compute_dry_weights(subsampling)),
  
  # weoc
  tar_target(weoc_data, import_weoc_data(FILEPATH = "data/npoc")),
  tar_target(weoc_processed, process_weoc(weoc_data, doc_key, dry_weights)),
  
  # fticr
  tar_target(fticr_report, import_fticr(FILEPATH = "data/fticr")),
  tar_target(fticr_meta, process_fticr(fticr_report, doc_key, sample_key)$fticr_meta),
  tar_target(fticr_long, process_fticr(fticr_report, doc_key, sample_key)$data_long),
  tar_target(fticr_trt, process_fticr(fticr_report, doc_key, sample_key)$data_long_trt),
  tar_target(fticr_relabund, fticr_compute_relabund_cores(fticr_long, fticr_meta, 
                                                          TREATMENTS = quos(site, depth, length, saturation, drying))),
  
  
  
  # export
  tar_target(export, {
    write.csv(fticr_meta, "data/processed/fticr_meta.csv", row.names = FALSE)
    crunch::write.csv.gz(fticr_long, "data/processed/fticr_long_all_samples.csv.gz", row.names = FALSE)
    crunch::write.csv.gz(fticr_trt, "data/processed/fticr_long_treatments.csv.gz", row.names = FALSE)
    
  }, format = "file")
)
