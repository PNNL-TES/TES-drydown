rm(list=ls())


library(ggplot2)
library(tidyr)
library(funrar)
library(data.table)
library(RColorBrewer)
library(GUniFrac)
library(vegan)
library(devtools)
library(microViz)
library(phyloseq)
library(dplyr)
library(pairwiseAdonis)
library(microbiome)
library(ape)
library(tidyverse)

###################
######Stacked Barplot
###################
###################

phyla = read.table("data/microbiome/taxtable2_transposed.txt", sep="\t", header=TRUE,row.names=1)

NAMES = rownames(phyla)
g_matrix = phyla[,9:67]
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(phyla)
g_sample = phyla[,1:8]
rownames(g_sample) = NAMES

############################
###########################
#####relative abundance normalization

g_rel = make_relative(g_matrix)
phyla_merged = merge(g_sample, g_rel, by="row.names")

#write.table(phyla_merged, "phyla_relative_abundance.txt",sep="\t")

### Create a stacked barplot at the Phylum level
phyla = read.table("data/microbiome/phyla_relative_abundance.txt", sep="\t", header=TRUE)
phyla_long = gather(phyla, phyla, counts, k__Archaea.p__Crenarchaeota:Other, factor_key=TRUE)


ggplot(phyla_long, aes(fill=phyla, y=counts,x=Sample))+
  geom_bar(position="fill",stat="identity")+
  theme_bw()+
  theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1))+
  ylab("Proportion")



##### Permanova analysis with time removed (since it has no drying factor)

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$length %in% c("30d","90d","150d"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES


g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))

pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

adonis(g_matrix~g_sample$Site+g_sample$depth+g_sample$saturation+g_sample$length+g_sample$drying,method="bray",permutations=999)

adonis(g_matrix~g_sample$Site*g_sample$depth*g_sample$saturation*g_sample$length*g_sample$drying,method="bray",permutations=999)

####PCoA 0-5cm, FAD, CPCRW

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "CPCRW", ]
species = species[species$drying %in% c("FAD",NA),]
species = species[species$depth %in% c("0-5cm"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)


####PCoA of 0-5cm, FAD, SR

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "SR", ]
species = species[species$drying %in% c("FAD",NA),]
species = species[species$depth %in% c("0-5cm"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)


### PCoA 0-5cm, CW, CPCRW

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "CPCRW", ]
species = species[species$drying %in% c("CW",NA),]
species = species[species$depth %in% c("0-5cm"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)


###PCoA of 0-5cm, CW, SR

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "SR", ]
species = species[species$drying %in% c("CW",NA),]
species = species[species$depth %in% c("0-5cm"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)

########Saturated only
###PCoA of 0-5cm, FAD, CPCRW, Saturated

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "CPCRW", ]
species = species[species$drying %in% c("FAD",NA),]
species = species[species$depth %in% c("0-5cm"),]
species = species[species$saturation %in% c("saturated","timezero"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)

####PCoA of 0-5cm, FAD, SR, saturated

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "SR", ]
species = species[species$drying %in% c("FAD",NA),]
species = species[species$depth %in% c("0-5cm"),]
species = species[species$saturation %in% c("saturated","timezero"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)


###PCoA of 0-5cm, CW, CPCRW, saturated

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "CPCRW", ]
species = species[species$drying %in% c("CW",NA),]
species = species[species$depth %in% c("0-5cm"),]
species = species[species$saturation %in% c("saturated","timezero"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)


####PCoA of 0-5cm, CW, SR, saturated

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "SR", ]
species = species[species$drying %in% c("CW",NA),]
species = species[species$depth %in% c("0-5cm"),]
species = species[species$saturation %in% c("saturated","timezero"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)



######Instant Chemistry only
### PCoA 0-5cm, FAD, CPCRW, Instant Chem

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "CPCRW", ]
species = species[species$drying %in% c("FAD",NA),]
species = species[species$depth %in% c("0-5cm"),]
species = species[species$saturation %in% c("instant chemistry","timezero"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)


###PCoA 0-5cm, FAD, SR, instant chem

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "SR", ]
species = species[species$drying %in% c("FAD",NA),]
species = species[species$depth %in% c("0-5cm"),]
species = species[species$saturation %in% c("instant chemistry","timezero"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)

####PCoA of 0-5cm, CW, CPCRW, instant chem

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "CPCRW", ]
species = species[species$drying %in% c("CW",NA),]
species = species[species$depth %in% c("0-5cm"),]
species = species[species$saturation %in% c("instant chemistry","timezero"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)


###PCoA of 0-5cm, CW, SR, instant chem

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)

