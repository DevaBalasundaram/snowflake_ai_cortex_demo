/*--
Snowflake Cortex Analyst Demo Setup Script 1/3
Database, schema, warehouse, role, and table creation
--*/

-- Switch to security admin role to create roles
USE ROLE SECURITYADMIN;

-- Create custom role for Cortex users
CREATE ROLE IF NOT EXISTS cortex_user_role;

-- Grant Cortex capabilities to the role
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE cortex_user_role;

-- Grant role to current user (replace <user> with your username)
GRANT ROLE cortex_user_role TO USER CURRENT_USER();

-- Switch to system admin for resource creation
USE ROLE SYSADMIN;

-- Create demo database
CREATE OR REPLACE DATABASE cortex_analyst_demo
    COMMENT = 'Demo database for Snowflake Cortex Analyst quickstart';

-- Create schema for revenue timeseries data
CREATE OR REPLACE SCHEMA cortex_analyst_demo.revenue_timeseries
    COMMENT = 'Schema containing revenue analytics tables';

-- Create warehouse for Cortex operations
CREATE OR REPLACE WAREHOUSE cortex_analyst_wh
    WAREHOUSE_SIZE = 'SMALL'              -- Small is sufficient for Cortex LLM functions
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 60                     -- Auto-suspend after 1 minute
    AUTO_RESUME = TRUE                    -- Auto-resume when needed
    INITIALLY_SUSPENDED = TRUE            -- Start suspended to save costs
    COMMENT = 'Warehouse for Cortex Analyst demo operations';

-- Grant permissions to cortex_user_role
GRANT USAGE ON WAREHOUSE cortex_analyst_wh TO ROLE cortex_user_role;
GRANT OPERATE ON WAREHOUSE cortex_analyst_wh TO ROLE cortex_user_role;
GRANT OWNERSHIP ON SCHEMA cortex_analyst_demo.revenue_timeseries TO ROLE cortex_user_role;
GRANT OWNERSHIP ON DATABASE cortex_analyst_demo TO ROLE cortex_user_role;

-- Switch to cortex_user_role for object creation
USE ROLE cortex_user_role;

-- Set context
USE WAREHOUSE cortex_analyst_wh;
USE DATABASE cortex_analyst_demo;
USE SCHEMA cortex_analyst_demo.revenue_timeseries;

-- Create stage for raw data and semantic model files
CREATE OR REPLACE STAGE raw_data 
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for CSV data files and semantic model YAML';

/*--
Table Creation - Star Schema Design
Fact table: daily_revenue
Dimension tables: product_dim, region_dim
--*/

-- Fact table: Daily revenue data
CREATE OR REPLACE TABLE daily_revenue (
    date DATE NOT NULL COMMENT 'Transaction date',
    revenue FLOAT COMMENT 'Total revenue for the day',
    cogs FLOAT COMMENT 'Cost of goods sold',
    forecasted_revenue FLOAT COMMENT 'Forecasted revenue amount',
    product_id INT NOT NULL COMMENT 'Foreign key to product dimension',
    region_id INT NOT NULL COMMENT 'Foreign key to region dimension'
) COMMENT = 'Daily revenue facts by product and region';

-- Dimension table: Product information
CREATE OR REPLACE TABLE product_dim (
    product_id INT NOT NULL PRIMARY KEY COMMENT 'Unique product identifier',
    product_line VARCHAR(16777216) COMMENT 'Product category or line'
) COMMENT = 'Product dimension table';

-- Dimension table: Region information  
CREATE OR REPLACE TABLE region_dim (
    region_id INT NOT NULL PRIMARY KEY COMMENT 'Unique region identifier',
    sales_region VARCHAR(16777216) COMMENT 'Sales region name',
    state VARCHAR(16777216) COMMENT 'State or province'
) COMMENT = 'Region dimension table';

-- Create foreign key relationships (informational - Snowflake doesn't enforce)
ALTER TABLE daily_revenue 
ADD CONSTRAINT fk_product 
FOREIGN KEY (product_id) REFERENCES product_dim(product_id) NOT ENFORCED;

ALTER TABLE daily_revenue 
ADD CONSTRAINT fk_region 
FOREIGN KEY (region_id) REFERENCES region_dim(region_id) NOT ENFORCED;

-- Grant select permissions on tables to cortex_user_role
GRANT SELECT ON ALL TABLES IN SCHEMA cortex_analyst_demo.revenue_timeseries TO ROLE cortex_user_role;

-- Display created objects
SELECT 'Database created: ' || DATABASE_NAME as STATUS FROM INFORMATION_SCHEMA.DATABASES WHERE DATABASE_NAME = 'CORTEX_ANALYST_DEMO'
UNION ALL
SELECT 'Schema created: ' || SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'REVENUE_TIMESERIES'
UNION ALL 
SELECT 'Tables created: ' || COUNT(*)::STRING FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'REVENUE_TIMESERIES';

SHOW TABLES;

/*--
Next Steps:
1. Upload CSV files to the @raw_data stage using Snowsight UI
2. Run 02_load_data.sql to load data into tables
3. Run 03_create_cortex_search.sql to create search service
--*/