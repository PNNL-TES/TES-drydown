## FTICR BIOTIC-ABIOTIC TRANSFORMATIONS
## ORIGINAL CODE FROM ROBERT A. DANCZAK (NOV. 2019)
## MODIFIED INTO FUNCTIONS AND TIDYVERSE FORMAT BY KAIZAD F. PATEL (FEB. 2021)

## Use this script to calculate mass differences for each sample, linked to potential biotic/abiotic transformations

#####################
#####################


library(drake)
library(tidyverse)

# 1. SET input file paths -------------------------------
COREKEY = "data/processed/corekey.csv"
REPORT1 = "data/fticr/TES_drought_soil_Report1_2020-11-05.csv"
REPORT2 = "data/fticr/TES_drought_soil_Report2_timezero_2021-01-20.csv"
DOCKEY = "data/doc_analysis_key.csv"

# 2. source the fticr processing functions --------------------------------------------------------
source("code/fticrrr/a-functions_processing.R")


# 3. load drake plans -----------------------------------------------------
fticr_processing_plan_for_transformations = drake_plan(
  
  # 1. process the reports --------------------------------------------------
  # these targets are the same as the initial few targets in the fticr_processing_plan
  report1 = read.csv(file_in(REPORT1)),
  report2 = read.csv(file_in(REPORT2)),
  
  corekey = read.csv(file_in(COREKEY)),
  dockey = read.csv(file_in(DOCKEY)),
  
  datareport = combine_fticr_reports(report1, report2),
  fticr_meta = make_fticr_meta(datareport)$meta2,
  #fticr_data_longform = make_fticr_data(datareport, dockey, depth, Site, length, drying, saturation)$data_long_key_repfiltered,
  fticr_data_trt = make_fticr_data(datareport, dockey, depth, Site, length, drying, saturation)$data_long_trt,
  meta_formula = make_fticr_meta(datareport)$meta_formula,
  
  #
  # 2. load transformation file ---------------------------------------------
  #trans_full =  read.csv("data/fticr/Transformation_Database_10-2019.csv"),
  biotic_class = read.csv("data/fticr/transformation_database_biotic_abiotic_2020.csv", na.strings = ""),
  
  ## set error term for later calculations
  error_term = 0.000010,
  
  t1 = print(Sys.time()),
  
  transformations_c = compute_transformations(dat = fticr_data_trt %>% 
                                                filter(Site == "CPCRW" & length != "timezero"),
                                              meta_formula = meta_formula, 
                                              biotic_class = biotic_class),
  transformations_s = compute_transformations(dat = fticr_data_trt %>% 
                                                filter(Site == "SR" & length != "timezero"),
                                              meta_formula = meta_formula, 
                                              biotic_class = biotic_class),
  transformations_tz = compute_transformations(dat = fticr_data_trt %>% 
                                                filter(length == "timezero"),
                                              meta_formula = meta_formula, 
                                              biotic_class = biotic_class),

  transformation_summary = compute_transformation_summaries(transformations_c, transformations_s, transformations_tz)
  
  
)

make(fticr_processing_plan_for_transformations)


# TRANSFORMATIONS FUNCTIONS -----------------------------------------------

