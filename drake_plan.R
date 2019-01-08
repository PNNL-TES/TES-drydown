# drake plan

library(drake)
library(ggplot2)
theme_set(theme_bw())
library(googlesheets)
library(readxl)
library(tidyr)
library(dplyr)

download_massdata <- function() {
  key <- gs_key("1iFiROVEIDj4mnNdJpk9A5mtby0Y4-Hl0UmWhyN-mZ1c")
  old <- getwd()
  setwd("data/")
  on.exit(setwd(old))
  gs_download(key, overwrite = TRUE)
}

read_massdata <- function(fqfn) {
  readxl::read_excel(fqfn) %>% 
    filter(Site != "AMB") %>% 
    separate(Core_assignment, into = c("Site1", "Length", "up", "FAD", "r"))
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
