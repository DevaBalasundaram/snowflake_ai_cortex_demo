/*--
Snowflake Cortex Analyst Demo Setup Script 3/3
Create Cortex Search service for improved literal string matching
--*/

-- Set role and context
USE ROLE cortex_user_role;
USE DATABASE cortex_analyst_demo;
USE SCHEMA cortex_analyst_demo.revenue_timeseries;
USE WAREHOUSE cortex_analyst_wh;

/*--
Create Cortex Search Service

Cortex Search helps improve literal string searches to help Cortex Analyst 
generate more accurate SQL queries. When users ask questions that require 
filtering on exact values, the search service can help find the correct 
literals even if they don't match exactly.

For example:
User asks: "Show me revenue for electronics"  
Search service helps match "electronics" to "Electronics" in the data
--*/

-- Create search service for product lines
CREATE OR REPLACE CORTEX SEARCH SERVICE product_line_search_service
ON product_dim
WAREHOUSE = cortex_analyst_wh
TARGET_LAG = '1 hour'                        -- Refresh every hour
AS (
    SELECT DISTINCT 
        product_line AS product_dimension 
    FROM product_dim
    WHERE product_line IS NOT NULL
);

-- Create search service for sales regions  
CREATE OR REPLACE CORTEX SEARCH SERVICE sales_region_search_service
ON region_dim
WAREHOUSE = cortex_analyst_wh
TARGET_LAG = '1 hour'
AS (
    SELECT DISTINCT 
        sales_region AS region_dimension,
        state
    FROM region_dim 
    WHERE sales_region IS NOT NULL
);

-- Wait a moment for services to initialize
SELECT SYSTEM$WAIT(2);

-- Verify search services were created successfully
SHOW CORTEX SEARCH SERVICES;

-- Test the search services with sample queries
SELECT 
    'Testing product line search service:' as TEST_TYPE,
    '' as QUERY,
    '' as RESULTS
    
UNION ALL

SELECT 
    '',
    'electronics' as search_query,
    ARRAY_TO_STRING(
        PARSE_JSON(
            SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                'product_line_search_service', 
                'electronics',
                1
            )
        )['results'][0]['chunk']::STRING, 
        ''
    ) as search_result

UNION ALL

SELECT 
    '',
    'clothing' as search_query, 
    ARRAY_TO_STRING(
        PARSE_JSON(
            SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                'product_line_search_service',
                'clothing', 
                1
            )
        )['results'][0]['chunk']::STRING,
        ''
    ) as search_result

UNION ALL

SELECT 
    'Testing region search service:' as TEST_TYPE,
    '' as QUERY, 
    '' as RESULTS
    
UNION ALL

SELECT 
    '',
    'north' as search_query,
    ARRAY_TO_STRING(
        PARSE_JSON(
            SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                'sales_region_search_service',
                'north',
                1  
            )
        )['results'][0]['chunk']::STRING,
        ''
    ) as search_result;

-- Show all objects created for the demo
SELECT 'Demo Setup Complete!' as STATUS, '' as DETAILS
UNION ALL
SELECT 'Database:', 'cortex_analyst_demo'
UNION ALL  
SELECT 'Schema:', 'revenue_timeseries'
UNION ALL
SELECT 'Warehouse:', 'cortex_analyst_wh' 
UNION ALL
SELECT 'Tables:', '3 (daily_revenue, product_dim, region_dim)'
UNION ALL
SELECT 'Search Services:', '2 (product_line, sales_region)'
UNION ALL
SELECT 'Stage:', 'raw_data';

-- Display row counts for verification
SELECT 
    TABLE_NAME,
    TABLE_ROWS as ROW_COUNT,
    CASE 
        WHEN TABLE_ROWS > 0 THEN '✓ Ready'
        ELSE '✗ Empty' 
    END as STATUS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'REVENUE_TIMESERIES'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

/*--
Setup Complete! 🎉

Next Steps:
1. Upload revenue_timeseries.yaml to @raw_data stage
2. Create Streamlit app with cortex_analyst_demo.py  
3. Start asking natural language questions!

Sample questions to try:
- "What questions can I ask?"
- "What was our total revenue last month?"
- "Which product line has the highest profit margin?" 
- "Show me revenue trends by region"
- "Compare actual vs forecasted revenue"
--*/