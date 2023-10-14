
# Global Missing Migrants:
1.	**Data Collection:** Acquired a dataset from Kaggle.com containing information on Global Missing Migrants.
<img src="Migrants_Basic_Info.png" alt="alt text" width="50%" height="50%">
3.	**Exploratory Data Analysis:** Conducted comprehensive EDA to understand the dataset. Key steps included:

-	Summary Statistics: Computed summary statistics for numerical columns to grasp the data's overall characteristics.
<img src="Summary_Stat.png" alt="alt text" width="50%" height="50%">
-	Data Preprocessing: Divided the coordinates column into longitude and latitude components for better analysis. Addressed missing values in the "NUMBER OF DEAD" column by replacing them with zeros to ensure clean visualization.
   ' df[['latitude', 'Longitude']] = df['Coordinates'].str.split(', ', expand=True).astype(float)  '

3.	**Data Visualization:** Employed various visualization techniques to gain insights:
-	Histogram: Utilized histograms to depict the distribution of incidents across the years.
 	<img src="Histogram.png" alt="alt text" width="50%" height="50%">
-	Bar Chart: Created bar charts to visualize the gender distribution among migrants.
 	<img src="BarChart.png" alt="alt text" width="50%" height="50%">
-	Line Chart: Employed line charts to identify patterns and trends in the number of deceased migrants over the years and on a monthly basis.
    <img src="Yearly_Trends.png" alt="alt text" width="35%" height="35%">        <img src="Monthly_Trends.png" alt="alt text" width="35%" height="35%">
4.	**Geospatial Visualization:** Enhanced understanding by plotting data points on a world map. This visualization method highlighted locations with significant numbers of deceased and missing migrants for improved spatial insights.
By combining these techniques, this project provides a comprehensive analysis of Global Missing Migrants' data, offering valuable insights into trends, patterns, and spatial distributions.
<img src="Geospatial.png" alt="alt text" width="50%" height="50%">