species = species[species$Site %in% "SR", ]
species = species[species$drying %in% c("CW",NA),]
species = species[species$depth %in% c("0-5cm"),]
species = species[species$saturation %in% c("instant chemistry","timezero"),]

NAMES = rownames(species)
g_matrix = species[,9:1374]   
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)


NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

g_rel = make_relative(g_matrix)
#g_rel = na.omit(g_rel)

bray_distance = vegdist(g_rel, method="bray")
principal_coordinates = pcoa(bray_distance)
pcoa_plot = data.frame(principal_coordinates$vectors[,])
pcoa_plot_merged = merge(pcoa_plot,g_sample, by="row.names")

PC1 <- 100*(principal_coordinates$values$Eigenvalues[1]/sum(principal_coordinates$values$Eigenvalues))
PC2 <- 100*(principal_coordinates$values$Eigenvalues[2]/sum(principal_coordinates$values$Eigenvalues))
PC3 <- 100*(principal_coordinates$values$Eigenvalues[3]/sum(principal_coordinates$values$Eigenvalues))


pcoa_plot_merged$length = factor(pcoa_plot_merged$length, levels = c("timezero","30d","90d","150d"))

ggplot(data=pcoa_plot_merged,aes(x=Axis.1,y=-Axis.2)) + 
  geom_point(aes(fill=factor(length),shape=saturation), colour="black", size=6,alpha=0.6) + theme_bw()  +
  theme_bw(base_size=14) + 
  stat_ellipse(aes(color=length),type="norm")+
  theme(axis.text=element_text(size=14,color="black"),axis.title=element_text(size=14),legend.background = element_rect(colour = "black"),
        legend.text = element_text(size=18), legend.title=element_text(size=20)) + labs(fill = "Group")+theme(legend.title=element_blank())+
  labs(x = paste("PC1 - Variation Explained", round(PC1,2),"%"), y = paste("PC2 - Variation Explained", round(PC2,2),"%"))+
  scale_shape_manual(values=c(21,22,24)) + guides(fill=guide_legend(override.aes=list(shape=21)))

betadisper(bray_distance, g_sample$length,type=c("centroid"))

adonis(g_matrix~g_sample$length,method="bray",permutations=999)



##################Alpha diversity

species = read.table("data/microbiome/merged_taxtable7_transposed_lowSamplesRemoved.txt", sep="\t", header=TRUE,row.names=1)


NAMES = rownames(species)
g_matrix = species[,9:1374]
rownames(g_matrix) = NAMES
g_matrix = as.matrix(g_matrix)

NAMES = rownames(species)
g_sample = species[,1:8]
rownames(g_sample) = NAMES

rarefied = Rarefy(g_matrix, depth =3000)
rarefied_df = as.data.frame(rarefied[['otu.tab.rff']])
transposed_rarefied_df = t(rarefied_df)

shannon_diversity = diversity(transposed_rarefied_df,index="shannon")
richness = specnumber(rarefied_df)

shannon_diversity=as.data.frame(shannon_diversity)
shannon_merged = merge(g_sample, shannon_diversity, by="row.names")
shannon_merged$richness = richness

ggplot(shannon_merged, aes(x=depth,y=shannon))+
  geom_boxplot()+
  theme_bw()

t.test(shannon~depth, data=shannon_merged)


shannon_NA_drying = na.omit(shannon_merged,cols=drying)
ggplot(shannon_NA_drying, aes(x=drying,y=shannon))+
  geom_boxplot()+
  theme_bw()
  
t.test(shannon~drying,data=shannon_NA_drying)


