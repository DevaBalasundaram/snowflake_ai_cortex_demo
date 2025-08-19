"""
Snowflake Cortex Analyst Demo Application
Interactive Streamlit app for natural language queries on revenue data

This app demonstrates how to:
1. Connect to Cortex Analyst API
2. Send natural language questions  
3. Display AI-generated SQL and results
4. Provide guided user experience
"""

import streamlit as st
import pandas as pd
import json
from typing import List, Dict, Tuple, Optional
import snowflake.permissions as permissions
from snowflake.snowpark.context import get_active_session

# Configure Streamlit page
st.set_page_config(
    page_title="Cortex Analyst Revenue Demo",
    page_icon="🧠",
    layout="wide",
    initial_sidebar_state="expanded"
)

# API Configuration
API_ENDPOINT = "/api/v2/cortex/analyst/message"
API_TIMEOUT = 30000  # 30 seconds

# Get Snowflake session
session = get_active_session()

# App Header
st.title("🧠 Snowflake Cortex Analyst Demo")
st.caption("Ask questions about your revenue data in natural language!")

# Sidebar configuration
with st.sidebar:
    st.header("📊 Demo Configuration")
    
    # Semantic model path
    default_semantic_model = "@cortex_analyst_demo.revenue_timeseries.raw_data/revenue_timeseries.yaml"
    semantic_model_path = st.text_input(
        "Semantic Model Path:",
        value=default_semantic_model,
        help="Path to your semantic model YAML file in Snowflake stage"
    )
    
    # Store in session state
    if "selected_semantic_model_path" not in st.session_state:
        st.session_state.selected_semantic_model_path = semantic_model_path
    
    st.divider()
    
    # Sample questions
    st.subheader("💡 Try These Questions:")
    sample_questions = [
        "What questions can I ask?",
        "What was our total revenue last month?",
        "Which product line has the highest profit margin?",
        "Show me revenue trends by region",
        "Compare actual vs forecasted revenue",
        "What is our average daily revenue by product line?",
        "Which region has the lowest cost of goods sold?",
        "Show me profit margins over time",
        "What are the top 5 days by revenue?",
        "How accurate are our revenue forecasts?"
    ]
    
    for question in sample_questions:
        if st.button(question, key=f"sample_{hash(question)}", use_container_width=True):
            st.session_state.user_input = question

    st.divider()
    
    # Help section
    st.subheader("ℹ️ Tips for Better Results")
    st.markdown("""
    **Effective questions:**
    - Be specific about time periods
    - Mention specific product lines or regions
    - Ask for comparisons and trends
    - Request calculations (totals, averages, etc.)
    
    **Available data:**
    - **Time Range**: Last 90 days
    - **Products**: Electronics, Clothing, Home Appliances, Books, Toys  
    - **Regions**: North (CA), South (TX), East (NY), West (OR)
    - **Metrics**: Revenue, costs, profit, forecasts
    """)

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Initialize user input
if "user_input" not in st.session_state:
    st.session_state.user_input = ""

def get_analyst_response(messages: List[Dict]) -> Tuple[Dict, Optional[str]]:
    """
    Send chat history to the Cortex Analyst API and return the response.
    
    Args:
        messages (List[Dict]): The conversation history
        
    Returns:
        Tuple[Dict, Optional[str]]: Response and error message if any
    """
    try:
        # Prepare the request body
        request_body = {
            "messages": messages,
            "semantic_model_file": st.session_state.selected_semantic_model_path,
        }
        
        # Call Cortex Analyst using SQL interface
        sql_query = f"""
        SELECT SNOWFLAKE.CORTEX.ANALYST(
            '{json.dumps(messages)}',
            '{st.session_state.selected_semantic_model_path}'
        ) as response
        """
        
        # Execute the query
        result = session.sql(sql_query).collect()
        
        if result and len(result) > 0:
            response_str = result[0]['RESPONSE']
            parsed_response = json.loads(response_str)
            return parsed_response, None
        else:
            return {}, "No response received from Cortex Analyst"
            
    except Exception as e:
        error_msg = f"""
        🚨 An error occurred while calling Cortex Analyst 🚨
        
        **Error Details:**
        ```
        {str(e)}
        ```
        
        **Troubleshooting Tips:**
        - Verify your semantic model path is correct
        - Ensure you have CORTEX_USER permissions
        - Check that the semantic model file exists in the specified stage
        - Verify your Snowflake account has Cortex features enabled
        """
        return {}, error_msg

