
## Functions
# Kaizad F. Patel

## packages ####
library(tidyverse)
#library(ggalt)
#library(ggExtra)
library(stringi)
library(nlme)
library(car)
library(agricolae)
library(ggbiplot)
library(googlesheets4)
#library(DescTools)


# My 'picarro.data' package isn't on CRAN (yet) so need to install it via:
# devtools::install_github("PNNL-TES/picarro.data")
library(picarro.data)

# custom ggplot theme
theme_kp <- function() {  # this for all the elements common across plots
  theme_bw() %+replace%
    theme(legend.position = "top",
          legend.key=element_blank(),
          legend.title = element_blank(),
          legend.text = element_text(size = 12),
          legend.key.size = unit(1.5, 'lines'),
          legend.background = element_rect(colour = NA),
          panel.border = element_rect(color="black",size=1.5, fill = NA),
          
          plot.title = element_text(hjust = 0.0, size = 14),
          axis.text = element_text(size = 12, color = "black"),
          axis.title = element_text(size = 14, face = "bold", color = "black"),
          
          # formatting for facets
          panel.background = element_blank(),
          strip.background = element_rect(colour="white", fill="white"), #facet formatting
          panel.spacing.x = unit(1.5, "lines"), #facet spacing for x axis
          panel.spacing.y = unit(1.5, "lines"), #facet spacing for x axis
          strip.text.x = element_text(size=12, face="bold"), #facet labels
          strip.text.y = element_text(size=12, face="bold", angle = 270) #facet labels
    )
}

