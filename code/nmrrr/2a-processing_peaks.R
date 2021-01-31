source("0-nmr_setup.R")



# PART I. SET SOLVENT BINS ----
WATER_start = 3
WATER_stop = 4

DMSO_start = 2.25
DMSO_stop = 2.75

#
# PART II. IMPORT NMR PEAKS FILES ----

# import all .csv files in the target folder 
# since MestreNova splits the table into multiple columns, we do this 2 times and then combine
# fml

## 1. import and process NMR peak data ----
filePaths <- list.files(path = PEAKS_FILES,pattern = "*.csv", full.names = TRUE)

# rbind.fill binds all rows and fills in missing columns
spectra_temp1 <- do.call(rbind.fill, lapply(filePaths, function(path) {
  # the files are tab-delimited, so read.csv will not work. import using read.table
  # there is no header. so create new column names
  # then add a new column `source` to denote the file name
  df <- fread(path, header=TRUE)
  df[["source"]] <- rep(path, nrow(df))
  df}))


# this file has over 100 columns, because the peaks are split
# collapse the columns by first selecting the different column types, and then melting

spectra_Area = 
  spectra_temp1 %>% 
  dplyr::select(starts_with("Area")) %>% 
  tidyr::gather() %>% 
  dplyr::select(value) %>% 
  dplyr::rename(Area=value)

spectra_ppm = 
  spectra_temp1 %>% 
  dplyr::select(starts_with("ppm")) %>% 
  tidyr::gather() %>% 
  dplyr::select(value) %>% 
  dplyr::rename(ppm=value)

spectra_Intensity = 
  spectra_temp1 %>% 
  dplyr::select(starts_with("Intensity")) %>% 
  tidyr::gather() %>% 
  dplyr::select(value) %>% 
  dplyr::rename(Intensity=value)

spectra_Width = 
  spectra_temp1 %>% 
  dplyr::select(starts_with("Width")) %>% 
  tidyr::gather() %>% 
  dplyr::select(value) %>% 
  dplyr::rename(Width=value)

spectra_Source = 
  spectra_temp1 %>% 
  dplyr::select(starts_with("Source")) %>% 
  tidyr::gather() %>% 
  dplyr::select(value) %>% 
  dplyr::rename(Source=value)

spectra_Flags = 
  spectra_temp1 %>% 
  dplyr::select(starts_with("Flags")) %>% 
  tidyr::gather() %>% 
  dplyr::select(value) %>% 
  dplyr::rename(Flags=value)


merged = 
  cbind(spectra_Source, spectra_ppm, spectra_Intensity, spectra_Width,spectra_Area, spectra_Flags)

# now, clean up
peaks = 
  merged %>% 
  # keep only 0-10 ppm
  filter(ppm>=0&ppm<=10) %>% 
  # remove solvent regions
  filter(!(ppm>DMSO_start & ppm<DMSO_stop)) %>% 
  filter(!is.na(ppm)) %>% 
  # remove peaks with 0 intensity, and peaks flagged as weak 
  filter(Intensity > 0) %>% 
  filter(!Flags=="Weak") %>% 
  # the source column has the entire path, including directories
  # delete the unnecessary strings
  dplyr::mutate(Source = str_replace_all(Source,"data/peaks//",""),
                Source = str_replace_all(Source,".csv","")) %>% 
  dplyr::rename(Core = Source)

#

## OUTPUT ----
write_csv(peaks, PROCESSED_PEAKS)


