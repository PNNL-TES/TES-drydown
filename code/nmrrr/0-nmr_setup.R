
# PART I. LOAD PACKAGES ----
## library(readxl)
## library(readr)
## library(tidyverse)
## library(data.table)
## # library(plyr)
## library(tidyr)
## library(dplyr)
## library(ggplot2)


#

# FILE PATHS --------------------------------------------------------------
SPECTRA_FILES = "data/nmr-data/nmr_spectra/"
PEAKS_FILES = "data/nmr-data/nmr_peaks/"
BINS = "data/0-NMR_BINS.csv"
## 
## COREKEY = "data/processed/corekey.csv"
## DOCKEY = "data/doc_analysis_key.csv"
## 
## PROCESSED_PEAKS = "processed/peaks.csv"
## 
## RELABUND_CORES = "processed/relabund_cores.csv"
## RELABUND_TRT = "processed/relabund_trt.csv"
## RELABUND_SUMMARY = "processed/relabund_summary.csv"

#
# BINS SETUP --------------------------------------------------------------
## 1. set up bins ----

## choose which set of BINS SET to use
cat("ACTION: choose correct value of BINSET
      a.> Clemente2012
      b.> Lynch2019
      c.> Mitchell2018
  type this into the code
  e.g.: BINSET = [quot]Clemente2012[quot]")

BINSET = "Clemente2012"

bins = read_csv(BINS)
bins2 = 
  bins %>% 
  # here we select only the BINSET we chose above
  dplyr::select(group,startstop,BINSET) %>% 
  na.omit %>% 
  spread(startstop,BINSET) %>% 
  arrange(start) %>% 
  dplyr::mutate(number = row_number())


#
## 2. bins for water and DMSO solvent ----
WATER_start = 3
WATER_stop = 4

DMSO_start = 2.25
DMSO_stop = 2.75

#


#
# SPECTRA SETUP -----------------------------------------------------------
## 1. spectra with banded regions ----
gg_nmr1 =
  ggplot()+
  geom_rect(data=bins2, aes(xmin=start, xmax=stop, ymin=-Inf, ymax=+Inf, fill=reorder(group, start)), color = "grey", alpha=0.2)+
  scale_x_reverse(limits = c(10,0))+
  xlab("shift, ppm")+
  ylab("intensity")+
  
  # labels:
  annotate("text", label = "aliphatic", x = 1.4, y = -0.1)+
  annotate("text", label = "O-alkyl", x = 3.5, y = -0.1)+
  annotate("text", label = "alpha-H", x = 4.45, y = -0.1)+
  annotate("text", label = "aromatic", x = 7, y = -0.1)+
  annotate("text", label = "amide", x = 8.1, y = -0.1)+
  annotate("text", label = "\n\nWATER", x = 3.5, y = Inf)+
  annotate("text", label = "\n\nDMSO", x = 2.48, y = Inf)+
  geom_vline(xintercept = WATER_start, linetype="longdash")+
  geom_vline(xintercept = WATER_stop, linetype="longdash")+
  geom_vline(xintercept = DMSO_start, linetype="dashed")+
  geom_vline(xintercept = DMSO_stop, linetype="dashed")+
  
  theme_classic() %+replace%
  theme(legend.position = "right",
        legend.key=element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size = 12),
        legend.key.size = unit(1.5, 'lines'),
        panel.border = element_rect(color="black",size=1.5, fill = NA),
        
        plot.title = element_text(hjust = 0.05, size = 14),
        axis.text = element_text(size = 14, color = "black"),
        axis.title = element_text(size = 14, face = "bold", color = "black"),
        
        # formatting for facets
        panel.background = element_blank(),
        strip.background = element_rect(colour="white", fill="white"), #facet formatting
        panel.spacing.x = unit(1.5, "lines"), #facet spacing for x axis
        panel.spacing.y = unit(1.5, "lines"), #facet spacing for x axis
        strip.text.x = element_text(size=12, face="bold"), #facet labels
        strip.text.y = element_text(size=12, face="bold", angle = 270) #facet labels
  )

#

## 2. spectra without bands (use for manuscripts) ----
gg_nmr2 =
  ggplot()+
  # stagger bracketing lines for odd vs. even rows  
  geom_rect(data=bins2 %>% dplyr::filter(row_number() %% 2 == 0), 
            aes(xmin=start, xmax=stop, ymin=2, ymax=2), color = "black")+
  geom_rect(data=bins2 %>% dplyr::filter(row_number() %% 2 == 1), 
            aes(xmin=start, xmax=stop, ymin=1.8, ymax=1.8), color = "black")+
  # stagger numbering like the lines
  geom_text(data=bins2 %>% dplyr::filter(row_number() %% 2 == 0), 
            aes(x = (start+stop)/2, y = 2.1, label = number))+
  geom_text(data=bins2 %>% dplyr::filter(row_number() %% 2 == 1), 
            aes(x = (start+stop)/2, y = 1.9, label = number))+
  scale_x_reverse(limits = c(10,0), breaks = seq(0,10,2))+
  xlab("shift, ppm")+
  ylab("intensity")+
  
  theme_classic() %+replace%
  theme(legend.position = "right",
        legend.key=element_blank(),
        legend.title = element_blank(),
        legend.text = element_text(size = 12),
        legend.key.size = unit(1.5, 'lines'),
        panel.border = element_rect(color="black",size=1.5, fill = NA),
        
        plot.title = element_text(hjust = 0.05, size = 14),
        axis.text = element_text(size = 14, color = "black"),
        axis.title = element_text(size = 14, face = "bold", color = "black"),
        
        # formatting for facets
        panel.background = element_blank(),
        strip.background = element_rect(colour="white", fill="white"), #facet formatting
        panel.spacing.x = unit(1.5, "lines"), #facet spacing for x axis
        panel.spacing.y = unit(1.5, "lines"), #facet spacing for x axis
        strip.text.x = element_text(size=12, face="bold"), #facet labels
        strip.text.y = element_text(size=12, face="bold", angle = 270) #facet labels
  )

