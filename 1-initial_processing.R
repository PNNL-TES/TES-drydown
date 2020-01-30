### Jan 30, 2020

source("0-drydown_functions.R")

# clean the corekey

cpcrw_key = read.csv("data/cpcrw_corekey.csv")

cpcrw_corekey = 
  cpcrw_key %>% 
  dplyr::mutate(coreID = paste0("C",Core),
                site="CPCRW",
                location = case_when(grepl("_up_",Core_assignment)~"upland",
                                     grepl("_low_",Core_assignment)~"lowland"),
                drying = case_when(grepl("_CW_",Core_assignment)~"constant weight",
                                     grepl("_FAD_",Core_assignment)~"forced"),
                length = case_when(grepl("_30d_",Core_assignment)~"30 day",
                                   grepl("_90d_",Core_assignment)~"90 day",
                                   grepl("_150d_",Core_assignment)~"150 day",
                                   grepl("_1000d_",Core_assignment)~"1000 day"),
                replicate = case_when(grepl("_r1",Core_assignment)~1,
                                      grepl("_r2",Core_assignment)~2,
                                      grepl("_r3",Core_assignment)~3,
                                      grepl("_r4",Core_assignment)~4))

## OUTPUT
write_csv(cpcrw_corekey, COREKEY)
