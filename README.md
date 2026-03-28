
# 1. Layoffs Data Analysis Project
## Project Overview
- This project focuses on data cleaning and exploratory data analysis (EDA) of global layoffs data using SQL.
The goal is to transform raw data into a clean dataset and extract meaningful insights about layoffs trends across companies, industries, countries, and time.

## Tech Stack
- SQL (MySQL)
- Window Functions
- CTEs (Common Table Expressions)
- Data Cleaning Techniques
- Exploratory Data Analysis (EDA)

## Project Structure
├── Data_cleaning.sql   # Data cleaning & preprocessing

├── EDA.sql             # Exploratory Data Analysis queries

└── README.md           # Project documentation


## Data Cleaning Process
The dataset was cleaned using the following steps:

- Removed duplicate records using ROW_NUMBER()
- Created a staging table for safe transformations
- Trimmed inconsistent text values
- Standardized date format (STR_TO_DATE)
- Converted columns to appropriate data types
- Removed null/blank records
- Dropped unnecessary columns


## Exploratory Data Analysis (EDA)

### Key analysis performed:

- Maximum layoffs and percentage laid off
- Companies with highest layoffs
- Industry-wise layoffs trends
- Country-wise layoffs distribution
- Year-wise layoffs analysis
- Stage-wise layoffs comparison
- Monthly rolling totals
- Top companies by layoffs per year (ranking using DENSE_RANK)



 ## Key Insights
 
- Identified companies with the highest layoffs globally
- Found industries most impacted (e.g., tech, crypto)
- Observed layoffs trends over time (monthly & yearly)
- Highlighted top companies per year using ranking


## How to Run
1. Import dataset into MySQL
2. Run Data_cleaning.sql
3. Run EDA.sql
4. Analyze results using queries


## Future Improvements
- Add data visualization (Power BI / Tableau)
- Automate ETL pipeline using Python
- Schedule updates using Airflow or Cron




nverted columns to appropriate data types
Removed null/blank records
Dropped unnecessary columns
