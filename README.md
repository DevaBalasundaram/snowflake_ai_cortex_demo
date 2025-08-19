# Snowflake Cortex Analyst Demo Repository

A comprehensive guide and demo application for getting started with **Snowflake Cortex Analyst** - the conversational AI service for business analytics.

![Cortex Analyst Demo](assets/cortex-flow.png)

## 🚀 Quick Start

This repository contains everything you need to set up and demo Snowflake Cortex Analyst, including:

- **Complete setup scripts** for databases, warehouses, and sample data
- **Sample semantic model** with best practices  
- **Interactive Streamlit application** for natural language queries
- **Comprehensive documentation** and presentation materials
- **Real sample data** for revenue analytics use case

## 📁 Repository Structure

```
├── README.md                          # This file
├── docs/                             # Documentation
│   ├── quickstart-guide.md           # Comprehensive setup guide
│   ├── presentation-agenda.md        # 30-min demo presentation
│   └── best-practices.md             # Implementation best practices
├── sql/                              # SQL Scripts
│   ├── 01_create_snowflake_objects.sql
│   ├── 02_load_data.sql
│   └── 03_create_cortex_search.sql
├── data/                             # Sample data files
│   ├── daily_revenue.csv
│   ├── product.csv
│   └── region.csv
├── semantic_models/                  # YAML configurations
│   └── revenue_timeseries.yaml
├── streamlit/                        # Demo application
│   └── cortex_analyst_demo.py
├── assets/                           # Images and diagrams
└── LICENSE
```

## 🎯 What is Cortex Analyst?

**Cortex Analyst** is a fully managed conversational AI service in Snowflake that provides:

- **Natural Language to SQL**: Ask questions in plain English, get accurate SQL results
- **Self-Service Analytics**: Empowers business users without SQL knowledge  
- **Industry-Leading Accuracy**: Powered by state-of-the-art LLMs with agentic AI setup
- **Enterprise Security**: Built-in governance and role-based access controls
- **REST API Integration**: Easy integration into existing applications

### Key Benefits

✅ **Democratizes Data Access** - Business users can query data independently  
✅ **Reduces IT Bottlenecks** - Fewer ad-hoc requests to data teams  
✅ **Faster Time to Insights** - Real-time answers to business questions  
✅ **Enterprise-Grade Security** - Snowflake's built-in security and governance  

## 🛠️ Prerequisites

- **Snowflake Account**: Enterprise Edition or higher
- **Permissions**: CORTEX_USER role (granted to PUBLIC by default)
- **Supported Region**: AWS (us-east-1, us-west-2, eu-west-1, eu-central-1, ap-southeast-2, ap-northeast-1) or Azure (East US 2, West Europe)

## ⚡ Quick Setup (15 minutes)

### 1. Clone this repository
```bash
git clone https://github.com/your-org/snowflake-cortex-analyst-demo.git
cd snowflake-cortex-analyst-demo
```

### 2. Run setup scripts in Snowsight
Execute the SQL scripts in order:
1. `sql/01_create_snowflake_objects.sql` - Creates database, schema, warehouse, tables
2. Upload data files from `data/` folder to the `@raw_data` stage  
3. `sql/02_load_data.sql` - Loads sample data into tables
4. `sql/03_create_cortex_search.sql` - Creates search service for better accuracy

### 3. Upload semantic model
Upload `semantic_models/revenue_timeseries.yaml` to the `@raw_data` stage

### 4. Create Streamlit app
- Go to Streamlit Apps in Snowsight
- Create new app with code from `streamlit/cortex_analyst_demo.py`

### 5. Start asking questions!
Try these sample questions:
- "What questions can I ask?"
- "What was our total revenue last month?"  
- "Which product line has the highest profit margin?"
- "Show me revenue trends by region"

## 📊 Demo Use Case: Revenue Analytics

This demo uses a **revenue analytics** scenario with:

**Sample Data:**
- **Daily Revenue Facts**: Date, revenue, costs, forecasted revenue by product/region
- **Product Dimension**: Product lines (Electronics, Clothing, Home Appliances, etc.)
- **Region Dimension**: Sales regions and states

**Sample Questions You Can Ask:**
```
Business Questions:
• "What was our total revenue last month?"
• "Which product line generates the most profit?"  
• "Show me revenue trends over time"
• "What is our average daily revenue by region?"
• "Which products have the highest cost of goods sold?"

Analytical Questions:  
• "Calculate profit margin by product line"
• "Show me the top 5 days by revenue"
• "What's the revenue growth rate month over month?"
• "Compare actual vs forecasted revenue"
```

## 💰 Cost Considerations

**Cortex Analyst Pricing (2025):**
- **Token-based pricing**: ~$0.002 per 1K input tokens, ~$0.008 per 1K output tokens
- **Warehouse costs**: Standard Snowflake compute rates
- **Sample cost**: 100 daily queries ≈ $0.01-$0.10

**Cost Optimization Tips:**
- Use SMALL warehouses (larger ones don't improve LLM performance)
- Start with focused semantic models
- Set up resource monitors for cost control
- Monitor token usage regularly

## 🎓 Learning Path

### Beginner (Start here)
1. **Follow the quickstart guide** (`docs/quickstart-guide.md`)
2. **Run the demo setup** (15 minutes)  
3. **Try sample questions** in Streamlit app
4. **Review semantic model** structure

### Intermediate  
1. **Customize semantic model** for your data
2. **Add verified queries** for improved accuracy
3. **Create custom Streamlit apps** 
4. **Implement proper governance**

### Advanced
1. **REST API integration** into existing apps
2. **Multi-model semantic files** for complex use cases  
3. **Performance optimization** and monitoring
4. **Production deployment** best practices

## 📋 Presentation Materials

Ready to demo Cortex Analyst to your team? We've included:

- **30-minute presentation agenda** (`docs/presentation-agenda.md`)
- **Speaker notes and talking points**
- **Visual diagrams** explaining the architecture
- **Sample questions** that showcase capabilities
- **Cost and ROI discussion** materials

Perfect for capability showcases, lunch & learns, or executive demos.

## 🔧 Troubleshooting

### Common Issues

**Permission Denied:** Ensure CORTEX_USER role is granted to your user
```sql
USE ROLE SECURITYADMIN;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE your_role;
```

**Semantic Model Not Found:** Verify file is uploaded to correct stage path

**Poor Query Accuracy:** 
- Add more descriptive field descriptions
- Include business synonyms  
- Add sample values to dimensions
- Include verified queries for common questions

**High Costs:**
- Use SMALL warehouses for LLM functions
- Monitor token usage in account usage views
- Set up resource monitors

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality  
4. Submit a pull request

## 📚 Additional Resources

- [Snowflake Cortex Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex)
- [Cortex Analyst API Reference](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Semantic Model Specification](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/semantic-model-spec)  
- [Official Snowflake Quickstart](https://quickstarts.snowflake.com/guide/getting_started_with_cortex_analyst/index.html)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Tags

`snowflake` `cortex-analyst` `ai` `llm` `natural-language` `sql` `analytics` `self-service` `business-intelligence` `conversational-ai`

---

**Built with ❄️ by the Snowflake Community**

*Ready to unlock AI-powered analytics? Let's get started!* 🚀