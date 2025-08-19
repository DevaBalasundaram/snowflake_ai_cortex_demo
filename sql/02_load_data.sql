/*--
Snowflake Cortex Analyst Demo Setup Script 2/3  
Load sample data from CSV files into tables
--*/

-- Set role and context
USE ROLE cortex_user_role;
USE DATABASE cortex_analyst_demo;
USE SCHEMA cortex_analyst_demo.revenue_timeseries;
USE WAREHOUSE cortex_analyst_wh;

-- Verify files are uploaded to stage
LIST @raw_data;

/*--
Load data into tables using COPY INTO commands
Make sure you've uploaded the CSV files to @raw_data stage first!
--*/

-- Load daily revenue fact data
COPY INTO cortex_analyst_demo.revenue_timeseries.daily_revenue
FROM @raw_data
FILES = ('daily_revenue.csv')
FILE_FORMAT = (
    TYPE = CSV,
    SKIP_HEADER = 1,                          -- Skip header row
    FIELD_DELIMITER = ',',
    TRIM_SPACE = FALSE,
    FIELD_OPTIONALLY_ENCLOSED_BY = NONE,
    REPLACE_INVALID_CHARACTERS = TRUE,
    DATE_FORMAT = AUTO,                       -- Auto-detect date format  
    TIME_FORMAT = AUTO,
    TIMESTAMP_FORMAT = AUTO,
    EMPTY_FIELD_AS_NULL = FALSE,
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = CONTINUE                           -- Continue loading on errors
FORCE = TRUE;                                 -- Reload files if already loaded

-- Load product dimension data
COPY INTO cortex_analyst_demo.revenue_timeseries.product_dim
FROM @raw_data  
FILES = ('product.csv')
FILE_FORMAT = (
    TYPE = CSV,
    SKIP_HEADER = 1,
    FIELD_DELIMITER = ',',
    TRIM_SPACE = FALSE,
    FIELD_OPTIONALLY_ENCLOSED_BY = NONE,
    REPLACE_INVALID_CHARACTERS = TRUE,
    DATE_FORMAT = AUTO,
    TIME_FORMAT = AUTO, 
    TIMESTAMP_FORMAT = AUTO,
    EMPTY_FIELD_AS_NULL = FALSE,
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = CONTINUE
FORCE = TRUE;

-- Load region dimension data
COPY INTO cortex_analyst_demo.revenue_timeseries.region_dim
FROM @raw_data
FILES = ('region.csv') 
FILE_FORMAT = (
    TYPE = CSV,
    SKIP_HEADER = 1,
    FIELD_DELIMITER = ',',
    TRIM_SPACE = FALSE,
    FIELD_OPTIONALLY_ENCLOSED_BY = NONE,
    REPLACE_INVALID_CHARACTERS = TRUE,
    DATE_FORMAT = AUTO,
    TIME_FORMAT = AUTO,
    TIMESTAMP_FORMAT = AUTO, 
    EMPTY_FIELD_AS_NULL = FALSE,
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = CONTINUE
FORCE = TRUE;

-- Verify data loaded successfully
SELECT 'daily_revenue records loaded: ' || COUNT(*)::STRING as STATUS FROM daily_revenue
UNION ALL
SELECT 'product_dim records loaded: ' || COUNT(*)::STRING FROM product_dim  
UNION ALL
SELECT 'region_dim records loaded: ' || COUNT(*)::STRING FROM region_dim;

-- Show sample data from each table
SELECT 'Sample data from daily_revenue:' as TABLE_NAME, '' as DATE, '' as REVENUE, '' as PRODUCT_LINE, '' as REGION
UNION ALL
SELECT '', DATE::STRING, REVENUE::STRING, p.product_line, r.sales_region
FROM daily_revenue d
JOIN product_dim p ON d.product_id = p.product_id
JOIN region_dim r ON d.region_id = r.region_id
LIMIT 10;

-- Show dimension data
SELECT 'Product Lines Available:' as INFO, product_line as VALUE FROM product_dim
UNION ALL  
SELECT 'Sales Regions Available:', sales_region FROM region_dim
ORDER BY INFO, VALUE;

-- Basic data quality checks
SELECT 
    'Data Quality Check' as CHECK_TYPE,
    CASE 
        WHEN COUNT(*) > 0 THEN 'PASS ✓'
        ELSE 'FAIL ✗' 
    END as RESULT,
    COUNT(*)::STRING as RECORD_COUNT
FROM daily_revenue
WHERE date IS NOT NULL AND revenue IS NOT NULL

UNION ALL

SELECT 
    'Revenue Range Check',
    CASE 
        WHEN MIN(revenue) > 0 AND MAX(revenue) < 1000000 THEN 'PASS ✓'
        ELSE 'FAIL ✗'
    END,
    CONCAT('Min: $', MIN(revenue)::STRING, ', Max: $', MAX(revenue)::STRING)
FROM daily_revenue

UNION ALL

SELECT 
    'Date Range Check', 
    CASE 
        WHEN DATEDIFF(day, MIN(date), MAX(date)) > 30 THEN 'PASS ✓'
        ELSE 'FAIL ✗'  
    END,
    CONCAT('From: ', MIN(date)::STRING, ' To: ', MAX(date)::STRING)
FROM daily_revenue;

/*--
Next Steps:
1. Run 03_create_cortex_search.sql to create search service
2. Upload revenue_timeseries.yaml semantic model to @raw_data stage
3. Create Streamlit app using cortex_analyst_demo.py
--*/