ggplot(shannon_merged, aes(x=Site,y=shannon))+
  geom_boxplot()+
   theme_bw()

t.test(shannon~Site,data=shannon_merged)

shannon_merged$length = as.character(shannon_merged$length)
shannon_merged$length = factor(shannon_merged$length, levels=c("timezero","30d","90d","150d"))

ggplot(shannon_merged, aes(x=length,y=shannon))+
  geom_boxplot()+
  theme_bw()

species_anova = aov(shannon~length,data=shannon_merged)
summary(species_anova)
TukeyHSD(species_anova)


ggplot(shannon_merged, aes(x=saturation,y=shannon))+
  geom_boxplot()+
  theme_bw()

species_anova = aov(shannon~saturation,data=shannon_merged)
summary(species_anova)
TukeyHSD(species_anova)


ggplot(shannon_merged, aes(x=Site,y=shannon))+
  geom_boxplot()+
  theme_bw()

species_anova = aov(shannon~Site,data=shannon_merged)
summary(species_anova)
TukeyHSD(species_anova)


######Richness


ggplot(shannon_merged,aes(x=depth,y=richness))+
  geom_boxplot()+
  theme_bw()
t.test(richness~depth,data=shannon_merged)


ggplot(shannon_merged,aes(x=Site,y=richness))+
  geom_boxplot()+
  theme_bw()
t.test(richness~Site,data=shannon_merged)

shannon_merged$length = as.character(shannon_merged$length)
shannon_merged$length = factor(shannon_merged$length, levels=c("timezero","30d","90d","150d"))


ggplot(shannon_merged,aes(x=length,y=richness))+
  geom_boxplot()+
  theme_bw()

species_anova = aov(richness~length,data=shannon_merged)
summary(species_anova)
TukeyHSD(species_anova)


ggplot(shannon_merged,aes(x=Site,y=richness))+
  geom_boxplot()+
  theme_bw()
t.test(richness~Site,data=shannon_merged)


shannon_NA_drying = na.omit(shannon_merged,cols=drying)
ggplot(shannon_NA_drying,aes(x=drying,y=richness))+
  geom_boxplot()+
  theme_bw()
t.test(shannon~drying,data=shannon_NA_drying)


ggplot(shannon_merged,aes(x=saturation,y=richness))+
  geom_boxplot()+
  facet_wrap(~Site)+
  theme_bw()

species_anova = aov(richness~saturation,data=shannon_merged)
summary(species_anova)
TukeyHSD(species_anova)

#write.table(shannon_merged, "shannon_diversity.txt",sep="\t")
#write.table(richness_merged, "richness.txt",sep="\t")

###########################
###########################
##########################
###Phyloseq analysis
rm(list=ls())


OTU = read.table("data/microbiome/OTU_table.txt", sep="\t", header=TRUE,row.names=1)
taxa = read.table("data/microbiome/Tax_table.txt", sep="\t", header=TRUE,row.names=1)
metadata = read.table("data/microbiome/heatmap_order_metadata.txt", sep="\t", header=TRUE,row.names=1)


OTU_mat = as.matrix(OTU)
tax_mat = as.matrix(taxa)

OTU = otu_table(OTU_mat, taxa_are_rows=TRUE)
TAX = tax_table(tax_mat)
samples = sample_data(metadata)

combined = phyloseq(OTU,TAX,samples)
sample_names(combined)



combined = transform_sample_counts(combined, function(x) x/sum(x))

OTU1 = as(otu_table(combined),"matrix")
#tax_fix_interactive(combined)

combined_fixed = tax_fix(combined,min_length=4,unknowns=NA,sep="_",anon_unique=TRUE,suffix_rank="classified")
combined_agg = tax_agg(combined_fixed,rank="Phylum")

combined_fixed


combined_fixed_rel = transform_sample_counts(combined_fixed, function(x) x/sum(x))

ord1 = combined_fixed_rel %>%
  tax_agg("Species") %>%
  tax_transform("identity", rank="Species") %>%
  dist_calc("bray") %>%
  ord_calc()

ord_explore(data=ord1, auto_caption=NA)


