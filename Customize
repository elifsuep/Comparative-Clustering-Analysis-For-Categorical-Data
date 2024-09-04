#### Customizing the Main Script

You can customize the main script to suit your specific requirements. Here are the main sections you might want to modify:

1. **Output Directory**:
   - The `output_dir` variable specifies where the results will be saved. Change this to your preferred directory.
   ```r
   output_dir <- "/path/to/your/output/directory"
   ```

2. **Data File Path**:
   - The path to the input data file should be specified in the `fread` function. Modify this to point to your data file.
   ```r
   data <- fread("/path/to/your/datafile.txt", sep = "\t")
   ```

3. **Target Trait for Clustering**:
   - The `target_trait` parameter in the `prepare_y_column` and `prepare_x_column` functions determines which trait to use for clustering. Adjust this to the trait of interest in your dataset.
   ```r
   I9_CHD_data_wide <- prepare_y_column(data, target_trait = "Your_Target_Trait", value = "z_score")
   I9_CHD_data_wide_2 <- prepare_x_column(data, target_trait = "Your_Target_Trait", value = "z_score")
   ```

4. **Heatmap Title and Axis Labels**:
   - Customize the title, x-axis label, and y-axis label for the heatmap in the `create_heatmap` function call.
   ```r
   create_heatmap(output_dir, sorted_data_matrix, title = "Your Heatmap Title", xlab = "Your X-Axis Label", ylab = "Your Y-Axis Label", value_range = c(-9, 9))
   ```

5. **Value Range for Clipping Data**:
   - The `value_range` parameter in the `create_heatmap` function call specifies the range of values to clip the data. Modify this to fit the range of values in your dataset.
   ```r
   create_heatmap(output_dir, sorted_data_matrix, title = "Hierarchically-clustered Heatmap", xlab = "Relation Type", ylab = "Feature", value_range = c(-Your_Min_Value, Your_Max_Value))
   ```

### Example Customization

Here’s an example of how you might customize the main script:

```r
# Main Script

start_time <- Sys.time()
options(repos = c(CRAN = "https://cran.r-project.org"))

# Set your preferred output directory
output_dir <- "/Users/yourusername/Projects/Output"
dir.create(output_dir, showWarnings = FALSE)

output_file <- file.path(output_dir, "output_log.txt")
output_conn <- file(output_file, open = "wt")

sink(output_conn)
sink(output_conn, type = "message")

# Load required libraries
source("/Users/yourusername/Projects/Scripts/required_packages.R")
required_packages <- c("htmlwidgets", "data.table", "dplyr", "heatmaply", "reshape2", "ggnewscale", "scales", "ggdendro", "cluster", "dendextend")
install_and_load_packages(required_packages)

# Load your data
data <- fread("/Users/yourusername/Projects/Data/YourDataFile.txt", sep = "\t")
data <- na.omit(data)

# Calculate z-scores from p-values
source("/Users/yourusername/Projects/Scripts/qnorm.R")
data <- calculate_z_scores(data)

# Prepare data for clustering
source("/Users/yourusername/Projects/Scripts/prepare_columns.R")
I9_CHD_data_wide <- prepare_y_column(data, target_trait = "Your_Target_Trait", value = "z_score")
I9_CHD_data_wide_2 <- prepare_x_column(data, target_trait = "Your_Target_Trait", value = "z_score")

# Perform hierarchical clustering
source("/Users/yourusername/Projects/Scripts/hierarchical_cluster_data.R")
I9_CHD_data_dendro <- cluster_y_column(I9_CHD_data_wide)
I9_CHD_data_dendro_2 <- cluster_y_column(I9_CHD_data_wide_2)

# Sort the data based on clustering results
source("/Users/yourusername/Projects/Scripts/sort_data.R")
sorted_data_matrix <- sort_data_matrix(I9_CHD_data_dendro, I9_CHD_data_wide, I9_CHD_data_dendro_2, I9_CHD_data_wide_2)

# Create and save the heatmap
source("/Users/yourusername/Projects/Scripts/create_heatmap.R")
create_heatmap(output_dir, sorted_data_matrix, title = "My Custom Heatmap Title", xlab = "My X-Axis Label", ylab = "My Y-Axis Label", value_range = c(-5, 5))

end_time <- Sys.time()  # Record the end time
duration <- end_time - start_time  # Calculate the duration
print(paste("The script took", round(duration, 2), "seconds to run."))

sink()
sink(type = "message")

close(output_conn)
```

By following these instructions, you can customize the main script to fit your specific needs. Adjust the file paths, target traits, labels, and value ranges to ensure the script works with your data and desired output.
