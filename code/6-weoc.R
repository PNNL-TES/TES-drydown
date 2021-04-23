
source("code/0-drydown_functions.R")

doc_key = read.csv("data/doc_analysis_key.csv") 
core_weights = read.csv("data/processed/core_weights_depth.csv") 
weoc_subsampling = read.csv("data/weoc_subsampling_weights.csv") %>% 
  mutate(coreID = case_when(Site == "CPCRW" ~ paste0("C", Core),
                            Site == "SR" ~ paste0("S", Core)))

filePaths_npoc <- list.files(path = "data/npoc",pattern = "*.csv", full.names = TRUE)

npoc_data <-
  lapply(filePaths_npoc, read.csv, stringsAsFactors = FALSE, na.string = "") %>% 
  bind_rows() %>% 
  filter(is.na(notes))

npoc_data_processed = 
  npoc_data %>% 
  # clean the sample IDs, currently in weird format
  # extract the numbers, then add leading zeroes to make three digits
  # then add "DOC-" and merge with DOC key
  mutate(id = parse_number(sample),
         id = as.integer(str_remove_all(id, "-")),
         id = sprintf("%03d", id),
         DOC_ID = paste0("DOC-", id)) %>% 
  dplyr::select(DOC_ID, npoc_mg_l) %>% 
  left_join(doc_key) %>% 
  left_join(weoc_subsampling)
