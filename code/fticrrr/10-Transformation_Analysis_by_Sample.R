### Determing carbon transformations ###
### Code from RAD


######## #

library(tidyverse)
  ##  library(dplyr)
  ##  library(tidyr)
  ##  library(readr)         # 1.0.0

options(digits=10) # Sig figs in mass resolution data

Sample_Name = "drought_fullset"


# -------------------------------------------------------------------------

# 1. SET input file paths -------------------------------
COREKEY = "data/processed/corekey.csv"
REPORT1 = "data/fticr/TES_drought_soil_Report1_2020-11-05.csv"
REPORT2 = "data/fticr/TES_drought_soil_Report2_timezero_2021-01-20.csv"
DOCKEY = "data/doc_analysis_key.csv"

# 2. source the fticr processing functions --------------------------------------------------------
source("code/fticrrr/a-functions_processing.R")


# load files --------------------------------------------------------------

report1 = read.csv((REPORT1))
report2 = read.csv((REPORT2))

corekey = read.csv((COREKEY))
dockey = read.csv((DOCKEY))

datareport = combine_fticr_reports(report1, report2)
fticr_meta = make_fticr_meta(datareport)$meta2
#fticr_data_longform = make_fticr_data(datareport, dockey, depth, Site, length, drying, saturation)$data_long_key_repfiltered,
fticr_data_trt = make_fticr_data(datareport, dockey, depth, Site, length, drying, saturation)$data_long_trt
meta_formula = make_fticr_meta(datareport)$meta_formula



# format data file --------------------------------------------------------

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
  fticr_data_trt %>% 
  left_join(meta_formula2) %>% 
  mutate(sample = paste(depth, Site, length, drying, saturation, sep = "_"))

    fticr_data_test2 = 
      fticr_data_trt_with_mass  %>% 
      filter(length == "timezero") %>% 
      mutate(sample = paste0(Site, "_", depth, "_", length),
             presence = 1) %>% 
      dplyr::select(Mass, sample, presence) %>% 
      pivot_wider(names_from = "sample", values_from = "presence") %>% 
      replace(is.na(.), 0) %>% 
      #filter(sample == c("0-5cm_CPCRW_150d_FAD_saturated", "0-5cm_SR_150d_CW_saturated", "0-5cm_SR_90d_FAD_instant chemistry")) %>% 
      #column_to_rownames("Mass") %>% 
      #rename(peak = Mass) %>% 
      force()


data = 
  fticr_data_trt_with_mass %>% 
  dplyr::select(sample, Mass) %>% 
  mutate(presence = 1) %>% 
  pivot_wider(names_from = "sample", values_from = "presence") %>% 
  replace(is.na(.), 0) %>% 
  force()

#
# 2. load transformation file ---------------------------------------------
#trans_full =  read.csv("data/fticr/Transformation_Database_10-2019.csv"),
trans = read.csv("data/fticr/transformation_database_biotic_abiotic_2020.csv", na.strings = "")

trans.full = 
  trans %>% 
  filter(is.na(Notes)) %>% 
  mutate(Biotic_abiotic = recode(Biotic_abiotic, "Biotic/abiotic" = "both")) %>% 
  dplyr::select(-Notes) %>% 
  filter(Biotic_abiotic != "NA")





    ##    
    ##    #######################
    ##    ### Loading in data ###
    ##    #######################
    ##    
    ##    # Loading in ICR data
    ##    #setwd("~/Documents/48 Hour Meta-analysis/Individual Datasets/Nisqually River/")
    ##    mol = read_csv("data/FTICR_INPUT_SOILPORE.csv.zip") %>% 
    ##      dplyr::select(1:14) %>% 
    ##      dplyr::filter(!C13==1)# Keeping data and mol-data seperate to ensure they are unaltered
    ##    data = read_csv("data/FTICR_INPUT_SOILPORE.csv.zip") %>% 
    ##      dplyr::filter(!C13==1)%>% dplyr::select(1,16) 
    ##    
data = as.data.frame(data)
data.row = data$Mass
data = as.data.frame(data[,-1])
row.names(data) = data.row

    ##  mol = as.data.frame(mol)
    ##  row.names(mol) = mol$Mass

colnames(data) = paste("Sample_", colnames(data), sep="")

  ##    # Checking row names consistency
  ##    if(identical(x = row.names(data), y = row.names(mol)) == FALSE){
  ##      stop("Something is incorrect in your row names")
  ##    }

# Loading in transformations
# trans.full =  read.csv("data/Transformation_Database_10-2019.csv")
trans.full$Name = as.character(trans.full$Name)

