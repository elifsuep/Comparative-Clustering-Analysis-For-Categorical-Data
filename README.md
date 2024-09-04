### README

---

## Project Title: Comparative Clustering Analysis for Categorical Data

### Description

This repository contains scripts for analyzing the clustering of target traits in a dataset related to relatives to find the common features in the data. The workflow includes data processing, k-means clustering analysis, feature comparison, and visualization.

Scripts

1. Main_script_k_mean.R

This script serves as the main workflow for the project. It handles the initial setup, data loading, data preprocessing, clustering analysis, and results visualization.

Workflow:
1. Setup:
   - Specifies the CRAN repository for R packages.
   - Creates an output directory for results and initializes a log file to capture output.
   - Defines a helper function to install and load necessary R packages if they are not already installed.

2. Data Loading:
   - Loads raw data from a specified file path using `fread` from the `data.table` package.

3. Data Preprocessing:
   - Filters the data for each unique disease and relation type (Father), but you can change the variables according to your project.
   - Creates feature data frames for each target trait and stores them in lists.

4. Clustering Analysis:
   - Iterates over a range of cluster numbers to perform k-means clustering analysis.
   - Utilizes a separate script (`k_means_cluster_analysis.R`) to perform the clustering.
   - Compares features across clusters using a separate script (`Comparison_of_Features.R`).

5. Visualization:
   - Plots the ratio of common features across different numbers of clusters.
   - Saves the plot to a specified file path.

6. File Organization:
   - Moves result files into corresponding cluster directories based on their names.

Run the script in an R environment. Ensure the necessary file paths are correctly specified and the required scripts (`k_means_cluster_analysis.R` and `Comparison_of_Features.R`) are available in the specified locations.

2. `k_means_cluster_analysis.R`

This script performs k-means clustering analysis on the feature data for each target trait.

1. - `compute_wss`: Computes the within-cluster sum of squares (WSS) for a range of cluster numbers to help determine the optimal number of clusters.

2. Clustering Process:
   - Iterates over each target trait to perform k-means clustering.
   - Uses initial centers for clustering if available, otherwise calculates new centers.
   - Generates elbow plots for WSS to visualize the optimal number of clusters.
   - Creates k-means clustering plots for each target trait.

3. Visualization:
   - Saves elbow plots and k-means clustering plots to the output directory.

The script is sourced and executed from the main script. Ensure it is located in the specified file path.

3. `Comparison_of_Features.R`

This script compares the features across different clusters and calculates the ratio of common features found in all target trait types.

1. Data Combination:
   - Combines the feature data from all target traits into a single data frame.
   - Filters and summarizes the data to find common features across clusters.

2. Feature Analysis:
   - Identifies common features in all target traits for each cluster.
   - Calculates the prevalence of features separately for each cluster.

3. Visualization:
   - Creates heatmaps and bar plots to visualize feature prevalence across clusters.
   - Saves the visualizations to the output directory.

The script is sourced and executed from the main script. Ensure it is located in the specified file path.