def display_response(response: Dict):
    """
    Display the Cortex Analyst response with proper formatting
    
    Args:
        response (Dict): The response from Cortex Analyst
    """
    if "message" in response:
        st.write(response["message"])
    
    # Display generated SQL if available
    if "sql" in response and response["sql"]:
        st.subheader("🔍 Generated SQL Query")
        st.code(response["sql"], language="sql")
        
        # Option to execute the SQL and show results
        if st.button("▶️ Execute Query and Show Results", key="execute_sql"):
            try:
                with st.spinner("Executing query..."):
                    result_df = session.sql(response["sql"]).to_pandas()
                    
                    if not result_df.empty:
                        st.subheader("📋 Query Results")
                        
                        # Display as data table
                        st.dataframe(
                            result_df, 
                            use_container_width=True,
                            hide_index=True
                        )
                        
                        # Show basic statistics if numeric data
                        numeric_cols = result_df.select_dtypes(include=['number']).columns
                        if len(numeric_cols) > 0:
                            with st.expander("📊 Data Summary"):
                                st.write(result_df[numeric_cols].describe())
                        
                        # Option to download results
                        csv = result_df.to_csv(index=False)
                        st.download_button(
                            label="💾 Download Results as CSV",
                            data=csv,
                            file_name="cortex_analyst_results.csv",
                            mime="text/csv"
                        )
                    else:
                        st.info("Query executed successfully but returned no results.")
                        
            except Exception as e:
                st.error(f"Error executing SQL query: {str(e)}")
    
    # Display suggestions if available
    if "suggestions" in response and response["suggestions"]:
        st.subheader("💭 Suggested Follow-up Questions")
        for suggestion in response["suggestions"]:
            if st.button(suggestion, key=f"suggestion_{hash(suggestion)}"):
                st.session_state.user_input = suggestion

# Main chat interface
st.subheader("💬 Chat with Your Data")

# Display chat history
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        if message["role"] == "user":
            st.write(message["content"])
        else:
            # For assistant messages, parse if it's a JSON response
            if isinstance(message["content"], dict):
                display_response(message["content"])
            else:
                st.write(message["content"])

# Chat input with session state handling
user_input = st.chat_input(
    "Ask a question about your revenue data...",
    key="chat_input"
)

# Handle user input from either chat input or sample questions
if user_input or st.session_state.user_input:
    # Use the input from either source
    current_input = user_input if user_input else st.session_state.user_input
    
    # Clear the session state input
    if st.session_state.user_input:
        st.session_state.user_input = ""
    
    # Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": current_input})
    
    # Display user message
    with st.chat_message("user"):
        st.write(current_input)
    
    # Get AI response
    with st.chat_message("assistant"):
        with st.spinner("🤔 Thinking..."):
            try:
                response, error = get_analyst_response(st.session_state.messages)
                
                if error:
                    st.error(error)
                    # Add error to chat history
                    st.session_state.messages.append({
                        "role": "assistant", 
                        "content": f"Error: {error}"
                    })
                else:
                    # Display the response
                    display_response(response)
                    
                    # Add response to chat history
                    st.session_state.messages.append({
                        "role": "assistant", 
                        "content": response
                    })
                    
            except Exception as e:
                error_msg = f"Unexpected error: {str(e)}"
                st.error(error_msg)
                st.session_state.messages.append({
                    "role": "assistant", 
                    "content": error_msg
                })

# Clear chat history button
if st.session_state.messages:
    if st.button("🗑️ Clear Chat History", type="secondary"):
        st.session_state.messages = []
        st.rerun()

# Footer with information
st.divider()
st.markdown("""
---
**About this demo:**  
This application demonstrates Snowflake Cortex Analyst's natural language to SQL capabilities using a sample revenue dataset. 
The demo includes 90 days of revenue data across 5 product lines and 4 sales regions.

**Data Privacy:** All queries run within your Snowflake account. No data leaves your environment.

**Need Help?** Check the sidebar for sample questions and tips for better results.
""")

# Display session information in expander
with st.expander("🔧 Technical Details"):
    st.write("**Current Session Info:**")
    st.write(f"- **Semantic Model:** `{st.session_state.selected_semantic_model_path}`")
    st.write(f"- **Messages in History:** {len(st.session_state.messages)}")
    st.write(f"- **Snowflake Account:** `{session.get_current_account()}`")
    st.write(f"- **Current Database:** `{session.get_current_database()}`")
    st.write(f"- **Current Schema:** `{session.get_current_schema()}`")