# ############# #
#### Errors ####
# ############ #

    ##  # Checking row names consistency between molecular info and data
    ##  if(identical(x = row.names(data), y = row.names(mol)) == FALSE){
    ##    stop("Something is incorrect: the mol. info and peak counts don't match")
    ##  }
    ##  
    ##  # Checking to ensure "FREDA_Processing.R" was run
    ##  if(length(which(mol$C13 == 1)) > 0){
    ##    stop("Isotopic signatures weren't removed, please run FREDA_Processing.R")
    ##  }
    ##  
    ##  if(length(grep("QC_SRFAII", colnames(data))) > 0){
    ##    stop("Suwannee River standards are still in the data, please run FREDA_Processing.R")
    ##  }
    ##  
    ##  if(length(grep("rep1|rep2", colnames(data))) > 0){
    ##    stop("Technical replicates are still in the data, please run FREDA_Processing.R")
    ##  }
    ##  
    ##  if(max(data) > 1){
    ##    print("Data was not presence/absence, please run FREDA_Processing.R")
    ##    data[data > 1] = 1
    ##  }
    ##  
# Creating output directories
if(!dir.exists("Transformation Peak Comparisons")){
  dir.create("Transformation Peak Comparisons")
}

if(!dir.exists("Transformations per Peak")){
  dir.create("Transformations per Peak")
}


###########################################
### Running through the transformations ###
###########################################

# pull out just the sample names
samples.to.process = colnames(data)

# error term
error.term = 0.000010

# matrix to hold total number of transformations for each sample
tot.trans = numeric()

# matrix to hold transformation profiles
profiles.of.trans = trans.full
head(profiles.of.trans)

