

# -------------------------------------------------------------------------


data2 = report1 %>% 
  dplyr::filter(!C13==1)%>% dplyr::select(1,16) %>% 
  rename(sample = Fansler_51618_DOC007_Alder_Inf_02Oct2020_300SA_IATp1_1_01_55586) %>% 
  mutate(sample = if_else(sample > 0, 1, 0))

data3 = 
  data2 %>% 
  column_to_rownames("Mass") %>% 
  cbind(data2) %>% 
  dplyr::select(-1)

data3_gather = data3 %>% 
  gather("sample2", "value", -1) %>% 
  filter(value > 0) %>% 
  dplyr::select(sample2, Mass)

data3_gather2 = 
  data3_gather %>% 
  left_join(data3_gather, by = "sample2")
  
%>% gather("sample", "value", -1) %>% filter(value > 0) %>% dplyr::select(sample, peak)


fticr_data_water_summarized %>%
  left_join(fticr_meta_water %>% 
              dplyr::select(formula, NOSC, HC, OC, Class)) %>%
  mutate(Material = factor (Material, levels = c("Organic", "Upper Mineral", "Lower Mineral")))



combined_transformations %>% 
  group_by(sample) %>% 
  dplyr::summarise(n = n())



# -------------------------------------------------------------------------

fticr_meta_elements = 
  fticr_meta %>% 
  mutate(N_temp = str_extract(formula, "N[0-9]"),
         N = parse_number(N_temp)) %>% 
  replace(is.na(.), 0)

fticr_meta_elements %>% 
  gg_vankrev(aes(x = OC, y = HC, color = as.character(N)))+
  scale_color_manual(values = pnw_palette("Sunset2", 6))+
  theme_minimal()+
  NULL


fticr_meta_elements %>% 
  gg_vankrev(aes(x = OC, y = HC, color = DBE))+
  scale_color_gradientn(colors = pnw_palette("Sunset2", 6))+
  theme_minimal()+
  NULL


fticr_meta_elements %>% 
  gg_vankrev(aes(x = OC, y = HC, color = Class_detailed))+
  scale_color_manual(values = pnw_palette("Sunset2", 8))+
  theme_minimal()+
  NULL



# -------------------------------------------------------------------------

