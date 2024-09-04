#Combined

options(repos = c(CRAN = "https://cran.rstudio.com/"))

output_dir <- "/Users/elifsuep/Desktop/DSGELAB/Mother_targettrait/hierarchical"
dir.create(output_dir, showWarnings = FALSE)

output_file <- file.path(output_dir, "output_log.txt")
output_conn <- file(output_file, open = "wt")

current_path <- getwd()
cat("Current working directory:", current_path, "\n", file = output_file)

install_if_missing <- function(packages) {
  for (package in packages) {
    if (!require(package, character.only = TRUE)) {
      install.packages(package, dependencies = TRUE)
      library(package, character.only = TRUE)
    }
  }
}


install_if_missing(c("data.table", "ggplot2", "NbClust", "dplyr", "ggdendro"))

sink(output_conn)
sink(output_conn, type = "message")

data <- fread("/Users/elifsuep/Desktop/DSGELAB/AllFam.Res_Stand", sep = "\t")

unique_disease <- unique(data$TargetTrait)
filtered_data_list <- list()
feat_data_list <- list()

for (TargetTrait in unique_disease) {
  filtered_data <- subset(data, RelationType == "Mother" & TargetTrait == TargetTrait)
  filtered_data_list[[TargetTrait]] <- filtered_data
  feat_data <- data.frame(FeatCoeff = filtered_data$FeatCoeff, FeatP = filtered_data$FeatP)
  feat_data_list[[TargetTrait]] <- feat_data
}

for (TargetTrait in unique_disease) {
  assign(paste0("filtered_data_", TargetTrait), filtered_data_list[[TargetTrait]])
  assign(paste0("feat_data_", TargetTrait), feat_data_list[[TargetTrait]])
}

max_clusters <- 10
num_clusters <- 2

results <- data.frame(
  num_clusters = integer(),
  ratio_clusters = numeric()
)


tryCatch({
  for (num_clusters in 2:max_clusters) {
        source("/Users/elifsuep/Desktop/DSGELAB/Family_Pedigree_Clustering_github/Scripts/Hierarchical_cluster_analysis.R")
        clustering_results <- perform_clustering(feat_data_list, max_clusters, num_clusters)
        
        source("/Users/elifsuep/Desktop/DSGELAB/Family_Pedigree_Clustering_github/Scripts/Comparison_of_Features.R")
        ratio_cluster <- clustering_results(feat_data_list, max_clusters, num_clusters)
        results <- rbind(results, data.frame(num_clusters = num_clusters, ratio_cluster = ratio_cluster))
  }
})
plot <- ggplot(results, aes(x = num_clusters, y = ratio_cluster)) +
  geom_line() +
  geom_point() +
  labs(title = "Ratio of Features Found in All TargetTrait Types",
       x = "Number of Clusters",
       y = "Ratio of Common Features in Clusters")


output_filepath_plot <- file.path(output_dir, "ratio_clusters_plot.png")
ggsave(output_filepath_plot, plot = plot)

print(plot)

feature_prevalence_list <- list()
common_features_list <- list()

for (i in 1:num_clusters) {
  output_dir <- "/Users/elifsuep/Desktop/DSGELAB/Family_Pedigree_Clustering/Mother_targettrait/hierarchical"
  dir.create(output_dir, showWarnings = FALSE)
  file_path_common <- file.path(output_dir, paste0("common_features_cluster", i, "_k_", num_clusters, ".csv"))
  file_path_prevalence <- file.path(output_dir, paste0("feature_prevalence_cluster", i, "_k_", num_clusters, ".csv"))

  common_features_list[[i]] <- read.csv(file_path_common)
  feature_prevalence_list[[i]] <- read.csv(file_path_prevalence)
  feature_prevalence_list[[i]]$Cluster <- paste("Cluster", i)


feature_prevalence <- bind_rows(feature_prevalence_list)
heatmap_data <- reshape2::dcast(feature_prevalence, Feature ~ Cluster, value.var = "Prevalence")
heatmap_plot <- ggplot(reshape2::melt(heatmap_data, id.vars = "Feature"), aes(x = variable, y = Feature, fill = value)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "red") +
  theme_minimal() +
  ggtitle(paste("Heatmap of Features Prevalence", i, "_k_", num_clusters)) +
  xlab("Cluster") +
  ylab("Feature") +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 4),
    axis.text.y = element_text(size = 8),  
    plot.title = element_text(size = 14),  
    axis.title.x = element_text(size = 10),  
    axis.title.y = element_text(size = 10)  
  )


ggplot(feature_prevalence, aes(x = Feature, y = Prevalence, fill = Cluster)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  ggtitle(paste("Prevalence of Features in Clusters", i, "_k_", num_clusters)) +
  xlab("Feature") +
  ylab("Prevalence") +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 4),
    axis.text.y = element_text(size = 8),  
    plot.title = element_text(size = 14),  
    axis.title.x = element_text(size = 10),  
    axis.title.y = element_text(size = 10)   
  )

}
output_heatmap_filepath <- file.path(output_dir, paste0("heatmap_of_features_prevalence_k_", num_clusters, ".png"))
ggsave(output_heatmap_filepath, plot = last_plot(), width = 40, height = 40, units = "in")

output_barplot_filepath <- file.path(output_dir, paste0("features_barplot_k_", num_clusters, ".png"))
ggsave(output_barplot_filepath, plot = last_plot(), width = 40, height = 40, units = "in")



move_files_by_cluster <- function(output_dir) {
  files <- list.files(output_dir, full.names = TRUE)
  
  for (file in files) {
    file_name <- basename(file)
    
    if (grepl("k_", file_name)) {
      cluster_number <- sub(".*k_([0-9]+).*", "\\1", file_name)
      target_folder <- file.path(output_dir, paste0("k_", cluster_number))
      
      if (!dir.exists(target_folder)) {
        dir.create(target_folder, recursive = TRUE)
      }
      
      file.rename(file, file.path(target_folder, file_name))
    }
  }
}

move_files_by_cluster(output_dir)

cat("\nGood morning, and in case I don’t see ya, good afternoon, good evening, and good night!\n")

sink()
sink(type = "message")

close(output_conn)