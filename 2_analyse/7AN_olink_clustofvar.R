################################################################################

## Cluster analysis

## resources
# https://bio723-class.github.io/Bio723-book/clustering-in-r.html
# https://hal.science/hal-00742795/document 

################################################################################

library(ClustOfVar)
library(haven)
library(dendextend)
library(ggplot2)
library(data.table)
library(dplyr)
library(tidyverse)
library(gplots)

## remove all objects
rm(list = ls(all.names = TRUE))

## load data
coredata <- read_dta("C:/Users/wangs/OneDrive - IARC/Projects_IARC/Proj_PROEC/2_deriveddata/PROEC_coredata_olk75.dta")
names(coredata)

## subset olk vars
olk_columns <- grep("^olk_", names(coredata), value = TRUE)
olkmat <- coredata[, olk_columns]
# for proteins measured twice, use the one with the measurement below lod
olkmat <- olkmat[, !colnames(olkmat) %in% c("olk_il6_ir", "olk_il10_ir", "olk_ccl11_ir")]
# Convert df to matrix
olkmat <- as.matrix(olkmat)

## h clustering
tree <- hclustvar(olkmat)
plot(tree, cex=0.5)
# plot and examine tree
tree_dend <- as.dendrogram(tree)
nleaves(tree_dend)  # number of leaves in tree
nnodes(tree_dend)  # number of nodes (=leaves + joins) in tree
plot(tree_dend)

## cut tree into clusters
# k = number of clusters
# h = cut tree by height
clusters <- cutree(tree_dend, h=0.8)
table(clusters)
plot(color_branches(tree_dend, h=0.8)) 
# h=0.8 derived k=44 clusters
clusters <- cutree(tree_dend, k=44)
table(clusters)
plot(color_branches(tree_dend, k=44))

## save dendrogram
pdf("C:/Users/wangs/OneDrive - IARC/Projects_IARC/Proj_PROEC/5_outputs/cluster_dendrogram.pdf",
    width = 20, height = 30, pointsize = 30)
tree_dend %>% set("labels_cex", 0.4) %>% color_branches(h=0.8) %>% plot(horiz = TRUE) + theme(plot.margin = margin(0, 200, 0, 0))
dev.off()
# examine clusters in df
clusters.df <- data.frame(protein = names(clusters), cluster = clusters)
names(clusters.df)

################################################################################

## gen PCA for each cluster
part_init<-cutreevar(tree,44)$cluster 
part2<-kmeansvar(olkmat,init=part_init,matsim=TRUE)
summary(part2)

## save squared loading and correlation data 
table_cluster <- data.frame(part2$cluster)
table_cluster$proteins <- rownames(table_cluster)

my_list <- part2$var
for (i in seq_along(my_list)) {
  my_list[[i]] <- data.frame(my_list[[i]])
}
adjusted_list <- lapply(my_list, function(df) {
  if (nrow(df) == 2 && ncol(df) == 1) {
    return(data.frame(t(df)))
  } else {
    return(df)
  }
})
table_corr <- bind_rows(adjusted_list)
table_corr$proteins <- rownames(table_corr)

merged_df <- merge(table_cluster, table_corr, by = "proteins", all = TRUE)
merged_df$squared.loading <- ifelse(is.na(merged_df$squared.loading), 1, merged_df$squared.loading)
merged_df$correlation <- ifelse(is.na(merged_df$correlation), 1, merged_df$correlation)
olk_columns <- grep("^olk_", merged_df$proteins, value = TRUE)
table_master <- merged_df[grepl("^olk_", merged_df$proteins), ]

## calculate the average corr in each cluster
table_master <- table_master %>%
  group_by(part2.cluster) %>%
  mutate(avg_corr_cluster = mean(correlation, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(avg_corr_overall = mean(abs(correlation), na.rm = TRUE))

## Export table
setwd("C:/Users/wangs/OneDrive - IARC/Projects_IARC/Proj_PROEC/5_outputs")
write.table(table_master, "tab_clustervars.xlsx", row.names=FALSE)

## Export PCA score
pcascore <- data.frame(part2[["scores"]])
# combine to main dataframe
coredata_pca <- cbind(coredata, pcascore)
# Export as csv
setwd("C:/Users/wangs/OneDrive - IARC/Projects_IARC/Proj_PROEC/2_deriveddata")
write.csv(coredata_pca, "coredata_clusterpca.csv", row.names=FALSE)