for (current.sample in samples.to.process) {
  
  print(date())
  
  one.sample.matrix = cbind(as.numeric(as.character(row.names(data))), data[,which(colnames(data) == current.sample), drop = FALSE]) # "drop = FALSE" ensures that the row and column names remain associated with the data
  colnames(one.sample.matrix) = c("peak", colnames(one.sample.matrix[2]))
  # print(head(one.sample.matrix))
  
  Sample_Peak_Mat <- one.sample.matrix %>% tidyr::gather("sample", "value", -1) %>% filter(value > 0) %>% dplyr::select(sample, peak)
  Distance_Results <- Sample_Peak_Mat %>% left_join(Sample_Peak_Mat, by = "sample") %>% filter(peak.x > peak.y) %>% dplyr::mutate(Dist = peak.x - peak.y) %>% dplyr::select(sample, Dist,peak.x,peak.y)
  Distance_Results$Dist.plus = Distance_Results$Dist + error.term
  Distance_Results$Dist.minus = Distance_Results$Dist - error.term
  Distance_Results$Trans.name = -999
  head(Distance_Results)
  
  dist.unique = unique(Distance_Results[,'sample']) #unique samples
  
  date()
  
  #counter = 1
  
  for (current.trans in unique(trans.full$Name)) { # note that for masses with multiple names, only the last name is going to be recorded
    
    mass.diff = trans.full$Mass[which(trans.full$Name == current.trans)]
    if (length(mass.diff) > 1) { break() }
    Distance_Results$Trans.name[ which(Distance_Results$Dist.plus >= mass.diff & Distance_Results$Dist.minus <= mass.diff)  ] = current.trans
    #print(c(counter,current.trans,mass.diff,length(mass.diff)))
    
    #counter = counter + 1
    
  }
  
  date()
  
  Distance_Results = Distance_Results[-which(Distance_Results$Trans.name == -999),]
  head(Distance_Results)
  
  # Creating directory if it doesn't exist, prior to writing the output file
  if(length(grep(Sample_Name,list.dirs("Transformation Peak Comparisons", recursive = F))) == 0){
    dir.create(paste("Transformation Peak Comparisons/", Sample_Name, sep=""))
    print("Directory created")
  }

  write.csv(Distance_Results,paste("Transformation Peak Comparisons/",Sample_Name,"/Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)

  # Alternative .csv writing
  # write.csv(Distance_Results,paste("Transformation Peak Comparisons/", "Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  
  # sum up the number of transformations and update the matrix
  tot.trans = rbind(tot.trans,c(dist.unique,nrow(Distance_Results)))
  
  # generate transformation profile for the sample
  trans.profile = as.data.frame(tapply(X = Distance_Results$Trans.name,INDEX = Distance_Results$Trans.name,FUN = 'length')); head(trans.profile)
  colnames(trans.profile) = dist.unique
  head(trans.profile)
  
  # update the profile matrix
  profiles.of.trans = merge(x = profiles.of.trans,y = trans.profile,by.x = "Name",by.y = 0,all.x = T)
  profiles.of.trans[is.na(profiles.of.trans[,dist.unique]),dist.unique] = 0
  head(profiles.of.trans)
  str(profiles.of.trans)
  
  # find the number of transformations each peak was associated with
  peak.stack = as.data.frame(c(Distance_Results$peak.x,Distance_Results$peak.y)); head(peak.stack)
  peak.profile = as.data.frame(tapply(X = peak.stack[,1],INDEX = peak.stack[,1],FUN = 'length' )); dim(peak.profile)
  colnames(peak.profile) = 'num.trans.involved.in'
  peak.profile$sample = dist.unique
  peak.profile$peak = row.names(peak.profile)
  head(peak.profile);
  
  # Creating directory if it doesn't exist, prior to writing the output file
  if(length(grep(Sample_Name,list.dirs("Transformations per Peak", recursive = F))) == 0){
    dir.create(paste("Transformations per Peak/", Sample_Name, sep=""))
    print("Directory created")
  }

  # Writing data to newly created directory
  write.csv(peak.profile,paste("Transformations per Peak/",Sample_Name,"/Num.Peak.Trans_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  
  # Alternative .csv writing
  # write.csv(peak.profile,paste("Transformations per Peak/", "Num.Peak.Trans_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  
  print(dist.unique)
  print(date())
  
}

# format the total transformations matrix and write it out
tot.trans = as.data.frame(tot.trans)
colnames(tot.trans) = c('sample','total.transformations')
tot.trans$sample = as.character(tot.trans$sample)
tot.trans$total.transformations = as.numeric(as.character(tot.trans$total.transformations))
str(tot.trans)
write.csv(tot.trans,paste(Sample_Name,"_Total_Transformations.csv", sep=""),quote = F,row.names = F)

# write out the trans profiles across samples
write.csv(profiles.of.trans,paste(Sample_Name, "_Trans_Profiles.csv", sep=""),quote = F,row.names = F)


# -------------------------------------------------------------------------

## process the output

filePaths <- list.files(path = "Transformation Peak Comparisons/drought_fullset/",pattern = "*.csv", full.names = TRUE)

# rbind.fill binds all rows and fills in missing columns
all_data <- do.call(rbind, lapply(filePaths, function(path) {
  # the files are tab-delimited, so read.csv will not work. import using read.table
  # there is no header. so create new column names
  # then add a new column `source` to denote the file name
  df <- read.csv(path, header=TRUE)
  #df[["source"]] <- rep(path, nrow(df))
  df}))



all_data_trans = 
  all_data %>% 
  dplyr::select(sample, `Trans.name`) %>% 
  rename(Name = `Trans.name`) %>% 
  left_join(trans.full)

biotic_abiotic_counts = 
  all_data_trans %>% 
  group_by(sample, Biotic_abiotic) %>% 
  dplyr::summarise(n = n()) %>% 
  group_by(sample) %>% 
  mutate(total = sum(n),
         percentage = (n/total)*100)





transformation_count_long = 
  all_data_trans %>% 
  group_by(sample, Biotic_abiotic, Name) %>% 
  dplyr::summarise(count = n()) %>% 
  group_by(sample) %>% 
  mutate(total = sum(count),
         percentage = round((count/total)*100, 2))

transformation_count_wide = 
  transformation_count_long %>% 
  dplyr::select(sample, Biotic_abiotic, Name, count) %>% 
  pivot_wider(names_from = "sample", values_from = "count")

transformation_count_wide_relabund = 
  transformation_count_long %>% 
  dplyr::select(sample, Biotic_abiotic, Name, percentage) %>% 
  pivot_wider(names_from = "sample", values_from = "percentage")



transformation_count_long %>% 
  group_by(sample) %>% 
  #top_n(percentage, 10) %>% 
#  mutate(length = factor(length, levels = c("timezero", "30d", "90d", "150d")),
#         saturation = recode(saturation, "instant chemistry" = "instant")) %>% 
  #filter(site == "CPCRW") %>% 
  ggplot(aes(x = sample, y = reorder(Name, Name), fill = percentage))+
  geom_tile(color = "white", size = 0)+
  #facet_grid(depth ~ site + length + saturation, scales = "free_x")+
  scale_fill_gradientn(colours = pnw_palette("Sunset2"))+
  labs(title = "top 10 transformations",
       x = "",
       y = "",
       fill = "% occurrence",
       caption = "blank spaces = transformation was not seen")+
  theme_bw()+
  theme(panel.grid = element_blank())+
  NULL
