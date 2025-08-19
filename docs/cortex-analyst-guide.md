# Snowflake Cortex Analyst Quickstart Guide

## Table of Contents
1. [What is Snowflake?](#what-is-snowflake)
2. [What is Snowflake Cortex AI?](#what-is-snowflake-cortex-ai)
3. [What is Cortex Analyst?](#what-is-cortex-analyst)
4. [Prerequisites and Permissions](#prerequisites-and-permissions)
5. [Setup Guide](#setup-guide)
6. [Creating Your First Semantic Model](#creating-your-first-semantic-model)
7. [Testing with Streamlit App](#testing-with-streamlit-app)
8. [Best Practices](#best-practices)
9. [Cost Considerations](#cost-considerations)
10. [Troubleshooting](#troubleshooting)

---

## What is Snowflake?

**Snowflake** is a fully managed, cloud-native data platform that provides:
- **Zero Infrastructure Management**: No hardware or software to manage
- **Scalable Architecture**: Separates compute, storage, and cloud services
- **Multi-Cloud Support**: Works across AWS, Azure, and Google Cloud
- **Built-in Security & Governance**: Enterprise-grade security and compliance
- **Pay-for-What-You-Use**: Cost-effective pricing model

### Key Benefits:
- Highly performant and scalable
- No upfront infrastructure costs
- Automatic scaling and optimization
- Built-in data sharing capabilities

---

## What is Snowflake Cortex AI?

**Snowflake Cortex AI** is Snowflake's built-in AI/ML engine that enables:
- **Large Language Models (LLMs)**: Access to industry-leading models like Llama, Mistral, and Snowflake Arctic
- **AI Functions**: Text processing, summarization, translation, sentiment analysis
- **No Data Movement**: All AI processing happens within Snowflake's secure environment
- **Seamless Integration**: Works directly with your existing Snowflake data

### Cortex AI Features:
- Pre-trained LLMs ready to use
- No-code/low-code ML capabilities
- Built-in security and governance
- Real-time AI-driven insights

---

## What is Cortex Analyst?

**Cortex Analyst** is a fully managed conversational AI service that allows business users to:
- **Query Data in Natural Language**: Ask questions in plain English
- **Get Accurate SQL Results**: Powered by state-of-the-art LLMs with high text-to-SQL accuracy
- **Self-Service Analytics**: Reduces dependency on data teams
- **REST API Integration**: Easily integrate into existing applications

### Key Capabilities:
- Natural language to SQL conversion
- Industry-leading accuracy
- Conversational interface
- Integration with BI tools and custom applications

---

## Prerequisites and Permissions

### Account Requirements:
- **Snowflake Enterprise Edition** (or higher)
- Account with Cortex features enabled
- Access to a supported region (AWS: us-east-1, us-west-2, eu-west-1, eu-central-1, ap-southeast-2, ap-northeast-1; Azure: East US 2, West Europe)

### Required Roles and Permissions:

#### 1. CORTEX_USER Role
```sql
-- The CORTEX_USER role is granted to PUBLIC by default
-- If you need to restrict access:
USE ROLE ACCOUNTADMIN;
REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE PUBLIC;

-- Grant to specific roles:
CREATE ROLE cortex_analyst_role;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE cortex_analyst_role;
GRANT ROLE cortex_analyst_role TO USER <your_username>;
```

#### 2. Additional Permissions Needed:
- **USAGE** on database and schema
- **SELECT** on all tables referenced in semantic model
- **READ/WRITE** on stages (if storing semantic model files)
- **USAGE** on warehouses

### User Setup Checklist:
- [ ] Snowflake account with Enterprise edition or higher
- [ ] CORTEX_USER role granted
- [ ] Access to create databases, schemas, warehouses
- [ ] Basic familiarity with SQL and YAML

---

## Setup Guide

### Step 1: Create Required Objects

```sql
-- Use appropriate admin roles
USE ROLE SECURITYADMIN;

-- Create custom role for Cortex users
CREATE ROLE cortex_user_role;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE cortex_user_role;
GRANT ROLE cortex_user_role TO USER <your_username>;

USE ROLE SYSADMIN;

-- Create demo database
CREATE OR REPLACE DATABASE cortex_analyst_demo;
CREATE OR REPLACE SCHEMA cortex_analyst_demo.revenue_timeseries;

-- Create warehouse
CREATE OR REPLACE WAREHOUSE cortex_analyst_wh
  WAREHOUSE_SIZE = 'SMALL'  -- Start small to control costs
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- Grant necessary permissions
GRANT USAGE ON WAREHOUSE cortex_analyst_wh TO ROLE cortex_user_role;
GRANT USAGE ON DATABASE cortex_analyst_demo TO ROLE cortex_user_role;
GRANT USAGE ON SCHEMA cortex_analyst_demo.revenue_timeseries TO ROLE cortex_user_role;
```

### Step 2: Create Sample Tables

```sql
USE ROLE cortex_user_role;
USE WAREHOUSE cortex_analyst_wh;
USE DATABASE cortex_analyst_demo;
USE SCHEMA revenue_timeseries;

-- Create stage for data and semantic model files
CREATE OR REPLACE STAGE raw_data DIRECTORY = (ENABLE = TRUE);

-- Create fact table
CREATE OR REPLACE TABLE daily_revenue (
    date DATE,
    revenue FLOAT,
    cogs FLOAT,
    forecasted_revenue FLOAT,
    product_id INT,
    region_id INT
);

-- Create dimension tables
CREATE OR REPLACE TABLE product_dim (
    product_id INT,
    product_line VARCHAR(50)
);

CREATE OR REPLACE TABLE region_dim (
    region_id INT,
    sales_region VARCHAR(50),
    state VARCHAR(50)
);
```

### Step 3: Load Sample Data

```sql
-- Insert sample data (replace with your actual data loading process)
INSERT INTO product_dim VALUES 
    (1, 'Electronics'),
    (2, 'Clothing'),
    (3, 'Home Appliances'),
    (4, 'Books');

INSERT INTO region_dim VALUES 
    (1, 'North', 'California'),
    (2, 'South', 'Texas'),
    (3, 'East', 'New York'),
    (4, 'West', 'Oregon');

INSERT INTO daily_revenue VALUES 
    ('2024-01-01', 10000, 6000, 12000, 1, 1),
    ('2024-01-02', 8000, 5000, 9000, 2, 2),
    ('2024-01-03', 15000, 8000, 14000, 3, 1),
    ('2024-01-04', 12000, 7000, 13000, 1, 3);
```

### Step 4: Create Cortex Search Service (Optional)

```sql
-- Create search service for improved literal string matching
CREATE OR REPLACE CORTEX SEARCH SERVICE product_line_search_service
ON product_dim
WAREHOUSE = cortex_analyst_wh
TARGET_LAG = '1 hour'
AS (
    SELECT DISTINCT product_line FROM product_dim
);
```

---

## Creating Your First Semantic Model

### What is a Semantic Model?

A semantic model is a YAML file that maps business terminology to your database schema. It tells Cortex Analyst:
- Which tables and columns to use
- How to interpret business terms
- Relationships between tables
- Default aggregations and calculations

### Basic Semantic Model Structure

Create a file called `revenue_semantic_model.yaml`:

```yaml
name: "Revenue Analysis"
description: "Semantic model for revenue and sales analysis"

tables:
  - name: daily_revenue
    base_table: cortex_analyst_demo.revenue_timeseries.daily_revenue
    description: "Daily revenue data by product and region"
    dimensions:
      - name: date
        expr: date
        description: "Transaction date"
        data_type: date
    measures:
      - name: daily_revenue
        expr: revenue
        description: "Total revenue for the day"
        synonyms: ["sales", "income"]
        default_aggregation: sum
        data_type: number
      - name: cost_of_goods_sold
        expr: cogs
        description: "Cost of goods sold"
        synonyms: ["cogs", "costs"]
        default_aggregation: sum
        data_type: number
      - name: daily_profit
        expr: revenue - cogs
        description: "Profit calculated as revenue minus costs"
        data_type: number
        default_aggregation: sum

  - name: product_dim
    base_table: cortex_analyst_demo.revenue_timeseries.product_dim
    description: "Product dimension table"
    dimensions:
      - name: product_line
        expr: product_line
        description: "Product category or line"
        data_type: varchar
        sample_values: ["Electronics", "Clothing", "Home Appliances", "Books"]

relationships:
  - name: revenue_to_product
    left_table: daily_revenue
    right_table: product_dim
    relationship_columns:
      - left_column: product_id
        right_column: product_id
    join_type: left_outer
    relationship_type: many_to_one
```

### Upload Semantic Model to Stage

```sql
-- Upload your YAML file to the stage using Snowsight UI or SnowSQL
-- File should be uploaded to @cortex_analyst_demo.revenue_timeseries.raw_data/revenue_semantic_model.yaml
```

---

## Testing with Streamlit App

### Create a Streamlit App in Snowflake

1. In Snowsight, go to **Streamlit Apps**
2. Click **+ Streamlit App**
3. Name your app: `Cortex Analyst Demo`
4. Use the following code:

```python
import streamlit as st
import json
from snowflake.snowpark.context import get_active_session
from snowflake.core import Root
import snowflake.permissions as permissions

# Get Snowflake session
session = get_active_session()

# API Configuration
API_ENDPOINT = "/api/v2/cortex/analyst/message"
API_TIMEOUT = 30000

st.title("🧠 Cortex Analyst Demo")
st.caption("Ask questions about your data in natural language!")

# Initialize session state
if "messages" not in st.session_state:
    st.session_state.messages = []

# Semantic model path
semantic_model_path = "@cortex_analyst_demo.revenue_timeseries.raw_data/revenue_semantic_model.yaml"

# Function to call Cortex Analyst API
def get_analyst_response(messages):
    request_body = {
        "messages": messages,
        "semantic_model_file": semantic_model_path,
    }
    
    resp = session.sql(f"""
        SELECT SNOWFLAKE.CORTEX.ANALYST(
            '{json.dumps(messages)}',
            '{semantic_model_path}'
        ) as response
    """).collect()
    
    return json.loads(resp[0]['RESPONSE'])

# Chat interface
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.write(message["content"])

# User input
if prompt := st.chat_input("Ask a question about your revenue data..."):
    st.session_state.messages.append({"role": "user", "content": prompt})
    
    with st.chat_message("user"):
        st.write(prompt)
    
    with st.chat_message("assistant"):
        try:
            response = get_analyst_response(st.session_state.messages)
            st.write(response["message"])
            
            # Display SQL query if available
            if "sql" in response:
                st.code(response["sql"], language="sql")
            
            st.session_state.messages.append({"role": "assistant", "content": response["message"]})
        except Exception as e:
            st.error(f"Error: {str(e)}")

# Sample questions
st.sidebar.header("Try these sample questions:")
st.sidebar.markdown("""
- What was the total revenue last month?
- Which product line has the highest profit margin?
- Show me daily revenue trends
- What is the average cost of goods sold by product?
""")
```

---

## Best Practices

### Semantic Model Best Practices

1. **Start Simple**: Begin with essential tables and gradually expand
2. **Use Business Language**: Include synonyms that match user terminology
3. **Provide Context**: Add detailed descriptions for tables and columns
4. **Include Sample Values**: Help the model understand data patterns
5. **Optimize Relationships**: Define clear table relationships
6. **Add Verified Queries**: Include known good question-answer pairs

### Performance Optimization

1. **Use Appropriate Warehouse Sizes**: 
   - Start with SMALL warehouses
   - LLM functions don't benefit from larger warehouses
2. **Limit Scope**: Keep semantic models focused on specific use cases
3. **Monitor Usage**: Track credit consumption regularly

### Security Best Practices

1. **Role-Based Access Control**: Limit CORTEX_USER role to appropriate users
2. **Data Governance**: Use Snowflake's RBAC for underlying data access
3. **Audit Usage**: Monitor who is using Cortex Analyst and how

---

## Cost Considerations

### How Cortex Analyst Pricing Works

**Token-Based Pricing**: Cortex Analyst charges based on tokens processed (≈4 characters = 1 token)

### Typical Costs (As of 2025):
- **Input tokens**: ~$0.002 per 1K tokens
- **Output tokens**: ~$0.008 per 1K tokens
- **Warehouse compute**: Standard Snowflake compute rates apply

### Cost Management Tips:

1. **Use Smaller Warehouses**: SMALL warehouses are sufficient for most Cortex operations
2. **Monitor Credit Consumption**: 
   ```sql
   -- Check Cortex credit usage
   SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_HISTORY 
   WHERE SERVICE_TYPE = 'AI_SERVICES'
   ORDER BY START_TIME DESC;
   ```
3. **Set Resource Monitors**: Create monitors to track and limit spending
4. **Optimize Queries**: Well-designed semantic models reduce token usage

### Sample Cost Calculation:
- Simple question (50 tokens): ~$0.0001
- Complex analysis (500 tokens): ~$0.001
- Daily usage (100 queries): ~$0.01-$0.10

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Permission Denied Errors
```
Error: Insufficient privileges to operate on CORTEX_USER
```
**Solution**: Ensure CORTEX_USER role is granted to your role

#### 2. Semantic Model Not Found
```
Error: Cannot find semantic model file
```
**Solution**: 
- Verify file is uploaded to correct stage
- Check file path syntax
- Ensure READ permissions on stage

#### 3. Poor Query Accuracy
**Solutions**:
- Improve semantic model descriptions
- Add more synonyms
- Include sample values
- Add verified queries

#### 4. High Costs
**Solutions**:
- Use smaller warehouses
- Optimize semantic models
- Set up resource monitors
- Monitor token usage

### Getting Help

1. **Snowflake Documentation**: docs.snowflake.com
2. **Community**: community.snowflake.com
3. **Support**: Submit cases through Snowflake Support Portal
4. **Quickstart Guides**: quickstarts.snowflake.com

---

## Next Steps

1. **Expand Your Semantic Model**: Add more tables and relationships
2. **Create Production Apps**: Build custom applications using the REST API
3. **Implement Governance**: Set up proper access controls and monitoring
4. **Optimize Costs**: Monitor usage and optimize configurations
5. **Train Users**: Educate business users on effective questioning techniques

---

## Additional Resources

- [Snowflake Cortex Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex)
- [Cortex Analyst API Reference](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Semantic Model Specification](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/semantic-model-spec)
- [Official Quickstart Guide](https://quickstarts.snowflake.com/guide/getting_started_with_cortex_analyst/index.html)

---

*This guide provides a comprehensive foundation for getting started with Snowflake Cortex Analyst. For the latest updates and detailed technical specifications, always refer to the official Snowflake documentation.*