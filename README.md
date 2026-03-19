## NPA-Analysis ##

# Credit Risk Analysis: Movement of Non-Performing Assets (2005–2025)

# Project Overview

This project analyses 21 years of RBI Non-Performing Assets (NPA) movement data for Indian scheduled commercial banks. The goal was to understand trends in the movement of non-performing assets, how banks from different sectors handle NPAs, and how effective banks were at reforming and implementing solutions to deal with NPAs post-2018.

## Process of Analysis

# 1. Data Sourcing & Excel Cleaning (Initial QA)

  # • Downloaded "MOVEMENT OF NON-PERFORMING ASSETS (NPAs) OF SCHEDULED COMMERCIAL BANKS" dataset from RBI DBIE.

  # • Handled major data quality issues in Excel : 
     -  Inconsistent formatting not suitable for exporting to SQL for data analysis.
     -  Merged cells, Blank cells.
     -  Null / "-" values and zero-handling. 
     -  Duplicate rows and variations in bank names. 
     -  Varying bank categories (Public, Private, Foreign, Small Finance).
    
  # • Prepared clean, import-ready dataset for SQL.

## 2. SQL Server – Data Modelling & Standardization

   • Imported cleaned data into SQL Server and performed full data integrity checks (row count, duplicates, null/zero analysis, metadata validation).

   • Created bank_name_mapping table and used MERGE statement to systematically fix spelling variations, suffixes, and other terminologies (e.g., BANK OF BARODA*, HDFC BANK LTD., IDBI BANK LIMITED#).

   • Built analytical view v_npa_clean using LEFT JOIN and COALESCE for consistent bank_name_standard across all years.

   • Developed aggregate queries taking into account possible division errors for columns with 0s (NULLIF and CASE statements) to calculate:
       - Yearly system-wide totals
       - Sector-level aggregates
       - Core credit risk metrics (Slippage Ratio, Recovery Rate, Write-off Intensity, GNPA Change %, Inferred PCR)
    
   • Created CTE-based queries for bank-level rankings (Top 15 GNPA 2025 and Best Improvers 2020–2025).

## 3. Analysis & Visualization (Python) - Exported aggregated results from SQL to CSV files.

   • Loaded the CSVs into Python using Pandas.

   • Built four interactive Plotly visualizations in Google Colab: 
       1. Long-term Gross NPA trend line (2005–2025) 
       [https://deva-dharshini-447.github.io/NPA-Analysis/Charts/GNPA_Trend_2005_2025.html]
       
       2. Stacked area chart showing sector contribution to total GNPA 
       [https://deva-dharshini-447.github.io/NPA-Analysis/Charts/Sector_Share_2020_2025.html]
       
       3. Bar chart of Top 10 banks by GNPA exposure in 2025 
       [https://deva-dharshini-447.github.io/NPA-Analysis/Charts/Top_10_Banks_2025.html]
       
       4. Bar chart highlighting Best Improvers (percentage reduction 2020–2025) 
       [https://deva-dharshini-447.github.io/NPA-Analysis/Charts/Best_Improvers_2020_2025.html]
       
   • Exported all charts as standalone HTML files.

## ## *Key Insights and their Macroeconomic Context* ## ##

## • The 2015 AQR & The 2018 Peak: 
Indian banks largely survived the 2008 global crash, subsequently lending heavily to corporate infrastructure. Many of these went bad but were "evergreened" until the RBI’s 2015 Asset Quality Review (AQR) forced recognition. This is exactly why the data shows Gross NPAs violently peaking at ₹10.40 lakh crore in 2018, representing forced transparency rather than sudden systemic failure.

## • A Trend of Improvement: 
Following that peak, Gross NPAs fell to ₹4.32 lakh crore in 2025 (~58% reduction). This reflects the success of post-IBC (Insolvency and Bankruptcy Code) resolution mechanisms and a massive balance sheet cleanup phase.

## • The COVID-19 "Illusion" (2020–2022): 
Contrary to expectations of a pandemic-driven default crisis, the data shows Gross NPAs actively declining during this period. This highlights the impact of regulatory forbearance, loan moratoriums, and the ECLGS, which temporarily deferred stress recognition to prevent an economic shock.

## • Persistent PSB Dominance: 
Public Sector Banks still account for the largest volume of NPAs, highlighting legacy governance and challenges in corporate lending. However, their strong absolute reduction post-2020 shows meaningful progress in structural reform.

## • Private Sector Resilience: 
Private banks consistently showed lowering slippage ratios and better recovery efficiency. This indicates stronger credit underwriting, risk monitoring, and origination practices — a key differentiator in today’s competitive lending market.

## Tools Used

# Excel: 
Data cleaning & Quality Assurance
# SQL Server (SSMS): 
Data modeling, standardization & metric calculation
# Python (Pandas + Plotly): 
Data analysis & visualization

## Limitations

1. The analysis only includes aggregate bank-level data.
2. Inferred PCR (Gross – Net gap) for some banks.

## List of Attachments

## Npa-analysis

## 1. SQL queries
- npa_analysis.sql
  
## 2. Jupyter notebooks
- Notebook.ipynb
  
## 3. Outputs # SQL Query Outputs in .csv file format
- bank_risk_ranking.csv
- best_improvers_2020_2025.csv
- sector_ratios_2020_2025.csv
- top_gnpa_2025.csv
- yearly_totals.csv
  
## 4. Charts/              (charts/plots)
- Best_Improvers_2020_2025.png
- GNPA_Trend_2005_2025.png
- Sector_Share_2020_2025.png
- Top_10_Banks_2025.png
  
## README.md           # Documentation
