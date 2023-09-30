#!/usr/bin/env python
# coding: utf-8

# Global Missing Migrants
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
import scipy.cluster.hierarchy as sch
import warnings
warnings.filterwarnings('ignore')


# In[30]:


df = pd.read_csv("C:/Users/timyi/Downloads/GLobal_missing_migrants/Global Missing Migrants Dataset.csv")


# #Display basic information about the dataset

# In[31]:


print(df.info())


# #The 'Coordinates' column got both the Latitude and longitude together. This will split them in to two different columns wit the "Latitude" and 'Longitude'in each column

# In[33]:


df[['latitude', 'Longitude']] = df['Coordinates'].str.split(', ', expand=True).astype(float)


# #Get summary statstics of numerical columns excluding the Incident year, Longitude  abd latitude

# In[81]:


columns_to_exclude = ['Incident year','latitude','Longitude']
summary_stats = df.drop(columns=columns_to_exclude).describe()

print(summary_stats)


# #will replace any missing values in the "Number of dead" column with 0

# In[34]:


df['Number of Dead'].fillna(0, inplace=True) 


# In[35]:


fig_year = px.histogram(df, x='Incident year', nbins=len(df['Incident year'].unique()))

# Creating a color scale with shades for each unique year
color_scale = px.colors.sequential.Viridis  
color_scale = color_scale[::-1]  

traces = []
for year in df['Incident year'].unique():
    trace = go.Histogram(x=df[df['Incident year'] == year]['Incident year'],
                         name=str(year),
                         nbinsx=1,
                         marker_color=color_scale[year % len(color_scale)])
    traces.append(trace)

layout = go.Layout(title="Distribution of Incident Years with Color Shades",
                   barmode='overlay')

fig_year = go.Figure(data=traces, layout=layout)

fig_year.show()


# #Correlation heat map

# In[50]:


# Select numerical columns for correlation analysis
numerical_cols = df.select_dtypes(include=['int64', 'float64'])

# Calculate the correlation matrix
correlation_matrix = numerical_cols.corr()

# Create a heatmap
fig = px.imshow(correlation_matrix,
                x=numerical_cols.columns,
                y=numerical_cols.columns,
                title='Correlation Heatmap')
fig.show()


# #Gender Distribution

# In[37]:


gender_counts = df[['Number of Females', 'Number of Males', 'Number of Children']].sum()

# Define custom colors for the bars
custom_colors = ['#FF5733', '#3498DB', '#F7DC6F']

# Create the bar chart with custom colors
fig_gender = px.bar(
    gender_counts, 
    x=gender_counts.index, 
    y=gender_counts.values, 
    labels={'x': 'Gender', 'y': 'Count'},
    color=gender_counts.index,  # Use the 'Gender' column for coloring
    color_discrete_map={gender: color for gender, color in zip(gender_counts.index, custom_colors)}
)

# Customize the layout
fig_gender.update_layout(
    title_text="Gender Distribution of Global Migrants",
    xaxis_title="Gender",
    yaxis_title="Count",
)

fig_gender.show()


# #Time based monthly trends

# In[39]:


monthly_trends = df.groupby('Reported Month')['Total Number of Dead and Missing'].sum().reset_index()

fig_monthly_trends = px.line(monthly_trends, x='Reported Month', y='Total Number of Dead and Missing', 
                             labels={'Reported Month': 'Month', 'Total Number of Dead and Missing': 'Total Count'},
                             title='Monthly Trends of Total Deaths and Missing')
fig_monthly_trends.show()


# #trends and patterns over time for Number of Dead or missing over the years

# In[79]:


# Convert the 'Incident year' column to datetime
data['Incident year'] = pd.to_datetime(df['Incident year'], format='%Y')

# Create a time series line plot
fig = px.line(df, x='Incident year', y='Total Number of Dead and Missing',
              title='Total Number of Dead and Missing Over Time')
fig.show()


# In[82]:


fig = px.scatter_mapbox(df, lat='latitude', lon='Longitude', color='Total Number of Dead and Missing',
                        title='Incident Locations',
                        mapbox_style='carto-positron')
fig.show()

