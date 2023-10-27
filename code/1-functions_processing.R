


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