compute_transformations = function(meta_formula, dat, biotic_class){

# 0. format the biotic/abiotic input file ---------------------------------
  error_term = 0.000010
  
  biotic_class2 = 
    biotic_class %>% 
    filter(is.na(Notes)) %>% 
    mutate(Biotic_abiotic = recode(Biotic_abiotic, "Biotic/abiotic" = "both")) %>% 
    dplyr::select(-Notes) %>% 
    filter(Biotic_abiotic != "NA")
  
  # 1. format the data file -------------------------------------------
  ## fticr_data_trt has formula, but not mass. we need to add a mass column for the transformations
  meta_formula2 = 
    meta_formula %>% 
    group_by(formula) %>%  
    dplyr::summarise(Mass = mean(Mass))
  
  fticr_data_trt_with_mass = 
    dat %>% 
    left_join(meta_formula2) %>% 
    mutate(sample = paste(depth, Site, length, drying, saturation, sep = "_"))
  
  fticr_data_test2 = 
    fticr_data_trt_with_mass  %>% 
    #filter(Site == "CPCRW" & saturation == "saturated" & length == "150d") %>% 
    dplyr::select(Mass, sample) %>% 
    #filter(sample == c("0-5cm_CPCRW_150d_FAD_saturated", "0-5cm_SR_150d_CW_saturated", "0-5cm_SR_90d_FAD_instant chemistry")) %>% 
    #column_to_rownames("Mass") %>% 
    rename(peak = Mass) %>% 
    force()
  
  #  
  # 2. create a distance matrix -------------------------------------------------------------------------
  # join fticr_data_test2 with itself, so for each sample, each peak is matched with every other peak
  distance_results <- 
    fticr_data_test2 %>% 
    dplyr::select(sample, peak) %>% 
    left_join(fticr_data_test2, by = "sample") %>% 
    # IMPORTANT: left_join() by "sample" only. that way the peaks don't line up
    # next, calculate distance, and set range based on the error term from earlier
    # create a dummy column Trans_name, which will be filled in later
    dplyr::mutate(Dist = peak.x - peak.y,
                  Dist_plus = Dist + error_term,
                  Dist_minus = Dist - error_term,
                  Trans_name = -999)
  
  
  # 3. bring in transformations ---------------------------------------------
  ## we will use a for-loop here to match transformations with distance
  ## the loop pulls one metabolite/transformation from the list, matches it to the relevant peaks, 
  ## and then moves on to the next metabolite
  ## the peak name is pasted into the Trans_name column
  
  ## I have set t1 and t2 to determine how long this process takes
  t1 = print(Sys.time())
  
  for (current_trans in unique(biotic_class$Name)) { # note that for masses with multiple names, only the last name is going to be recorded
    
    mass_diff = biotic_class$Mass[which(biotic_class$Name == current_trans)]
    if (length(mass_diff) > 1) { break() }
    distance_results$Trans_name[ which(distance_results$Dist_plus >= mass_diff & distance_results$Dist_minus <= mass_diff)  ] = current_trans
    
  }
  
  t2 = print(Sys.time())
  
  ## now, we clean the output file distance_results
  ## first, remove all rows where we don't have a transformation
  distance_results = distance_results %>% filter(Trans_name != "-999")
  t3 = print(Sys.time())
  
  ## clean up the file and keep only the columns we need
  distance_results_clean = 
    distance_results %>%
    rename(peak = `peak.x`) %>% 
    dplyr::select(sample, peak, Trans_name)
  
  # 4. set biotic/abiotic ---------------------------------------------------
  ## first, clean up the classification
  ## we have some transformations that are Biotic, some Abiotic, and some both
        ##  biotic_class2 = 
        ##    biotic_class %>% 
        ##    mutate(Biotic_abiotic = recode(Biotic_abiotic, "Biotic/abiotic" = "both")) %>% 
        ##    dplyr::select(-Notes) %>% 
        ##    filter(Biotic_abiotic != "NA")
  
  ## then merge this with the distance results
  #distance_biotic = 
  distance_results_clean %>% 
    left_join(biotic_class2, by = c("Trans_name" = "Name")) %>% 
    drop_na()   
  
  ## THIS IS OUR PRIMARY OUTPUT FILE
  
  
  #list(distance_biotic = distance_biotic)
}

compute_transformation_summaries = function(transformations_c, transformations_s, transformations_tz){
  
  # 1. combine the subsets --------------------------------------------------
  combined_transformations = rbind(transformations_c, transformations_s, transformations_tz)
  
  # 2. calculate biotic/abiotic transformations per sample ------------------
  biotic_abiotic_counts = 
    combined_transformations %>% 
    group_by(sample, Biotic_abiotic) %>% 
    dplyr::summarise(n = n()) %>% 
    group_by(sample) %>% 
    mutate(total = sum(n),
           percentage = (n/total)*100)
  
  
  # 3. calculate transformation counts per sample ---------------------------
  ## how many times was each transformation seen?
  transformation_count_long = 
    combined_transformations %>% 
    group_by(sample, Biotic_abiotic, Trans_name) %>% 
    dplyr::summarise(count = n()) %>% 
    group_by(sample) %>% 
    mutate(total = n(),
           percentage = (count/total)*100)
  
  transformation_count_wide = 
    transformation_count_long %>% 
    dplyr::select(sample, Biotic_abiotic, Trans_name, count) %>% 
    pivot_wider(names_from = "sample", values_from = "count")
  
  transformation_count_wide_relabund = 
    transformation_count_long %>% 
    dplyr::select(sample, Biotic_abiotic, Trans_name, percentage) %>% 
    pivot_wider(names_from = "sample", values_from = "percentage")
  
  list(biotic_abiotic_counts = biotic_abiotic_counts,
       transformation_count_long = transformation_count_long,
       transformation_count_wide = transformation_count_wide,
       transformation_count_wide_relabund = transformation_count_wide_relabund
  )
  
  
  
}



#############################
#############################
## OLD CODE ####
#############################
#############################


loadd(datareport)
loadd(fticr_data_trt)
loadd(fticr_meta)