ggbiplot(pca_cpcrw_top$pca_int, obs.scale = 1, var.scale = 1,
         groups = as.character(pca_cpcrw_top$grp$length), 
         ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
  geom_point(size=4,stroke=1, 
             aes(shape = interaction(pca_cpcrw_top$grp$drying),
                 fill = groups, color = groups,))+
  scale_shape_manual(values = c(1, 16, 17), name = "")+
  #scale_color_manual(values = c("red", "blue"), name = "")+
  #scale_fill_manual(values = c("red", "blue"), name = "")+
  xlim(-4,4)+
  ylim(-3.5,3.5)+
  labs(shape="",
       title = "CPCRW, 0-5cm")+
  theme_kp()+
  theme(legend.position = "right")+
  NULL


ggbiplot(pca_cpcrw_bottom$pca_int, obs.scale = 1, var.scale = 1,
         groups = as.character(pca_cpcrw_bottom$grp$length), 
         ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
  geom_point(size=4,stroke=1, 
             aes(shape = interaction(pca_cpcrw_bottom$grp$drying),
                 fill = groups, color = groups,))+
  scale_shape_manual(values = c(1, 16, 17), name = "")+
  #scale_color_manual(values = c("red", "blue"), name = "")+
  #scale_fill_manual(values = c("red", "blue"), name = "")+
  xlim(-4,4)+
  ylim(-3.5,3.5)+
  labs(shape="",
       title = "CPCRW, 5cm-end")+
  theme_kp()+
  theme(legend.position = "right")+
  NULL


ggbiplot(pca_sr_top$pca_int, obs.scale = 1, var.scale = 1,
         groups = as.character(pca_sr_top$grp$length), 
         ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
  geom_point(size=4,stroke=1, 
             aes(shape = interaction(pca_sr_top$grp$drying, pca_sr_bottom$grp$saturation),
                 fill = groups, color = groups,))+
  #scale_shape_manual(values = c(1, 16, 17), name = "")+
  #scale_color_manual(values = c("red", "blue"), name = "")+
  #scale_fill_manual(values = c("red", "blue"), name = "")+
  xlim(-4,4)+
  ylim(-3.5,3.5)+
  labs(shape="",
       title = "SR, 0-5cm")+
  theme_kp()+
  theme(legend.position = "right")+
  NULL


ggbiplot(pca_sr_bottom$pca_int, obs.scale = 1, var.scale = 1,
         groups = as.character(pca_sr_bottom$grp$length), 
         ellipse = TRUE, circle = FALSE, var.axes = TRUE) +
  geom_point(size=4,stroke=1, 
             aes(shape = interaction(pca_sr_bottom$grp$drying, pca_sr_bottom$grp$saturation),
                 fill = groups, color = groups,))+
  #scale_shape_manual(values = c(1, 16, 17), name = "")+
  #scale_color_manual(values = c("red", "blue"), name = "")+
  #scale_fill_manual(values = c("red", "blue"), name = "")+
  xlim(-4,4)+
  ylim(-3.5,3.5)+
  labs(shape="",
       title = "SR, 5cm-end")+
  theme_kp()+
  theme(legend.position = "right")+
  NULL




relabund_cores = 
  relabund_cores %>% 
  ungroup() %>% 
  left_join(dplyr::select(dockey, coreID, location), by = c("CoreID" = "coreID")) %>% 
  distinct()


###############
##############

# -------------------------------------------------------------------------


# advanced stats ----------------------------------------------------------

# variance partitioning -----------------------------------------------------
# https://www.rdocumentation.org/packages/vegan/versions/2.4-2/topics/varpart
data(mite)
data(mite.env)
data(mite.pcnm)

# Two explanatory matrices -- Hellinger-transform Y
# Formula shortcut "~ ." means: use all variables in 'data'.
mod <- varpart(mite, ~ ., mite.pcnm, data=mite.env, transfo="hel")
mod

## Use fill colours
showvarparts(2, bg = c("hotpink","skyblue"))
plot(mod, bg = c("hotpink","skyblue"))
# Alternative way of to conduct this partitioning
# Change the data frame with factors into numeric model matrix
mm <- model.matrix(~ SubsDens + WatrCont + Substrate + Shrub + Topo, mite.env)[,-1]
mod <- varpart(decostand(mite, "hel"), mm, mite.pcnm)
# Test fraction [a] using partial RDA:
aFrac <- rda(decostand(mite, "hel"), mm, mite.pcnm)
anova(aFrac, step=200, perm.max=200)
# RsquareAdj gives the same result as component [a] of varpart
RsquareAdj(aFrac)

# Partition Bray-Curtis dissimilarities
varpart(vegdist(mite), ~ ., mite.pcnm, data = mite.env)
# Three explanatory matrices 
mod <- varpart(mite, ~ SubsDens + WatrCont, ~ Substrate + Shrub + Topo,
               mite.pcnm, data=mite.env, transfo="hel")
mod
showvarparts(3, bg=2:4)
plot(mod, bg=2:4)
# An alternative formulation of the previous model using
# matrices mm1 amd mm2 and Hellinger transformed species data
mm1 <- model.matrix(~ SubsDens + WatrCont, mite.env)[,-1]
mm2 <- model.matrix(~ Substrate + Shrub + Topo, mite.env)[, -1]
mite.hel <- decostand(mite, "hel")
mod <- varpart(mite.hel, mm1, mm2, mite.pcnm)
# Use RDA to test fraction [a]
# Matrix can be an argument in formula
rda.result <- rda(mite.hel ~ mm1 + Condition(mm2) +
                    Condition(as.matrix(mite.pcnm)))
anova(rda.result, step=200, perm.max=200)

# Four explanatory tables
mod <- varpart(mite, ~ SubsDens + WatrCont, ~Substrate + Shrub + Topo,
               mite.pcnm[,1:11], mite.pcnm[,12:22], data=mite.env, transfo="hel")
mod
plot(mod, bg=2:5)
# Show values for all partitions by putting 'cutoff' low enough:
plot(mod, cutoff = -Inf, cex = 0.7, bg=2:5)


# variance partitioning relabund -----------------------------------------------------
# https://www.rdocumentation.org/packages/vegan/versions/2.4-2/topics/varpart

loadd(relabund_cores)
relabund_wide = 
  relabund_cores %>% 
  dplyr::select(-c(abund, total)) %>% 
  pivot_wider(names_from = "Class", values_from = "relabund") %>% 
  dplyr::select(-other) %>% 
  #  mutate(assignment = paste(Site, depth, length, drying, saturation, CoreID, sep = "_")) %>%
  #  column_to_rownames(., var = "assignment") %>% 
  force()

relabund_wide2 = 
  relabund_wide %>% 
  ungroup() %>% 
  dplyr::select(-c(CoreID:saturation))

relabund_wide_grp = 
  relabund_wide %>% 
  ungroup() %>% 
  dplyr::select(c(Site:saturation))

dist = vegdist(relabund_wide2)
rel.pcnm = pcnm(dist)$vectors %>% as.data.frame()

##    # Two explanatory matrices -- Hellinger-transform Y
##    # Formula shortcut "~ ." means: use all variables in 'data'.
##    mod <- varpart(mite, ~ ., mite.pcnm, data=mite.env, transfo="hel")
##    mod
##    
##    ## Use fill colours
##    showvarparts(2, bg = c("hotpink","skyblue"))
##    plot(mod, bg = c("hotpink","skyblue"))
##    # Alternative way of to conduct this partitioning
##    # Change the data frame with factors into numeric model matrix
##    mm <- model.matrix(~ SubsDens + WatrCont + Substrate + Shrub + Topo, mite.env)[,-1]
##    mod <- varpart(decostand(mite, "hel"), mm, mite.pcnm)
##    # Test fraction [a] using partial RDA:
##    aFrac <- rda(decostand(mite, "hel"), mm, mite.pcnm)
##    anova(aFrac, step=200, perm.max=200)
##    # RsquareAdj gives the same result as component [a] of varpart
##    RsquareAdj(aFrac)
##    
##    # Partition Bray-Curtis dissimilarities
##    varpart(vegdist(mite), ~ ., mite.pcnm, data = mite.env)
##    # Three explanatory matrices 
##    mod <- varpart(mite, ~ SubsDens + WatrCont, ~ Substrate + Shrub + Topo,
##                   mite.pcnm, data=mite.env, transfo="hel")
##    mod
##    showvarparts(3, bg=2:4)
##    plot(mod, bg=2:4)
##    # An alternative formulation of the previous model using
##    # matrices mm1 amd mm2 and Hellinger transformed species data
##    mm1 <- model.matrix(~ SubsDens + WatrCont, mite.env)[,-1]
##    mm2 <- model.matrix(~ Substrate + Shrub + Topo, mite.env)[, -1]
##    mite.hel <- decostand(mite, "hel")
##    mod <- varpart(mite.hel, mm1, mm2, mite.pcnm)
##    # Use RDA to test fraction [a]
##    # Matrix can be an argument in formula
##    rda.result <- rda(mite.hel ~ mm1 + Condition(mm2) +
##                        Condition(as.matrix(mite.pcnm)))
##    anova(rda.result, step=200, perm.max=200)
##    
# Four explanatory tables
mod <- varpart(relabund_wide2, ~ Site, ~length, ~saturation, ~drying,
               data=relabund_wide_grp, transfo = "hel")
mod
plot(mod, bg=2:5)
# Show values for all partitions by putting 'cutoff' low enough:
plot(mod, cutoff = -Inf, cex = 0.7, bg=2:5)

# cluster -----------------------------------------------------------------

data(wine, package='rattle')
head(wine)

wine.stand <- scale(wine[-1])  # To standarize the variables

# K-Means
k.means.fit <- kmeans(wine.stand, 3) # k = 3

attributes(k.means.fit)
k.means.fit$centers
k.means.fit$cluster
k.means.fit$size

wssplot <- function(data, nc=15, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}

wssplot(wine.stand, nc=6) 

library(cluster)
clusplot(wine.stand, k.means.fit$cluster, main='2D representation of the Cluster solution',
         color=TRUE, shade=TRUE,
         labels=2, lines=0)
table(wine[,1],k.means.fit$cluster)

d <- dist(wine.stand, method = "euclidean") # Euclidean distance matrix.
H.fit <- hclust(d, method="ward")

plot(H.fit) # display dendogram
groups <- cutree(H.fit, k=3) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters
rect.hclust(H.fit, k=3, border="red") 


# cluster relabund -------------------------------------------------------------------------

loadd(relabund_cores)
relabund_wide = 
  relabund_cores %>% 
  dplyr::select(-c(abund, total)) %>% 
  pivot_wider(names_from = "Class", values_from = "relabund") %>% 
  dplyr::select(-other) %>% 
  mutate(assignment = paste(Site, depth, length, drying, saturation, CoreID, sep = "_")) %>%
  column_to_rownames(., var = "assignment")

relabund_wide2 = 
  relabund_wide %>% 
  ungroup() %>% 
  dplyr::select(-c(CoreID:saturation))

dd_2 = dist(relabund_wide2, method = "euclidean")
hc_2 <- hclust(dd_2, method = "ward.D2")
plot(hc_2)


hcd <- as.dendrogram(hc_2)

plot(hcd, ylim = c(1, 30), xlim = c(0,100), horiz = TRUE)

plot(as.phylo(hc_2), type = "fan")
colors = c("red", "blue", "green", "black")
clus4 = cutree(hc, 4)
plot(as.phylo(hc_2), type = "fan", tip.color = colors[clus4],
     label.offset = 1, cex = 0.7)



k.means.fit <- kmeans(relabund_wide2, 3) # k = 3

attributes(k.means.fit)
k.means.fit$centers
k.means.fit$cluster
k.means.fit$size

wssplot <- function(data, nc=15, seed=1234){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")}

wssplot(relabund_wide2, nc=6) 

library(cluster)
clusplot(relabund_wide2, k.means.fit$cluster, main='2D representation of the Cluster solution',
         color=TRUE, shade=TRUE,
         labels=2, lines=0)
table(relabund_wide[,1],k.means.fit$cluster)

d <- dist(relabund_wide2, method = "euclidean") # Euclidean distance matrix.
H.fit <- hclust(d, method="ward")

plot(H.fit) # display dendogram
groups <- cutree(H.fit, k=5) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters
rect.hclust(H.fit, k=2, border="red")



# ggdendrogram ------------------------------------------------------------
# http://www.sthda.com/english/wiki/beautiful-dendrogram-visualizations-in-r-5-must-known-methods-unsupervised-machine-learning
library(ggdendro)
ggdendrogram(hc_2)

# Build dendrogram object from hclust results
dend <- as.dendrogram(hc_2)
# Extract the data (for rectangular lines)
# Type can be "rectangle" or "triangle"
dend_data <- dendro_data(dend, type = "rectangle")
# What contains dend_data
names(dend_data)


dend_data$labels = 
  dend_data$labels %>%
  mutate(label2 = label) %>% 
  separate(label2, sep = "_", into = c("site", "depth", "length", "drying", "saturation", "CoreID"))


ggplot(dend_data$segments) + 
  geom_segment(aes(x = x, y = y, xend = xend, yend = yend))+
  geom_text(data = dend_data$labels, aes(x, y, label = label, color = saturation),
            hjust = 1, angle = 90, size = 3)+
  ylim(-3, 15)

