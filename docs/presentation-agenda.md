# 30-Minute Presentation Agenda: Unlocking AI with Snowflake Cortex

**Meeting**: Capability Showcase - Unlocking AI with Snowflake Cortex Walkthrough
**Presenters**: Deva Balasundaram, Durganand Yedlapati  
**Date**: August 27, 2025
**Duration**: 30 minutes
**Audience**: USDC AI&Data Practitioners

---

## Presentation Outline (30 minutes)

### 1. Welcome & Introduction (3 minutes)
- Welcome to iHub Capability Showcase
- Today's agenda overview
- What you'll learn and take away

### 2. What is Snowflake? (5 minutes)
**For those new to Snowflake**

#### Key Points:
- **Cloud-native data platform** - No infrastructure to manage
- **Architecture**: Separates compute, storage, and services
- **Multi-cloud**: AWS, Azure, Google Cloud
- **Scalability**: Pay for what you use, scale up/down instantly
- **Security & Governance**: Enterprise-grade built-in

#### Why it matters:
- Eliminates traditional data warehouse limitations
- Enables modern data architecture
- Foundation for AI/ML workloads

---

### 3. Introduction to Snowflake Cortex AI (7 minutes)

#### What is Cortex AI?
- **Built-in AI/ML engine** within Snowflake
- **No data movement** - AI runs where your data lives
- **Pre-trained models** ready to use
- **Enterprise security** and governance

#### Cortex AI Capabilities:
- **Large Language Models** (Llama, Mistral, Arctic)
- **AI Functions**: Text processing, summarization, translation
- **ML Functions**: Forecasting, anomaly detection
- **Document AI**: Extract insights from unstructured data

#### Benefits:
- No model training or management
- Integrated security and compliance
- Real-time AI-driven insights
- Cost-effective token-based pricing

---

### 4. Cortex Analyst Deep Dive (10 minutes)

#### What is Cortex Analyst?
- **Conversational AI service** for business analytics
- **Natural language to SQL** with high accuracy
- **Self-service analytics** for business users
- **REST API** for application integration

#### Key Features:
- **Text-to-SQL Excellence**: Industry-leading accuracy
- **Agentic AI Setup**: Powered by state-of-the-art LLMs
- **Semantic Models**: Business terminology mapping
- **Verified Queries**: Improved accuracy through examples

#### Business Value:
- **Democratizes Data Access**: Business users can query independently
- **Reduces Data Team Bottlenecks**: Fewer ad-hoc requests
- **Faster Time to Insights**: Real-time answers to business questions
- **Consistent Results**: Governed and secure access

---

### 5. Live Demo: Cortex Analyst in Action (8 minutes)

#### Demo Flow:
1. **Show the semantic model** - revenue_timeseries.yaml
2. **Launch Streamlit application**
3. **Ask natural language questions**:
   - "What was our total revenue last month?"
   - "Which product line has the highest profit margin?"
   - "Show me revenue trends by region"
   - "What questions can I ask?"

#### Highlight:
- **SQL generation** transparency
- **Response accuracy** and context
- **Business user-friendly** interface
- **Real-time results**

---

### 6. Getting Started Guide (5 minutes)

#### Prerequisites:
- **Snowflake Enterprise Edition** or higher
- **CORTEX_USER role** (granted by default to PUBLIC)
- **Supported region** (US-East, US-West, EU-West, etc.)

#### Key Setup Steps:
1. **Permissions Setup** - Grant CORTEX_USER role
2. **Create Warehouse** - SMALL size sufficient
3. **Prepare Data** - Tables with business data
4. **Build Semantic Model** - YAML file mapping business terms
5. **Test with Streamlit** - Create conversational interface

#### Cost Considerations:
- **Token-based pricing** (~$0.002 per 1K input tokens)
- **Standard warehouse costs** apply
- **Start small** and scale based on usage
- **Resource monitors** for cost control

---

### 7. Best Practices & Tips (2 minutes)

#### Semantic Model Best Practices:
- **Start simple** - Focus on core business questions
- **Use business language** - Include synonyms users understand
- **Provide context** - Rich descriptions for better accuracy
- **Iterative improvement** - Add verified queries over time

#### Success Tips:
- **Train users** on effective question techniques
- **Monitor usage** and costs regularly
- **Implement governance** with proper access controls
- **Scale gradually** as adoption grows

---

## Q&A and Wrap-up (5 minutes)

### Key Takeaways:
✅ **Cortex Analyst democratizes data access** with natural language queries
✅ **High accuracy** text-to-SQL powered by advanced LLMs  
✅ **Enterprise-ready** with built-in security and governance
✅ **Easy to get started** with semantic models and REST API
✅ **Cost-effective** token-based pricing model

### Next Steps for Attendees:
1. **Try the quickstart guide** (provided as attachment)
2. **Identify use cases** in your organization
3. **Set up a pilot** with key business users
4. **Contact iHub team** for implementation support

### Resources Provided:
- Comprehensive quickstart guide
- Step-by-step setup instructions
- Sample semantic model templates
- Cost estimation guidelines
- Troubleshooting tips

---

## Presenter Notes

### Technical Tips:
- Have demo environment pre-loaded and tested
- Prepare backup screenshots in case of connectivity issues  
- Have sample questions ready that showcase different capabilities
- Be ready to show the generated SQL for transparency

### Audience Engagement:
- Ask about current BI/analytics challenges
- Encourage questions throughout the demo
- Collect feedback on potential use cases
- Offer follow-up consultations

### Follow-up Actions:
- Send quickstart guide to all attendees
- Schedule follow-up sessions for interested teams
- Collect contact information for pilot opportunities
- Update iHub knowledge base with questions received

---

**Contact Information:**
- iHub Team: [contact details]
- Slack Channel: [channel name]
- Documentation: [internal links]
- Quickstart Guide: [attachment link]