# load transformations
trans_full =  read.csv("data/fticr/Transformation_Database_10-2019.csv")

# bring back Mass 
meta_formula = make_fticr_meta(datareport)$meta_formula
meta_formula2 = meta_formula %>% 
  group_by(formula) %>%  dplyr::summarise(Mass = mean(Mass))
fticr_meta_with_mass = fticr_meta %>% left_join(meta_formula2)

fticr_data_trt_with_mass = fticr_data_trt %>% left_join(meta_formula2) %>% 
  mutate(sample = paste(depth, Site, length, drying, saturation, sep = "_"))

# create a test dataset
fticr_data_test = 
  fticr_data_trt_with_mass  %>% 
  dplyr::select(Mass, sample) %>% 
  filter(sample == "0-5cm_CPCRW_150d_FAD_saturated") %>% 
  #column_to_rownames("Mass") %>% 
  rename(peak = Mass) %>% 
  force()

fticr_data_test2 = 
  fticr_data_trt_with_mass  %>% 
  filter(Site == "CPCRW" & saturation == "saturated" & length == "150d") %>% 
  dplyr::select(Mass, sample) %>% 
  #filter(sample == c("0-5cm_CPCRW_150d_FAD_saturated", "0-5cm_SR_150d_CW_saturated", "0-5cm_SR_90d_FAD_instant chemistry")) %>% 
  #column_to_rownames("Mass") %>% 
  rename(peak = Mass) %>% 
  force()

# error term
error_term = 0.000010

#sample_matrix = cbind(peak = row.names(fticr_data_test), fticr_data_test)

#sample_peak_mat = sample_matrix %>% gather("sample", "value", -2) %>% filter(value > 0) %>% dplyr::select(sample, peak)

distance_results <- fticr_data_test2 %>% 
  dplyr::select(sample, peak) %>% 
  left_join(fticr_data_test2, by = "sample") %>% 
  dplyr::mutate(Dist = peak.x - peak.y,
                Dist_plus = Dist + error_term,
                Dist_minus = Dist - error_term,
                Trans_name = -999)


# distance_results2 = 
#  subset(bind_cols(distance_results, trans_full), Dist_plus >= Mass & Dist_minus <= Mass)


#counter = 1

for (current_trans in unique(trans_full$Name)) { # note that for masses with multiple names, only the last name is going to be recorded
  
  mass_diff = trans_full$Mass[which(trans_full$Name == current_trans)]
  if (length(mass_diff) > 1) { break() }
  distance_results$Trans_name[ which(distance_results$Dist_plus >= mass_diff & distance_results$Dist_minus <= mass_diff)  ] = current_trans
  #print(c(counter,current.trans,mass.diff,length(mass.diff)))
  
  #counter = counter + 1
  
}

t2 = print(Sys.time())

distance_results = distance_results %>% filter(Trans_name != "-999")
t3 = print(Sys.time())

distance_results_clean = 
  distance_results %>%
  rename(peak = `peak.x`) %>% 
  dplyr::select(sample, peak, Trans_name)


biotic_class = read.csv("data/fticr/transformation_database_biotic_abiotic_2020.csv", na.strings = "")
biotic_class2 = 
  biotic_class %>% 
  mutate(Biotic_abiotic = recode(Biotic_abiotic, "Biotic/abiotic" = "both")) %>% 
  dplyr::select(-Notes) %>% 
  filter(Biotic_abiotic != "NA")

## replace biotic/abiotic with both 
## replace "biotic but didnt use" with biotic
distance_biotic = 
  distance_results_clean %>% 
  left_join(biotic_class2, by = c("Trans_name" = "Name")) %>% 
  drop_na() 


distance_biotic %>% write.csv("data/fticr/sf_drydown/transformations_cpcrw_sat_150d.csv", row.names = FALSE)

## calculate number of biotic/abiotic transformations per sample
biotic_abiotic_counts = 
  distance_biotic %>% 
  group_by(sample, Biotic_abiotic) %>% 
  dplyr::summarise(n = n()) %>% 
  group_by(sample) %>% 
  mutate(total = sum(n),
         percentage = (n/total)*100)


## n per transformation per sample
## how many times was each transformation seen?
transformation_count_long = 
  distance_biotic %>% 
  group_by(sample, Biotic_abiotic, Trans_name) %>% 
  dplyr::summarise(count = n()) %>% 
  group_by(sample) %>% 
  mutate(total = n(),
         percentage = (count/total)*100)

transformation_count_wide = 
  transformation_count_long %>% 
  dplyr::select(sample, Biotic_abiotic, Trans_name, count) %>% 
  pivot_wider(names_from = "sample", values_from = "count")