#####Heatmap
OTU = read.table("data/microbiome/OTU_table.txt", sep="\t", header=TRUE,row.names=1)
taxa = read.table("data/microbiome/Tax_table.txt", sep="\t", header=TRUE,row.names=1)
metadata = read.table("data/microbiome/heatmap_order_metadata.txt", sep="\t", header=TRUE,row.names=1)


OTU_mat = as.matrix(OTU)
tax_mat = as.matrix(taxa)

OTU = otu_table(OTU_mat, taxa_are_rows=TRUE)
TAX = tax_table(tax_mat)
samples = sample_data(metadata)

combined = phyloseq(OTU,TAX,samples)
sample_names(combined)



combined = transform_sample_counts(combined, function(x) x/sum(x))



combined = subset_samples(combined, Site=="CPCRW")
#combined = subset_taxa(combined, OTU==c("OTU0040",	"OTU0062",	"OTU0264",	"OTU0717",	"OTU0826",	"OTU0844",	"OTU1087",	"OTU1156",	"OTU1253",	"OTU1255",	"OTU0089",	"OTU0163",	"OTU1109",	"OTU1145",	"OTU1148",	"OTU0345",	"OTU0962",	"OTU0981",	"OTU1184",	"OTU0559",	"OTU1144",	"OTU0705",	"OTU0947",	"OTU1167",	"OTU0267",	"OTU0509",	"OTU0931",	"OTU0989",	"OTU0055",	"OTU0816",	"OTU0123",	"OTU0126",	"OTU0813",	"OTU0832",	"OTU0861",	"OTU1170",	"OTU1187",	"OTU0506",	"OTU0507",	"OTU0508",	"OTU0568",	"OTU0991",	"OTU1134",	"OTU0221",	"OTU0084",	"OTU0440",	"OTU0101",	"OTU0252",	"OTU0870",	"OTU1055",	"OTU0966",	"OTU1190",	"OTU0228",	"OTU0370",	"OTU0839",	"OTU0773",	"OTU0316",	"OTU0924",	"OTU0169",	"OTU0343",	"OTU0960",	"OTU0781",	"OTU0894",	"OTU0057",	"OTU0450",	"OTU0041",	"OTU0364"))
top_10_taxa = c("OTU0040",	"OTU0062",	"OTU0264",	"OTU0717",	"OTU0826",	"OTU0844",	"OTU1087",	"OTU1156",	"OTU1253",	"OTU1255",	"OTU0089",	"OTU0163",	"OTU1109",	"OTU1145",	"OTU1148",	"OTU0345",	"OTU0962",	"OTU0981",	"OTU1184",	"OTU0559",	"OTU1144",	"OTU0705",	"OTU0947",	"OTU1167",	"OTU0267",	"OTU0509",	"OTU0931",	"OTU0989",	"OTU0055",	"OTU0816",	"OTU0123",	"OTU0126",	"OTU0813",	"OTU0832",	"OTU0861",	"OTU1170",	"OTU1187",	"OTU0506",	"OTU0507",	"OTU0508",	"OTU0568",	"OTU0991",	"OTU1134",	"OTU0221",	"OTU0084",	"OTU0440",	"OTU0101",	"OTU0252",	"OTU0870",	"OTU1055",	"OTU0966",	"OTU1190",	"OTU0228",	"OTU0370",	"OTU0839",	"OTU0773",	"OTU0316",	"OTU0924",	"OTU0169",	"OTU0343",	"OTU0960",	"OTU0781",	"OTU0894",	"OTU0057",	"OTU0450",	"OTU0041",	"OTU0364")
top_10 = prune_taxa(top_10_taxa, combined)
ntaxa(top_10)
tax_table(top_10)

