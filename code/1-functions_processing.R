


# 
compute_dry_weights = function(subsampling){
  #  x =   
  subsampling %>% 
    mutate(wt_dry_soil_g = weoc_g/((moisture_percent/100) + 1),
           vol_water_mL = weoc_g - wt_dry_soil_g) %>% 
    dplyr::select(coreID, depth, wt_dry_soil_g, vol_water_mL) %>% 
    mutate_if(is.numeric, round, 2)
  
}


refactor_levels = function(dat){
  
  dat %>% 
    mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d", "1000d")),
           saturation = factor(saturation, levels = c("timezero", "drought", "d+rewet")),
           drying = factor(drying, levels = c("air-dried", "force-dried")))
  
}


# WEOC ----

import_weoc_data = function(FILEPATH){
  
  filePaths_weoc <- list.files(path = FILEPATH, pattern = "*.csv", full.names = TRUE)
  weoc_dat <- do.call(bind_rows, lapply(filePaths_weoc, function(path) {
    df <- read_csv(path)
    df}))
  
}
#weoc_data = import_weoc_data(FILEPATH = "data/npoc")
process_weoc = function(weoc_data, doc_key, dry_weights){
  
  weoc_processed = 
    weoc_data %>% 
    dplyr::select(-notes) %>% 
    left_join(doc_key) %>% 
    # join gwc and subsampling weights to normalize data to soil weight
    left_join(dry_weights, by = c("coreID", "depth")) %>% 
    mutate(npoc_ugg = npoc_mgL * (40 + vol_water_mL/wt_dry_soil_g),
           npoc_mgg = npoc_ugg/1000,
           npoc_mgg = round(npoc_mgg, 2)) %>% 
    dplyr::select(DOC_ID, coreID, depth, npoc_mgL, npoc_mgg) %>% 
    force()
  
  weoc_processed
  
}

# FTICR ----
import_fticr = function(FILEPATH){
  
  filePaths_fticr <- list.files(path = FILEPATH, pattern = "*.csv", full.names = TRUE)
  fticr_dat <- do.call(bind_rows, lapply(filePaths_fticr, function(path) {
    df <- read_csv(path)
    df}))
  
}
#fticr_report = import_fticr(FILEPATH = "data/fticr")
process_fticr = function(fticr_report, doc_key, sample_key){
  
  fticr_meta = fticr_make_metadata(report = fticr_report)$meta2
  mass_to_formula = fticr_make_metadata(report = fticr_report)$meta_formula
  
  data_columns = 
    fticr_report %>% 
    dplyr::select(Mass, contains("DOC")) %>% 
    pivot_longer(cols = -Mass) %>% 
    mutate(name = str_replace(name, "DOC_", "DOC"),
           name = str_replace(name, "DOC-", "DOC"),
           name = str_extract(name, "DOC[0-9]{3}"),
           name = str_replace(name, "DOC", "DOC-")) %>% 
    filter(!is.na(name)) %>% 
    pivot_wider()
  #data_columns %>% write.csv("fticr_data.csv", row.names = F, na = "")
  
  data_presence = 
    fticr_compute_presence(data_columns) %>% 
    left_join(mass_to_formula, by = "Mass") %>% 
    filter(!is.na(formula))
  
  data_long = 
    data_presence %>% 
  #  mutate(name = str_replace(name, "DOC_", "DOC-")) %>% 
    rename(DOC_ID = name) %>% 
    left_join(doc_key) %>% 
    left_join(sample_key) %>%
    filter(!is.na(site)) %>% 
    fticr_apply_replication_filter(site, depth, length, saturation, drying)
  
  data_long_trt = 
    data_long %>% 
    distinct(formula, site, depth, length, saturation, drying)

  
  list(fticr_meta = fticr_meta,
       data_long = data_long,
       data_long_trt = data_long_trt)  
}
fticr_compute_relabund_cores = function(fticr_long, fticr_meta, TREATMENTS){
  
  fticr_long %>% 
    # add the Class column to the data
    left_join(dplyr::select(fticr_meta, formula, Class), by = "formula") %>% 
    # calculate abundance of each Class as the sum of all counts
    group_by(coreID, Class, !!!TREATMENTS) %>%
    dplyr::summarise(abund = sum(presence)) %>%
    filter(!Class %in% "other") %>% 
    ungroup %>% 
    # create a new column for total counts per core assignment
    # and then calculate relative abundance  
    group_by(coreID, !!!TREATMENTS) %>% 
    dplyr::mutate(total = sum(abund),
                  relabund  = round((abund/total)*100,2))
}
