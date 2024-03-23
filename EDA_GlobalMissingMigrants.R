library(dplyr)
library(tidyr)
library(reshape2)
library(ggplot2)
library(leaflet)
library(e1071)


#Import dataset
migrants <- read.csv("Global_Missing_Migrants_Dataset - Copy.csv")

#View Dataset
glimpse(migrants) 
summary(migrants)

#excluded the source cause of lack of relevance
migrants <- migrants[,-c(17)]


#Count missing values in each column
sapply(migrants, function(x) sum(is.na(x)))

# Check for duplicate rows
duplicates <- migrants[duplicated(migrants),]

# If duplicates are found, examine them and decide whether to remove
if(nrow(duplicates) > 0) {
  migrants <- migrants[!duplicated(migrants),]
}


# For Migration Route filling missing values with a placeholder like "Unknown"
mode_get <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
migrants$Migration.route <- ifelse(is.na(migrants$Migration.route), 
                                   "Unknown", 
                                   migrants$Migration.route)


################################################################################
############################### Distribution ###################################

# Histogram
ggplot(migrants, aes(x = Number.of.Dead)) + 
  geom_histogram(binwidth = 1, fill = "blue", color = "black") + 
  labs(title = "Histogram of Number of Dead", x = "Number of Dead", y = "Frequency")

# Boxplot
ggplot(migrants, aes(y = Number.of.Dead)) + 
  geom_boxplot(fill = "blue", color = "black") + 
  labs(title = "Boxplot of Number of Dead", y = "Number of Dead", x = "")

# Q-Q Plot
qqnorm(migrants$Number.of.Dead, main = "Q-Q Plot of Number of Dead")
qqline(migrants$Number.of.Dead, col = "red")

# Skewness and Kurtosis
skewness_value <- skewness(migrants$Number.of.Dead, na.rm = TRUE)
kurtosis_value <- kurtosis(migrants$Number.of.Dead, na.rm = TRUE)

################################################################################

# For Number_of_Dead filled missing values with the median
# Median imputation
migrants$Number.of.Dead[is.na(migrants$Number.of.Dead)] <- median(migrants$Number.of.Dead, na.rm = TRUE)

################################################################################

#Split Coordinates' column into two new columns 'Latitude' and 'Longitude'
migrants <- migrants %>%
  # Separate the 'Coordinates' into 'Latitude' and 'Longitude'
  separate(Coordinates, into = c("Latitude", "Longitude"), sep = ",") %>%
  # Convert the new 'Latitude' and 'Longitude' columns to numeric
  mutate(
    Latitude = as.numeric(Latitude),
    Longitude = as.numeric(Longitude)
  )


################################################################################
################################################################################
# Scatter plot for Number of Dead vs. Incident Year
ggplot(migrants, aes(x = Incident.year, y = Number.of.Dead)) +
  geom_point(alpha = 0.5) +
  labs(title = "Scatter Plot of Number of Dead over Years", x = "Incident Year", y = "Number of Dead")

# Time Series Plot of Incidents over Time
migrants %>%
  group_by(Incident.year) %>%
  summarise(Total.Incidents = sum(Total.Number.of.Dead.and.Missing, na.rm = TRUE)) %>%
  ggplot(aes(x = Incident.year, y = Total.Incidents)) +
  geom_line() +
  geom_point() +
  labs(title = "Total Incidents over Years", x = "Year", y = "Total Incidents")


# Bar Chart for Region of Incident
ggplot(migrants, aes(x = Region.of.Incident)) +
  geom_bar(fill = "cyan", color = "black") +
  labs(title = "Incidents by Region", x = "Region of Incident", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) # Rotating x labels for better readability


############################## CORRELATION MATRIX ##############################
#only the numerical columns for the correlation matrix
numerical_data <- migrants %>% 
  select(Number.of.Dead, Minimum.Estimated.Number.of.Missing, Total.Number.of.Dead.and.Missing, Number.of.Survivors, Number.of.Females, Number.of.Males, Number.of.Children)

# Calculate the correlation matrix, using Pearson method and excluding NA values
cor_matrix <- cor(numerical_data, use = "complete.obs", method = "pearson")

# Print the correlation matrix
print(cor_matrix)

# Melt the correlation matrix to long format
melted_cor_matrix <- melt(cor_matrix)

# Heatmap for correlations
ggplot(melted_cor_matrix, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, limit = c(-1,1)) +
  theme_minimal() +
  labs(title = "Heatmap of Correlation Matrix", x = "", y = "") +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))


############################################
#### Geographic Analysis ###################
# View the first few rows of the updated dataframe
head(migrants)


# Set a threshold for significant incidents
threshold <- 5 # This value can be adjusted as needed

# Assign colors based on the threshold
migrants$color <- with(migrants, ifelse(Number.of.Dead > threshold, 'red', 'lightgrey'))