order_of_samples = c("DOC_180",	"DOC_015",	"DOC_019",	"DOC_021",	"DOC_025",	"DOC_026",	"DOC_027",	"DOC_031",	"DOC_032",	"DOC_033",	"DOC_001",	"DOC_002",	"DOC_003",	"DOC_008",	"DOC_009",	"DOC_181",	"DOC_183",	"DOC_184",	"DOC_055",	"DOC_056",	"DOC_057",	"DOC_061",	"DOC_062",	"DOC_067",	"DOC_068",	"DOC_069",	"DOC_037",	"DOC_038",	"DOC_039",	"DOC_043",	"DOC_044",	"DOC_045",	"DOC_022",	"DOC_023",	"DOC_024",	"DOC_029",	"DOC_034",	"DOC_035",	"DOC_036",	"DOC_004",	"DOC_006",	"DOC_010",	"DOC_011",	"DOC_012",	"DOC_058",	"DOC_059",	"DOC_060",	"DOC_064",	"DOC_065",	"DOC_070",	"DOC_071",	"DOC_072",	"DOC_046",	"DOC_047",	"DOC_048",	"DOC_141",	"DOC_142",	"DOC_143",	"DOC_148",	"DOC_144",	"DOC_145",	"DOC_152")
taxa_order = c("OTU0364",	"OTU0041",	"OTU0450",	"OTU0057",	"OTU0894",	"OTU0781",	"OTU0960",	"OTU0343",	"OTU0169",	"OTU0924",	"OTU0316",	"OTU0773",	"OTU0839",	"OTU0370",	"OTU0228",	"OTU1190",	"OTU0966",	"OTU1055",	"OTU0870",	"OTU0252",	"OTU0101",	"OTU0440",	"OTU0084",	"OTU0221",	"OTU1134",	"OTU0991",	"OTU0568",	"OTU0508",	"OTU0507",	"OTU0506",	"OTU1187",	"OTU1170",	"OTU0861",	"OTU0832",	"OTU0813",	"OTU0126",	"OTU0123",	"OTU0816",	"OTU0055",	"OTU0989",	"OTU0931",	"OTU0509",	"OTU0267",	"OTU1167",	"OTU0947",	"OTU0705",	"OTU1144",	"OTU0559",	"OTU1184",	"OTU0981",	"OTU0962",	"OTU0345",	"OTU1148",	"OTU1145",	"OTU1109",	"OTU0163",	"OTU0089",	"OTU1255",	"OTU1253",	"OTU1156",	"OTU1087",	"OTU0844",	"OTU0826",	"OTU0717",	"OTU0264",	"OTU0062",	"OTU0040")

plot_heatmap(top_10, sample.label="sample_order",sample.order=order_of_samples,taxa.order=taxa_order)

(p = plot_heatmap(combined, "NMDS","bray","Site","Family"))

####SR heatmap

OTU = read.table("data/microbiome/OTU_table.txt", sep="\t", header=TRUE,row.names=1)
taxa = read.table("data/microbiome/Tax_table.txt", sep="\t", header=TRUE,row.names=1)
metadata = read.table("data/microbiome/heatmap_order_metadata.txt", sep="\t", header=TRUE,row.names=1)


OTU_mat = as.matrix(OTU)
tax_mat = as.matrix(taxa)

OTU = otu_table(OTU_mat, taxa_are_rows=TRUE)
TAX = tax_table(tax_mat)
samples = sample_data(metadata)

combined = phyloseq(OTU,TAX,samples)
sample_names(combined)



combined = transform_sample_counts(combined, function(x) x/sum(x))

combined = subset_samples(combined, Site=="SR")

top_10_taxa = c("OTU0040",	"OTU0062",	"OTU0264",	"OTU0717",	"OTU0826",	"OTU0844",	"OTU1087",	"OTU1156",	"OTU1253",	"OTU1255",	"OTU0089",	"OTU0163",	"OTU1109",	"OTU1145",	"OTU1148",	"OTU0345",	"OTU0962",	"OTU0981",	"OTU1184",	"OTU0559",	"OTU1144",	"OTU0705",	"OTU0947",	"OTU1167",	"OTU0267",	"OTU0509",	"OTU0931",	"OTU0989",	"OTU0055",	"OTU0816",	"OTU0123",	"OTU0126",	"OTU0813",	"OTU0832",	"OTU0861",	"OTU1170",	"OTU1187",	"OTU0506",	"OTU0507",	"OTU0508",	"OTU0568",	"OTU0991",	"OTU1134",	"OTU0221",	"OTU0084",	"OTU0440",	"OTU0101",	"OTU0252",	"OTU0870",	"OTU1055",	"OTU0966",	"OTU1190",	"OTU0228",	"OTU0370",	"OTU0839",	"OTU0773",	"OTU0316",	"OTU0924",	"OTU0169",	"OTU0343",	"OTU0960",	"OTU0781",	"OTU0894",	"OTU0057",	"OTU0450",	"OTU0041",	"OTU0364")
top_10 = prune_taxa(top_10_taxa, combined)
ntaxa(top_10)
tax_table(top_10)