transformation_count_wide_relabund = 
  transformation_count_long %>% 
  dplyr::select(sample, Biotic_abiotic, Trans_name, percentage) %>% 
  pivot_wider(names_from = "sample", values_from = "percentage")


biotic_abiotic_counts %>% write.csv("data/fticr/sf_drydown/transformations_cpcrw_sat_150d_biotic_abiotic_summary.csv", row.names = FALSE, na = "")

transformation_count_wide %>% write.csv("data/fticr/sf_drydown/transformations_cpcrw_sat_150d_transformation_count_wide.csv", row.names = FALSE, na = "")

transformation_count_long %>% write.csv("data/fticr/sf_drydown/transformations_cpcrw_sat_150d_transformation_count_long.csv", row.names = FALSE)
transformation_count_wide_relabund %>% write.csv("data/fticr/sf_drydown/transformations_cpcrw_sat_150d_transformation_count_wide_relabund.csv", row.names = FALSE, na = "")




## PCA and Kruskal-Wallis/Tukey (??)

## Network analysis?

## centered log ratio (CLR) ??? d



##      
##      Distance_Results_temp = Distance_Results
##      
##      Distance_Results = 
##        Distance_Results_temp[-which(Distance_Results_temp$Trans.name == -999),] %>% 
##        mutate(sample = "a")
##      head(Distance_Results)
##      
##      # Creating directory if it doesn't exist, prior to writing the output file
##      if(length(grep(Sample_Name,list.dirs("Transformation Peak Comparisons", recursive = F))) == 0){
##        dir.create(paste("data/fticr/", Sample_Name, sep=""))
##        print("Directory created")
##      }
##      
##      write.csv(Distance_Results,paste("data/fticr/",Sample_Name,"/Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
##      
##      # Alternative .csv writing
##      # write.csv(Distance_Results,paste("Transformation Peak Comparisons/", "Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
##      
##      # sum up the number of transformations and update the matrix
##      tot.trans = rbind(tot.trans,c(dist.unique,nrow(Distance_Results)))
##      
##      # generate transformation profile for the sample
##      trans.profile = as.data.frame(tapply(X = Distance_Results$Trans.name,INDEX = Distance_Results$Trans.name,FUN = 'length')); head(trans.profile)
##      colnames(trans.profile) = dist.unique
##      head(trans.profile)
##      
##      # update the profile matrix
##      profiles.of.trans = merge(x = profiles.of.trans,y = trans.profile,by.x = "Name",by.y = 0,all.x = T)
##      profiles.of.trans[is.na(profiles.of.trans[,dist.unique]),dist.unique] = 0
##      head(profiles.of.trans)
##      str(profiles.of.trans)
##      
##      # find the number of transformations each peak was associated with
##      peak.stack = as.data.frame(c(Distance_Results$peak.x,Distance_Results$peak.y)); head(peak.stack)
##      peak.profile = as.data.frame(tapply(X = peak.stack[,1],INDEX = peak.stack[,1],FUN = 'length' )); dim(peak.profile)
##      colnames(peak.profile) = 'num.trans.involved.in'
##      peak.profile$sample = dist.unique
##      peak.profile$peak = row.names(peak.profile)
##      head(peak.profile);
##      
##      # Creating directory if it doesn't exist, prior to writing the output file
##      if(length(grep(Sample_Name,list.dirs("Transformations per Peak", recursive = F))) == 0){
##        dir.create(paste("data/fticr/", Sample_Name, "2", sep=""))
##        print("Directory created")
##      }
##      
##      # Writing data to newly created directory
##      write.csv(peak.profile,paste("data/fticr/", Sample_Name, "2/Num.Peak.Trans_",dist.unique,".csv",sep=""), quote = F,row.names = F)
##      
##      # Alternative .csv writing
##      # write.csv(peak.profile,paste("Transformations per Peak/", "Num.Peak.Trans_",dist.unique,".csv",sep=""),quote = F,row.names = F)
##      
##      print(dist.unique)
##      print(date())
##      
##    }
##    
##    # format the total transformations matrix and write it out
##    tot.trans = as.data.frame(tot.trans)
##    colnames(tot.trans) = c('sample','total.transformations')
##    tot.trans$sample = as.character(tot.trans$sample)
##    tot.trans$total.transformations = as.numeric(as.character(tot.trans$total.transformations))
##    str(tot.trans)
##    write.csv(tot.trans,paste(Sample_Name,"_Total_Transformations.csv", sep=""),quote = F,row.names = F)
##    
##    # write out the trans profiles across samples
##    write.csv(profiles.of.trans,paste(Sample_Name, "_Trans_Profiles.csv", sep=""),quote = F,row.names = F)
##    