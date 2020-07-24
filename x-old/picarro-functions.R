# Process Picarro data for the TES drydown lab experiment
# This script reads all available Picarro outputs in `data/picarro/`
# Ben Bond-Lamberty December 2018


# -----------------------------------------------------------------------------
# scan a directory and process all files in it, returning a single big tibble
read_picarro_dir <- function(input_path) {
  filelist <- list.files(path = input_path, 
                         pattern = "dat$|dat.gz$|dat.zip$", 
                         recursive = TRUE,
                         full.names = TRUE)
  filedata <- list()
  for(f in filelist) {
    cat("Reading", f, "\n")
    d <- try(read.table(f, header = TRUE, stringsAsFactors = FALSE), silent = TRUE)
    if(inherits(d, "try-error")) {
      warning("Couldn't read", f)
      next
    }
    tibble::as_tibble(d) %>%
      # select only the columns we need, and discard any fractional valve numbers
      select(DATE, TIME, ALARM_STATUS, MPVPosition, CH4_dry, CO2_dry, h2o_reported) %>%
      filter(MPVPosition == floor(MPVPosition)) ->
      filedata[[basename(f)]]
  }
  filedata %>%
    bind_rows(.id = "filename")
}
