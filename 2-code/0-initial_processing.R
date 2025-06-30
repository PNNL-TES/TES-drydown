

# corekey
sample_key = read_sheet("1ORU32O9ZeU1qFEZIpMUkIvMshEc0ziU-fIir1wXZEpA", na = c("", "NA"))
sample_key %>% filter(is.na(skip)) %>% write.csv("data/sample_key.csv", row.names = F, na = "")

doc_analysis_key = read_sheet("1CMU1gNACsZmLZ6ycB27X_zISoDHReeFVjK7TEIdX1d4")
doc_analysis_key %>% filter(is.na(skip)) %>% dplyr::select(coreID, depth, DOC_ID) %>% write.csv("data/doc_analysis_key.csv", row.names = F, na = "")

subsampling = read_sheet("1Ld-oTByerCn_C506_E1h8Kcnb5wpTVMxfPZh8bCoBwY", na = "")
subsampling %>% 
  filter(!is.na(coreID)) %>% 
  rename(weoc_g = fticr_wt_g) %>% 
  dplyr::select(coreID, depth, moisture_percent, weoc_g) %>% 
  mutate(moisture_percent = round(moisture_percent, 2)) %>% 
  write.csv("data/subsampling.csv", row.names = F, na = "")
