### Hierarchical clustering

perform_clustering <- function(feat_data_list, max_clusters, num_clusters) {
  
  for (TargetTrait in unique_disease) {
    print(paste("Processing TargetTrait:", TargetTrait))
    feat_data <- feat_data_list[[TargetTrait]]
    dist_matrix <- dist(feat_data)
    hc_complete <- hclust(dist_matrix, method = "complete")
    clusters <- cutree(hc_complete, k = num_clusters)
    feat_data$Cluster <- as.factor(clusters)
    feat_data_list[[TargetTrait]] <- feat_data

  ### Visualization of Dendogram
  dendro_data <- ggdendro::dendro_data(hc_complete, type = "rectangle")
  dendrogram_plot <- ggplot() +
    geom_segment(data = dendro_data$segments, aes(x = x, y = y, xend = xend, yend = yend)) +
    geom_text(data = dendro_data$labels, aes(x = x, y = y, label = label), hjust = 1, angle = 90, size = 2.5) +
    theme_minimal() +
    ggtitle("Complete Linkage Dendrogram")

  output_filepath <- file.path(output_dir, paste0("hierarchical_plot_", TargetTrait, "_k_", num_clusters, ".png"))
  ggsave(output_filepath, plot = dendrogram_plot, width = 30, height = 30, units = "cm")

  assign(paste0("feat_data_", TargetTrait), feat_data, envir = .GlobalEnv)


  }
  
}