order_of_samples = c("DOC_185",	"DOC_186",	"DOC_187",	"DOC_084",	"DOC_085",	"DOC_086",	"DOC_090",	"DOC_091",	"DOC_092",	"DOC_095",	"DOC_096",	"DOC_097",	"DOC_101",	"DOC_073",	"DOC_074",	"DOC_075",	"DOC_079",	"DOC_080",	"DOC_081",	"DOC_188",	"DOC_189",	"DOC_190",	"DOC_118",	"DOC_119",	"DOC_120",	"DOC_124",	"DOC_125",	"DOC_126",	"DOC_129",	"DOC_130",	"DOC_136",	"DOC_137",	"DOC_135",	"DOC_107",	"DOC_108",	"DOC_109",	"DOC_113",	"DOC_114",	"DOC_115",	"DOC_087",	"DOC_088",	"DOC_089",	"DOC_093",	"DOC_094",	"DOC_098",	"DOC_100",	"DOC_104",	"DOC_105",	"DOC_106",	"DOC_076",	"DOC_077",	"DOC_078",	"DOC_082",	"DOC_083",	"DOC_121",	"DOC_123",	"DOC_127",	"DOC_128",	"DOC_132",	"DOC_133",	"DOC_134",	"DOC_138",	"DOC_139",	"DOC_140",	"DOC_110",	"DOC_111",	"DOC_116",	"DOC_117",	"DOC_153",	"DOC_154",	"DOC_155",	"DOC_159",	"DOC_160",	"DOC_165",	"DOC_166",	"DOC_167",	"DOC_172",	"DOC_173",	"DOC_156",	"DOC_157",	"DOC_158",	"DOC_163",	"DOC_164",	"DOC_168",	"DOC_169",	"DOC_170",	"DOC_175",	"DOC_176")
taxa_order = c("OTU0364",	"OTU0041",	"OTU0450",	"OTU0057",	"OTU0894",	"OTU0781",	"OTU0960",	"OTU0343",	"OTU0169",	"OTU0924",	"OTU0316",	"OTU0773",	"OTU0839",	"OTU0370",	"OTU0228",	"OTU1190",	"OTU0966",	"OTU1055",	"OTU0870",	"OTU0252",	"OTU0101",	"OTU0440",	"OTU0084",	"OTU0221",	"OTU1134",	"OTU0991",	"OTU0568",	"OTU0508",	"OTU0507",	"OTU0506",	"OTU1187",	"OTU1170",	"OTU0861",	"OTU0832",	"OTU0813",	"OTU0126",	"OTU0123",	"OTU0816",	"OTU0055",	"OTU0989",	"OTU0931",	"OTU0509",	"OTU0267",	"OTU1167",	"OTU0947",	"OTU0705",	"OTU1144",	"OTU0559",	"OTU1184",	"OTU0981",	"OTU0962",	"OTU0345",	"OTU1148",	"OTU1145",	"OTU1109",	"OTU0163",	"OTU0089",	"OTU1255",	"OTU1253",	"OTU1156",	"OTU1087",	"OTU0844",	"OTU0826",	"OTU0717",	"OTU0264",	"OTU0062",	"OTU0040")

combined = transform(combined,transform="log10")

plot_heatmap(top_10, sample.label="sample_order",sample.order=order_of_samples,taxa.order=taxa_order)

(p = plot_heatmap(combined, "NMDS","bray","Site","Family"))




