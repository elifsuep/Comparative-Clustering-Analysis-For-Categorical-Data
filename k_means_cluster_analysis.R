library(ggplot2)

calculate_total_distance <- function(clusters, reference_clusters) {
  total_distance <- sum(sapply(1:nrow(clusters), function(i) {
    distance <- dist(rbind(clusters[i, ], reference_clusters[i, ]))
    return(distance)
  }))
  return(total_distance)
}

perform_clustering <- function(unique, feat_data_list, max_clusters, num_clusters, output_dir) {
  
  compute_wss <- function(data, max_clusters) {
    wss <- numeric(max_clusters)
    for (k in 1:max_clusters) {
      kmeans_result <- kmeans(data, centers = k, iter.max = 1000, nstart = 25)
      wss[k] <- kmeans_result$tot.withinss
    }
    return(wss)
  }
  all_centers <- list()
  
  for (relation in unique) {
    print(paste("Processing RelationType:", relation)) 
    
    feat_data <- feat_data_list[[relation]]
    feat_data <- na.omit(feat_data)
    wss <- compute_wss(feat_data, max_clusters)
    wss_df <- data.frame(Clusters = 1:max_clusters, WSS = wss)
    
    elbow_plot <- ggplot(wss_df, aes(x = Clusters, y = WSS)) +
      geom_line() +
      geom_point() +
      labs(title = paste("Elbow Plot for", relation, "K-means Clustering"),
           x = "Number of Clusters",
           y = "Total Within-Cluster Sum of Squares") +
      theme_minimal()
    
    output_filepath <- file.path(output_dir, paste0("elbow_plot_", relation, "_k_", num_clusters, ".png"))
    ggsave(output_filepath, plot = elbow_plot)
    
    kmeans_result <- kmeans(feat_data, centers = num_clusters, nstart = 25)
    all_centers[[relation]] <- kmeans_result$centers
    
    feat_data$Cluster <- as.factor(kmeans_result$cluster)
    feat_data_list[[relation]] <- feat_data
  
    assign(paste0("feat_data_", relation), feat_data, envir = .GlobalEnv)
  }    
  return(list(all_centers = all_centers, feat_data_list = feat_data_list))
}  
  reassign_cluster_names <- function(all_centers) {
    best_a <- NULL
    best_unique_k_number <- -Inf
    best_total_distance <- Inf
    best_assigned_names <- NULL

    for (a in unique) {
      reference_centers <- all_centers$all_centers[[a]]
      reference_names <- rownames(reference_centers)
      total_unique_k_number <- 0
      total_distance <- 0
      assigned_names_list <- list()
     
      for (relation in unique) {
        cluster_centers <- all_centers$all_centers[[relation]]
        distances <- as.matrix(dist(rbind(cluster_centers, reference_centers)))
        distances <- distances[1:nrow(cluster_centers), (nrow(cluster_centers) + 1):(nrow(cluster_centers) + nrow(reference_centers))]
        nearest_indices <- apply(distances, 1, which.min)
        assigned_names <- reference_names[nearest_indices]
        assigned_names <- as.numeric(assigned_names)
        total_unique_k_number <- total_unique_k_number + length(unique(assigned_names))
        total_distance <- total_distance + calculate_total_distance(cluster_centers, reference_centers[nearest_indices, ])
        assigned_names_list[[relation]] <- assigned_names
      }
        
      if (total_unique_k_number > best_unique_k_number || 
          (total_unique_k_number == best_unique_k_number && total_distance < best_total_distance)) {
        best_a <- a
        best_unique_k_number <- total_unique_k_number
        best_total_distance <- total_distance
        best_assigned_names <- assigned_names_list
      }
        print(best_unique_k_number)
    }
      
    print(paste0("Best relatives for clustering:", best_a))
    # Best assignment için tekrar atama yapma
    reference_centers <- all_centers$all_centers[[best_a]]
    reference_names <- rownames(reference_centers)
    
    for (relation in unique) {
      cluster_centers <- all_centers$all_centers[[relation]]
      distances <- as.matrix(dist(rbind(cluster_centers, reference_centers)))
      distances <- distances[1:nrow(cluster_centers), (nrow(cluster_centers) + 1):(nrow(cluster_centers) + nrow(reference_centers))]
      nearest_indices <- apply(distances, 1, which.min)
      assigned_names <- reference_names[nearest_indices]
      assigned_names <- as.numeric(assigned_names)
      
      for (i in 1:length(all_centers$feat_data_list[[relation]]$Cluster)) {
        b <- as.numeric(all_centers$feat_data_list[[relation]]$Cluster[i])
        all_centers$feat_data_list[[relation]]$Cluster[i] <- assigned_names[b]
      }
    
    }
  
      for (relation in unique) {
        feat_data <- all_centers$feat_data_list[[relation]]
        
       
        color_palette <- hue_pal()(max_clusters)
        cluster_colors <- setNames(color_palette, 1:max_clusters)
        
        kmeans_plot <- ggplot(feat_data, aes(FeatP, FeatCoeff, color = Cluster)) +
          geom_point(size = 3) +
          scale_color_manual(values = cluster_colors) +
          labs(title = paste("K-means Clustering of", relation, "Dataset"),
               x = "FeatP",
               y = "FeatCoeff") +
          theme_minimal()
        
        
        output_filepath <- file.path(output_dir, paste0("kmeans_plot_", relation, "_k_", num_clusters, ".png"))
        ggsave(output_filepath, plot = kmeans_plot)
        
        assign(paste0("feat_data_", relation), feat_data, envir = .GlobalEnv)
      }

      }
  