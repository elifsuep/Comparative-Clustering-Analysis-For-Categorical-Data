combined_list <- list()

clustering_results <- function(feat_data_list, max_clusters, num_clusters) {
  
  for (relation in unique) {
    feat_data <- get(paste0("feat_data_", relation))
    filtered_data <- get(paste0("filtered_data_", relation))
    filtered_data$Cluster <- feat_data$Cluster
    combined_list[[relation]] <- filtered_data
  }
  
  combined_data <- do.call(rbind, combined_list)
  print(combined_data)
  
  combined_data <- combined_data %>%
    select(RelationType, Feature, Cluster)
  
  # Initialize lists to store common features and prevalence for each cluster
  common_features <- vector("list", num_clusters)
  names(common_features) <- paste0("common_features_cluster", 1:num_clusters)
  
  for (i in 1:num_clusters) {
    cluster_name <- paste0("common_features_cluster", i)
    
    common_features[[cluster_name]] <- combined_data %>%
      filter(Cluster == as.character(i)) %>%
      group_by(Feature) %>%
      summarize(Count = n_distinct(RelationType)) %>%
      filter(Count == length(unique))
  }
  
  
  # Convert results into separate data frames
  for (i in 1:num_clusters) {
    cluster_name <- paste0("common_features_cluster", i)
    df_name <- paste0("common_features_df_cluster", i)
    
    assign(df_name, as.data.frame(common_features[[cluster_name]]))
  }
  
  # Calculate feature prevalence separately for each cluster
  for (i in 1:num_clusters) {
    prevalence_name <- paste0("feature_prevalence_cluster", i)
    
    prevalence_df <- combined_data %>%
      filter(Cluster == as.character(i)) %>%
      group_by(Feature) %>%
      summarize(Prevalence = n_distinct(RelationType))
    
    assign(prevalence_name, prevalence_df)
  }
  
  # Calculate the ratio of features found in all RelationType types
  all_features <- unique(combined_data$Feature)
  total_features <- length(all_features)
  
  total_ratio <- 0
  
  for (i in 1:num_clusters) {
    df_name <- paste0("common_features_df_cluster", i)
    total_features_cluster <- nrow(get(df_name))
    
    ratio_cluster <- total_features_cluster / total_features
    total_ratio <- total_ratio + ratio_cluster
    
    print(total_ratio)
    
    for (i in 1:num_clusters) {
      common_features_df_name <- paste0("common_features_df_cluster", i)
      feature_prevalence_name <- paste0("feature_prevalence_cluster", i)
      
      print(paste("Common Features in All RelationTypes for Cluster", i, ":"))
      print(get(common_features_df_name))
      
      print(paste("Feature Prevalence in Cluster", i, ":"))
      print(get(feature_prevalence_name))
    }
    
    for (i in 1:num_clusters) {
      file_path_common <- file.path(output_dir, paste0("common_features_cluster", i, "_k_", num_clusters, ".csv"))
      file_path_prevalence <- file.path(output_dir, paste0("feature_prevalence_cluster", i, "_k_", num_clusters, ".csv"))
      
      common_features_df_name <- paste0("common_features_df_cluster", i)
      feature_prevalence_name <- paste0("feature_prevalence_cluster", i)
      
      write.csv(get(common_features_df_name), file_path_common, row.names = FALSE)
      write.csv(get(feature_prevalence_name), file_path_prevalence, row.names = FALSE)
    }
    
    feature_prevalence_list <- list()
    common_features_list <- list()
    
    for (i in 1:num_clusters) {
      output_dir <- "/Users/elifsuep/Desktop/DSGELAB/m13_arthrosis_relationtype_clustering/k_mean"
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
        ggtitle(paste("Heatmap of Features Prevalence k=", num_clusters)) +
        xlab("Cluster") +
        ylab("Feature") +
        theme(
          axis.text.x = element_text(angle = 90, hjust = 1, size = 10),
          axis.text.y = element_text(size = 4),  
          plot.title = element_text(size = 20),  
          axis.title.x = element_text(size = 10),  
          axis.title.y = element_text(size = 10)  
        )
      
      output_heatmap_filepath <- file.path(output_dir, paste0("heatmap_of_features_prevalence_k_", num_clusters, ".png"))
      ggsave(output_heatmap_filepath, plot = last_plot(), width = 10, height = 10, units = "in")
      
      #Sys.sleep(15)
      
      ggplot(feature_prevalence, aes(x = Feature, y = Prevalence, fill = Cluster)) +
        geom_bar(stat = "identity", position = "dodge") +
        theme_minimal() +
        ggtitle(paste("Prevalence of Features in Clusters k=", num_clusters)) +
        xlab("Feature") +
        ylab("Prevalence") +
        theme(
          axis.text.x = element_text(angle = 90, hjust = 1, size = 2.5),
          axis.text.y = element_text(size = 8),  
          plot.title = element_text(size = 20),  
          axis.title.x = element_text(size = 10),  
          axis.title.y = element_text(size = 10)   
        )
      
      output_barplot_filepath <- file.path(output_dir, paste0("features_barplot_k_", num_clusters, ".png"))
      ggsave(output_barplot_filepath, plot = last_plot(), width = 10, height = 10, units = "in")
      #Sys.sleep(15)
    }
    
  } 
  return(total_ratio)  
}