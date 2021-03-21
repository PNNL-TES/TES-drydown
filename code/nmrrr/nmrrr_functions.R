library(tidyverse)


PEAKS_FILES = "data/nmr-data/nmr_peaks"


import_nmr_peaks = function(PEAKS_FILES){
  filePaths_peaks <- list.files(path = PEAKS_FILES,pattern = "*.csv", full.names = TRUE)
  peaks_rawdat <- do.call(bind_rows, lapply(filePaths_peaks, function(path) {
    # this function will import all the data files and combine for all samples
    # first, we run the function to clean a single file
    # the input data are spread across multiple columns, so use this function to align columns
    
    align_columns = function(path){
      # Step 1. import file. 
      # check.names=FALSE because columns have duplicate names, and we want to leave as is
      df <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
      
      # Step 2. confirm that the data are in 9-column groups
      noname_cols <- which(names(df) == "")
      if(!all(diff(noname_cols) == 9)) {
        stop("Formatting problem: data don't appear to be in 9-column groups")
      }
      names(df)[noname_cols] <- "Obs"  # give them a name

      # Step 3. Extract each group in turn and store temporarily in a list
      nmr_list <- lapply(noname_cols, function(x) df[x:(x + 8)])
      
      # Step 4. Finally, bind everything into a single data frame
      # This uses dplyr but we could also use base R: do.call("rbind", nmr_list)
      nmr_dat <- dplyr::bind_rows(nmr_list)
      
      # Step 5. Create a new column that includes source sample name
      nmr_dat[["source"]] <- rep(path, nrow(df))
      
      nmr_dat
      }
    
    # now create an object from the function
    align_columns(path)
    # this will be repeated for each file in the input folder
    
    }))
  
  # process the dataset
  peaks_rawdat %>% 
    mutate(DOC_ID = str_remove(source, paste0(PEAKS_FILES, "/")),
           DOC_ID = str_remove(DOC_ID, ".csv"),
           DOC_ID = paste0("DOC-", DOC_ID)) %>% 
    dplyr::select(-Obs, -source)
  }

x = import_nmr_peaks(PEAKS_FILES)
  
  
  
  
