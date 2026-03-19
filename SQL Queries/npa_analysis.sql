-- ================================================================================================ --
-- Analysis of Movement of Non-Performing Assets (NPAs) of Banks --
-- Data Source: MOVEMENT OF NON-PERFORMING ASSETS (NPAs) OF SCHEDULED COMMERCIAL BANKS - RBI DBIE --
-- ================================================================================================ --

-- 1. METADATA & HEALTH CHECKS

SELECT 
    COLUMN_NAME, DATA_TYPE, NUMERIC_PRECISION, NUMERIC_SCALE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'npa_data'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT year) AS unique_years,
    MIN(year) AS min_year,
    MAX(year) AS max_year,
    COUNT(DISTINCT bank_name) AS unique_banks
FROM dbo.npa_data;


-- 2. BANK NAME STANDARDIZATION

-- Creating mapping table 
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bank_name_mapping')
CREATE TABLE dbo.bank_name_mapping (
    original_name NVARCHAR(100) PRIMARY KEY,
    standard_name NVARCHAR(100) NOT NULL
);

-- Inserting mappings
MERGE dbo.bank_name_mapping AS target
USING (VALUES
    ('BANK OF BARODA*', 'BANK OF BARODA'),
    ('CANARA BANK*', 'CANARA BANK'),
    ('INDIAN BANK*', 'INDIAN BANK'),
    ('PUNJAB NATIONAL BANK*', 'PUNJAB NATIONAL BANK'),
    ('STATE BANK OF INDIA*', 'STATE BANK OF INDIA'),
    ('UNION BANK OF INDIA*', 'UNION BANK OF INDIA'),
    ('HDFC BANK LTD.', 'HDFC BANK LIMITED'),
    ('YES BANK LTD.', 'YES BANK LIMITED'),
    ('IDBI BANK LIMITED#', 'IDBI BANK LIMITED')
) AS source (original_name, standard_name)
ON target.original_name = source.original_name
WHEN MATCHED THEN UPDATE SET target.standard_name = source.standard_name
WHEN NOT MATCHED THEN INSERT VALUES (source.original_name, source.standard_name);

-- Creating an analytical view
IF EXISTS (SELECT * FROM sys.views WHERE name = 'v_npa_clean')
    DROP VIEW dbo.v_npa_clean;
GO

CREATE VIEW dbo.v_npa_clean AS
SELECT 
    n.year,
    COALESCE(m.standard_name, n.bank_name) AS bank_name_standard,
    n.bank_category,
    n.gross_npa_opening,
    n.gross_npa_addition,
    n.gross_npa_reduction,
    n.gross_npa_writeoff,
    n.gross_npa_closing,
    n.net_npa_opening,
    n.net_npa_closing
FROM dbo.npa_data n
LEFT JOIN dbo.bank_name_mapping m ON n.bank_name = m.original_name;
GO

-- 3. Calculating Aggregates

-- Yearly Totals 
SELECT 
    year,
    SUM(gross_npa_opening)   AS total_gross_opening_cr,
    SUM(gross_npa_addition)  AS total_addition_cr,
    SUM(gross_npa_reduction) AS total_reduction_cr,
    SUM(gross_npa_writeoff)  AS total_writeoff_cr,
    SUM(gross_npa_closing)   AS total_gross_closing_cr,
    SUM(net_npa_closing)     AS total_net_closing_cr
FROM dbo.v_npa_clean
GROUP BY year
ORDER BY year DESC;
-- (results exported as yearly_totals.csv)--


-- 4. Analysis of Key Metrics

-- Sector Aggregates with Ratios 
SELECT 
    year,
    bank_category,
    SUM(gross_npa_opening)   AS gross_opening_cr,
    SUM(gross_npa_addition)  AS addition_cr,
    SUM(gross_npa_closing)   AS gross_closing_cr,
    
    ROUND(SUM(gross_npa_addition)*1.0/NULLIF(SUM(gross_npa_opening),0)*100,2) AS slippage_pct,
    ROUND(SUM(gross_npa_reduction)*1.0/NULLIF(SUM(gross_npa_opening)+SUM(gross_npa_addition),0)*100,2) AS recovery_rate_pct,
    ROUND((SUM(gross_npa_closing)-SUM(net_npa_closing))*1.0/NULLIF(SUM(gross_npa_closing),0)*100,2) AS inferred_pcr_pct
FROM dbo.v_npa_clean
WHERE year BETWEEN 2020 AND 2025
GROUP BY year, bank_category
ORDER BY year DESC, bank_category;
-- (Results exported as sector_ratios_2020_2025.csv)

-- 5. Ranking of Banks based on Metrics.
-- Top 15 Banks by GNPA (2025) 

SELECT TOP 15 
    bank_name_standard,
    bank_category,
    gross_npa_closing AS gnpa_closing_cr,
    (gross_npa_closing - net_npa_closing) AS provision_gap_cr,
    ROUND((gross_npa_closing - net_npa_closing)*1.0/NULLIF(gross_npa_closing,0)*100,2) AS inferred_pcr_pct
FROM dbo.v_npa_clean
WHERE year = 2025
ORDER BY gross_npa_closing DESC;
-- (Results exported as top_gnpa_2025.csv)

-- Best Improving Banks 2020-2025 
WITH cte_2020 AS (
    SELECT bank_name_standard, gross_npa_closing AS gnpa_2020 
    FROM dbo.v_npa_clean WHERE year = 2020
),
cte_2025 AS (
    SELECT bank_name_standard, gross_npa_closing AS gnpa_2025, bank_category 
    FROM dbo.v_npa_clean WHERE year = 2025
)
SELECT 
    c25.bank_name_standard,
    c25.bank_category,
    ROUND((c20.gnpa_2020 - c25.gnpa_2025)*1.0/NULLIF(c20.gnpa_2020,0)*100,2) AS gnpa_reduction_pct
FROM cte_2025 c25
INNER JOIN cte_2020 c20 ON c25.bank_name_standard = c20.bank_name_standard
WHERE c20.gnpa_2020 > 0
ORDER BY gnpa_reduction_pct DESC;
-- (Results exported as best_improvers_2020_2025.csv)

-----------------------------------------------------------------------------------------------------
