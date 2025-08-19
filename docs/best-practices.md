# Best Practices for Snowflake Cortex Analyst

This guide provides production-ready best practices for implementing Snowflake Cortex Analyst in your organization.

## 🎯 Semantic Model Design

### Start Simple, Scale Gradually
- Begin with 2-3 core tables that answer 80% of business questions
- Add complexity incrementally based on user feedback
- Test extensively with real users before expanding

### Business-Focused Naming
```yaml
# ✅ Good - Business terms
- name: monthly_revenue
  description: "Total monthly sales revenue"
  synonyms: ["sales", "income", "monthly sales"]

# ❌ Avoid - Technical column names  
- name: rev_amt_sum
  description: "Revenue amount sum"
```

### Rich Descriptions and Synonyms
```yaml
measures:
  - name: customer_acquisition_cost
    expr: marketing_spend / new_customers
    description: "Cost to acquire each new customer (CAC) - marketing spend divided by new customers acquired"
    synonyms: ["CAC", "acquisition cost", "cost per customer", "customer cost"]
    data_type: number
```

### Sample Values for Better Context
```yaml
dimensions:
  - name: product_category
    expr: category
    description: "Primary product category"
    sample_values: ["Electronics", "Clothing", "Home & Garden", "Sports"]
    data_type: varchar
```

## 🔒 Security & Governance

### Role-Based Access Control
```sql
-- Create dedicated roles for different user groups
CREATE ROLE cortex_business_users;
CREATE ROLE cortex_analysts;  
CREATE ROLE cortex_admins;

-- Grant appropriate Cortex permissions
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE cortex_business_users;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE cortex_analysts;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE cortex_admins;

-- Limit data access using views
CREATE SECURE VIEW public_revenue_data AS 
SELECT date, revenue, product_line, region 
FROM detailed_revenue_data
WHERE is_public = TRUE;
```

### Data Masking for Sensitive Fields
```sql
-- Create masking policy for PII
CREATE MASKING POLICY customer_name_mask AS (val string) RETURNS string ->
  CASE 
    WHEN CURRENT_ROLE() IN ('ANALYSTS', 'ADMINS') THEN val
    ELSE '***MASKED***'
  END;

-- Apply to semantic model base tables
ALTER TABLE customer_data MODIFY COLUMN customer_name 
SET MASKING POLICY customer_name_mask;
```

### Audit and Monitoring
```sql
-- Monitor Cortex usage
CREATE VIEW cortex_usage_monitoring AS
SELECT 
  user_name,
  query_text,
  start_time,
  credits_used,
  execution_status
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text LIKE '%CORTEX.ANALYST%'
  AND start_time >= DATEADD(day, -30, CURRENT_DATE())
ORDER BY start_time DESC;
```

## 🚀 Performance Optimization

### Warehouse Sizing
```sql
-- Small warehouses are optimal for LLM functions
CREATE WAREHOUSE cortex_wh 
  WAREHOUSE_SIZE = 'SMALL'           -- Don't use larger sizes
  AUTO_SUSPEND = 60                  -- Suspend quickly
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- For heavy analytics workloads, use separate warehouse
CREATE WAREHOUSE analytics_wh
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 300;
```

### Query Result Caching
```sql
-- Enable result caching to reduce costs
ALTER WAREHOUSE cortex_wh SET AUTO_SUSPEND = 60;

-- Use materialized views for common aggregations
CREATE MATERIALIZED VIEW monthly_revenue_summary AS
SELECT 
  DATE_TRUNC('MONTH', date) as month,
  product_line,
  region,
  SUM(revenue) as total_revenue,
  AVG(revenue) as avg_daily_revenue
FROM daily_revenue_facts 
GROUP BY 1, 2, 3;
```

### Search Service Optimization
```sql
-- Create targeted search services
CREATE CORTEX SEARCH SERVICE product_search
ON product_dim
WAREHOUSE = cortex_wh
TARGET_LAG = '6 hours'        -- Less frequent refresh for stable data
AS (
  SELECT DISTINCT 
    product_name,
    product_category,
    brand
  FROM product_dim
  WHERE is_active = TRUE
);
```

## 💰 Cost Management

### Resource Monitoring
```sql
-- Set up resource monitors
CREATE RESOURCE MONITOR cortex_monthly_budget
  CREDIT_QUOTA = 100            -- Set appropriate limit
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS 
    ON 75 PERCENT DO NOTIFY
    ON 90 PERCENT DO SUSPEND
    ON 100 PERCENT DO SUSPEND_IMMEDIATE;

-- Apply to Cortex warehouses
ALTER WAREHOUSE cortex_wh SET RESOURCE_MONITOR = cortex_monthly_budget;
```

### Usage Analytics
```sql
-- Track Cortex costs by user/department
CREATE VIEW cortex_cost_analysis AS
SELECT 
  DATE_TRUNC('day', start_time) as usage_date,
  user_name,
  database_name,
  COUNT(*) as query_count,
  SUM(credits_used_cloud_services) as cortex_credits,
  AVG(execution_time_millis) as avg_execution_time
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text LIKE '%CORTEX.ANALYST%'
  AND start_time >= DATEADD(month, -1, CURRENT_DATE())
GROUP BY 1, 2, 3
ORDER BY cortex_credits DESC;
```

## 🎓 User Training & Adoption

### Question Templates
Provide users with effective question patterns:

**Good Questions:**
```
✅ "What was our revenue in the Electronics category last quarter?"
✅ "Show me the top 5 sales regions by profit margin"  
✅ "Compare Q1 vs Q2 revenue by product line"
✅ "Which customers have the highest lifetime value?"
```

