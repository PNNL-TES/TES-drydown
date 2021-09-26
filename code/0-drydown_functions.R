
## Functions
# Kaizad F. Patel

## packages ####
library(readxl)
library(lubridate)     # 1.6.0
library(ggalt)
library(ggExtra)
library(stringi)
library(nlme)
library(car)
library(agricolae)
library(ggbiplot)
#library(DescTools)

library(drake)
pkgconfig::set_config("drake::strings_in_dots" = "literals")
library(tidyverse)

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


# custom ggplot function for Van Krevelen plots
gg_vankrev <- function(data,mapping){
  ggplot(data,mapping) +
    # plot points
    geom_point(size=2, alpha = 0.4) + # set size and transparency
    # axis labels
    ylab("H/C") +
    xlab("O/C") +
    # axis limits
    xlim(0,1.25) +
    ylim(0,2.5) +
    # add boundary lines for Van Krevelen regions
    geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
    geom_segment(x = 0.0, y = 2, xend = 1.2, yend = 2,color="black",linetype="longdash") +
    geom_segment(x = 0.0, y = 1, xend = 1.2, yend = 0.75,color="black",linetype="longdash") +
    geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.5,color="black",linetype="longdash")
}

## to make the Van Krevelen plot:
# replace the initial `ggplot` function with `gg_vankrev` and use as normal

## CREATE OUTPUT FILES
COREKEY = "data/processed/corekey.csv"
WSOC = "data/processed/wsoc.csv"