leaflet(data = migrants) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~Longitude, 
    lat = ~Latitude, 
    color = ~color, 
    popup = ~paste("Dead:", Number.of.Dead, "<br>Missing:", Minimum.Estimated.Number.of.Missing)
  )

########################################################
######### TREND OF MIGRATION BY MONTH ##################

# Summarize the data by month
monthly_trends <- migrants %>% 
  group_by(Reported.Month) %>% 
  summarise(Total_Incidents = n(),
            Total_Deaths = sum(Number.of.Dead, na.rm = TRUE))

# Order the months correctly
monthly_trends$Reported.Month <- factor(monthly_trends$Reported.Month, levels = month.name)
3079 
# Create a line chart with the summarized data
ggplot(monthly_trends, aes(x = Reported.Month, y = Total_Deaths, group = 1)) +
  geom_line() +
  geom_point() +
  labs(title = "Trend of Migration Incidents by Month", x = "Month", y = "Total Incidents") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

################################################################################
########### CAUSE OF DEATH and LOCATION ANALYSIS ###########

# Summarize data by cause of death
cause_of_death_summary <- migrants %>%
  group_by(Cause.of.Death) %>%
  summarise(Total_Deaths = sum(Number.of.Dead, na.rm = TRUE)) %>%
  arrange(desc(Total_Deaths))

# View the summary
print(cause_of_death_summary)

########### VISUALIZATION #####################

# Create a bar chart for causes of death
ggplot(cause_of_death_summary, aes(x = Total_Deaths, y = reorder(Cause.of.Death, Total_Deaths))) +
  geom_bar(stat = "identity", fill = "tomato3") +
  labs(title = "Number of Deaths by Cause", x = "Cause of Death", y = "Number of Deaths") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


################################################################################
####################### Missing Children #######################################

# Assuming your dataframe is named 'migrants'
# and the columns are 'Number.of.Children', 'Number.of.Males', 'Number.of.Females'
migrants_long <- gather(migrants, 'Demographic', 'Number.Missing', 
                        c('Number.of.Children', 'Number.of.Males', 'Number.of.Females'))

ggplot(migrants_long, aes(x=Demographic, y=Number.Missing, fill=Demographic)) +
  geom_bar(stat='identity', position='dodge') +
  facet_wrap(~Region.of.Incident) + # Assuming you have a 'Region.of.Incident' column
  labs(title="Comparison of Missing Migrants by Demographic and Region", 
       y="Number Missing", x="Demographic") +
  theme_minimal() +
  theme(legend.position="none")

################################################################################
# Calculate the totals for each Demographic category
totals <- migrants_long %>%
  group_by(Demographic) %>%
  summarise(Total = sum(Number.Missing)) 

# Merge the totals back with the original data for plotting
migrants_long <- migrants_long %>%
  left_join(totals, by = "Demographic")

################################################################################
# WORKED KEEP
# Calculate the totals for each demographic
demographic_totals <- migrants_long %>%
  group_by(Demographic) %>%
  summarise(Total = sum(Number.Missing, na.rm = TRUE))

# Create a simple bar chart with totals on top
ggplot(demographic_totals, aes(x=Demographic, y=Total, fill=Demographic)) +
  geom_bar(stat='identity') +
  geom_text(aes(label=Total), 
            vjust=-0.3, # Adjust this to position the text above the bars
            size=3.5) +
  labs(title="Total Missing Migrants by Demographic", 
       y="Total Number Missing", x="Demographic") +
  theme_minimal() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Set1")
################################################################################
########### Total Missing Children by Region ###################################

# Calculate the totals of missing children for each region
grand_total <- sum(region_children_totals$Total.Children.Missing)

# Your existing code to create the plot
p <- ggplot(region_children_totals, aes(x=Region.of.Incident, y=Total.Children.Missing)) +
  geom_bar(stat='identity', fill='steelblue') +
  geom_text(aes(label=Total.Children.Missing), vjust=-0.3, size=3.5) +
  labs(title="Total Missing Children by Region of Incident", y="Total Number of Missing Children", x="Region of Incident") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=45, hjust=1))

# Add the grand total annotation to the top-right corner
p + annotate("text", x=Inf, y=Inf, label=paste("Total Missing Children:", grand_total), 
             hjust=1, vjust=1, size=5, color="red")



################## Geo Location ################################################
#Considering incidents with 10 or more missing children
threshold <- 10

# Filter the data
children_incidents <- migrants %>% 
  filter(Number.of.Children >= threshold)

# Create a leaflet map
leaflet(children_incidents) %>%
  addTiles() %>%
  addCircles(
    lng = ~Longitude, lat = ~Latitude, weight = 1,
    radius = ~Number.of.Children * 2000, # Adjust the multiplier to suitable for your data
    popup = ~paste(Number.of.Children, "children missing"),
    color = '#FF0000', fillColor = '#FF0000', fillOpacity = 0.5
  )
