# Overview

This project contains code for my DS 785 - Capstone Project titled 'Providing User Specific LMS Content Recommendations Using Machine Learning'. All data has been anonymized.

The primary goal of this project was to build a hybrid content recommendation engine using callaborative and content-based filtering. To accomplish this, KNN and Neural Networks were used in a hybrid approach to achieve 81.5% predictive accuracy. 

Full commentary on this project is provided in the final paper. For access to this paper (those outside of UWEX), please contact me at 17arhomberg@gmail.com.

# Project Directory

*data (this folder and its subfolders have been redacted due to GitHub size constraints)*
- *processed (the cleaned, aggregated, and finalized versions of the datasets)*
- *raw (the raw data sourced from Snowflake, orginating from Azure SQL DB and Salesforce)*
- *sample (samples of each of the datasets used for code development and testing)*


data_processing.ipynb (file contains the code used for reading in, cleaning, aggregating, and processing the data)

exploratory_data_analysis.ipynb (file contains the code used for the EDA, PCA, and Social Network analysis)

model_training.ipynb (file contains the code used for KNN and NN model development, along with the hybrid implementation and error analysis)

snowflake_queries.sql (contains the SQL files ran in Snowflake to obtain the 'raw' data)

*Note that code was written for and executed on a Macbook Pro M1 chip.*
