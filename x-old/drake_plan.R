# drake plan

library(drake)
pkgconfig::set_config("drake::strings_in_dots" = "literals")
library(ggplot2)
theme_set(theme_bw())
library(googlesheets)
library(readxl)
library(tidyr)
library(dplyr)

download_massdata <- function() {
  # https://docs.google.com/spreadsheets/d/1iFiROVEIDj4mnNdJpk9A5mtby0Y4-Hl0UmWhyN-mZ1c/edit#gid=884986514
  key <- gs_key("1iFiROVEIDj4mnNdJpk9A5mtby0Y4-Hl0UmWhyN-mZ1c")
  old <- getwd()
  setwd("data/")
  on.exit(setwd(old))
  gs_download(key, overwrite = TRUE)
}

read_massdata <- function(fqfn) {
  ca <- readxl::read_excel(fqfn, sheet = "Core_assignments")
  
  readxl::read_excel(fqfn, sheet = "Mass_tracking") %>% 
    filter(!is.na(Site), Site != "AMB", Core != "0") %>% 
    left_join(ca, by = "Core") %>% 
    separate(Core_assignment, into = c("Site1", "Length", "uplow", "drying", "rep"))
}

plan <- drake_plan(
  massdata_file = download_massdata(),
  massdata = read_massdata(massdata_file),
  
  # README file and diagnostics
  readme = rmarkdown::render(
    knitr_in("README.Rmd"),
    output_file = file_out("README.md"),
    quiet = TRUE)
)