**Questions to Improve:**
```
❌ "Show me some data" → "Show me monthly revenue trends"
❌ "What happened?" → "What caused the revenue drop in March?"
❌ "Everything about sales" → "Compare sales performance by region"
```

### Progressive Disclosure
Start users with simple questions, then introduce complexity:

**Level 1 - Basic Aggregations:**
- "What was total revenue last month?"
- "How many orders did we have yesterday?"

**Level 2 - Comparisons:**  
- "Compare this quarter vs last quarter revenue"
- "Which product line grew the most?"

**Level 3 - Complex Analysis:**
- "Show cohort retention rates by acquisition channel"
- "Calculate customer lifetime value by segment"

## 🔧 Implementation Patterns

### Semantic Model Structure
```
semantic_models/
├── core/
│   ├── sales_analytics.yaml          # Core revenue/sales metrics
│   ├── customer_analytics.yaml       # Customer behavior and segmentation  
│   └── operational_metrics.yaml      # Operations and efficiency metrics
├── departmental/
│   ├── marketing_campaigns.yaml      # Marketing-specific metrics
│   ├── finance_reporting.yaml        # Financial reporting requirements
│   └── product_analytics.yaml        # Product performance metrics
└── specialized/
    ├── cohort_analysis.yaml          # Advanced cohort analytics
    └── forecasting_models.yaml       # Predictive analytics
```

### Version Control
```yaml
# Include version metadata in semantic models
name: "Sales Analytics v2.1"
description: "Core sales and revenue analytics semantic model"
version: "2.1.0"
last_updated: "2025-08-18"
created_by: "Data Team"
approved_by: "Business Stakeholder"

# Track changes in commit messages
# git commit -m "feat: add customer lifetime value calculations to sales model v2.1"
```

### Testing Strategy
```sql
-- Create test suite for semantic models
CREATE SCHEMA cortex_testing;

-- Test data validation
CREATE TABLE test_scenarios (
  scenario_name STRING,
  test_question STRING,
  expected_sql_pattern STRING,
  expected_result_count INT,
  test_status STRING
);

-- Example test cases
INSERT INTO test_scenarios VALUES
  ('revenue_aggregation', 'What was total revenue last month?', '%SUM(revenue)%', NULL, 'pending'),
  ('product_filtering', 'Show me Electronics revenue', '%product_line%Electronics%', NULL, 'pending'),
  ('time_grouping', 'Monthly revenue trends', '%DATE_TRUNC%MONTH%', 12, 'pending');
```

## 📊 Monitoring & Analytics

### Success Metrics
Track these KPIs to measure Cortex Analyst adoption:

- **Usage Metrics:**
  - Daily/monthly active users
  - Questions asked per user per day
  - Query success rate

- **Business Impact:**  
  - Time to insight (compared to traditional BI)
  - Self-service query ratio
  - Data team request reduction

- **Quality Metrics:**
  - Query accuracy feedback
  - User satisfaction scores  
  - SQL query execution success rate

### Dashboard Creation
```sql
-- Create monitoring dashboard data
CREATE VIEW cortex_adoption_dashboard AS
SELECT 
  DATE_TRUNC('week', start_time) as week,
  COUNT(DISTINCT user_name) as active_users,
  COUNT(*) as total_queries,
  AVG(execution_time_millis/1000) as avg_response_time,
  COUNT(CASE WHEN execution_status = 'SUCCESS' THEN 1 END) / COUNT(*) * 100 as success_rate
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY  
WHERE query_text LIKE '%CORTEX.ANALYST%'
  AND start_time >= DATEADD(month, -3, CURRENT_DATE())
GROUP BY week
ORDER BY week;
```

## 🆘 Troubleshooting Guide

### Common Issues & Solutions

**Issue: "Semantic model not found"**
```sql
-- Check stage contents and permissions
LIST @your_stage;
SHOW GRANTS ON STAGE your_stage;

-- Verify file path format
-- ✅ Correct: @database.schema.stage/file.yaml
-- ❌ Wrong: @stage/file.yaml (missing database.schema)
```

**Issue: "Poor query accuracy"**  
- Add more descriptive field descriptions
- Include business synonyms for technical terms
- Add sample values to dimension fields
- Create verified queries for common patterns

**Issue: "High token costs"**
- Use smaller warehouses (SMALL is optimal)
- Optimize semantic model complexity
- Set resource monitors and alerts
- Cache common query results

**Issue: "Slow response times"**
- Check warehouse auto-suspend settings
- Verify search services are running
- Optimize base table performance
- Review query complexity

## 🚀 Advanced Features

### Custom Instructions
```yaml
# Add custom instructions to semantic model
custom_instructions: |
  When users ask about revenue, always include profit margins in the analysis.
  For time-based questions, default to the last complete month unless specified.
  When comparing periods, show percentage change calculations.
  Always format currency values with appropriate symbols.
```

### Multi-Model Architecture
```python
# Route questions to appropriate semantic models
def get_semantic_model(question: str) -> str:
    if any(word in question.lower() for word in ['customer', 'retention', 'churn']):
        return '@customer_analytics.yaml'
    elif any(word in question.lower() for word in ['campaign', 'marketing', 'lead']):
        return '@marketing_analytics.yaml'  
    else:
        return '@sales_analytics.yaml'
```

---

**Remember:** Start simple, gather feedback, iterate quickly. Cortex Analyst works best when semantic models reflect real business terminology and questions.