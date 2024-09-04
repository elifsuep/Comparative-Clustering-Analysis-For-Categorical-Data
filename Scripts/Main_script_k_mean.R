#Combined


options(repos = c(CRAN = "https://cran.rstudio.com/"))

output_dir <- "/Users/elifsuep/Desktop/DSGELAB/m13_arthrosis_relationtype_clustering/k_mean/"
dir.create(output_dir, showWarnings = FALSE)

output_file <- file.path(output_dir, "output_log.txt")
output_conn <- file(output_file, open = "wt")

sink(output_conn)
sink(output_conn, type = "message")

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


install_if_missing(c("gtools", "data.table", "ggplot2", "NbClust", "dplyr", "scales"))



data <- fread("/Users/elifsuep/Desktop/DSGELAB/AllFam.Res_Stand", sep = "\t")

unique <- unique(data$RelationType)
filtered_data_list <- list()
feat_data_list <- list()

for (relation in unique) {
  filtered_data <- subset(data, RelationType == relation & TargetTrait == "I9_CHD")
  filtered_data_list[[relation]] <- filtered_data
  feat_data <- data.frame(FeatCoeff = filtered_data$FeatCoeff, FeatP = filtered_data$FeatP)
  feat_data_list[[relation]] <- feat_data
}

for (relation in unique) {
  assign(paste0("filtered_data_", relation), filtered_data_list[[relation]])
  assign(paste0("feat_data_", relation), feat_data_list[[relation]])
}

max_clusters <- 15
num_clusters <- 2

results <- data.frame(
  num_clusters = integer(),
  ratio_clusters = numeric()
)


  for (num_clusters in 2:max_clusters) {
    tryCatch({
      source("/Users/elifsuep/Desktop/DSGELAB/Family_Pedigree_Clustering_github/Scripts/k_means_cluster_analysis.R")
      all_centers <- perform_clustering(unique, feat_data_list, max_clusters, num_clusters, output_dir)
      new_names <- reassign_cluster_names(all_centers)
      
      source("/Users/elifsuep/Desktop/DSGELAB/Family_Pedigree_Clustering_github/Scripts/Comparison_of_Features.R")
      ratio_cluster <- clustering_results(feat_data_list, max_clusters, num_clusters)
      results <- rbind(results, data.frame(num_clusters = num_clusters, ratio_cluster = ratio_cluster))
    }, error = function(e) {
      message("Error in clustering or comparison script: ", e$message)
    })
  }
plot <- ggplot(results, aes(x = num_clusters, y = ratio_cluster)) +
  geom_line() +
  geom_point() +
  labs(title = "Ratio of Features Found in All RelationType Types",
       x = "Number of Clusters",
       y = "Ratio of Common Features in Clusters")


output_filepath_plot <- file.path(output_dir, "ratio_clusters_plot.png")
ggsave(output_filepath_plot, plot = plot)

print(plot)

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
