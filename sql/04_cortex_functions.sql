/*--
Snowflake Cortex AI Functions Demo Script
Demonstrates task-specific LLM functions available in Snowflake Cortex

This script shows how to use various Cortex AI functions for:
- Translation
- Sentiment analysis  
- Text summarization
- Custom LLM completions
- Token counting

Prerequisites:
- Snowflake account with Cortex AI features enabled
- CORTEX_USER role granted to your user
- Appropriate warehouse for running queries
--*/

-- Set up environment
USE ROLE CORTEX_USER_ROLE;  -- or any role with CORTEX_USER permissions
USE WAREHOUSE cortex_analyst_wh;

-- Enable cross-region access for Cortex functions (if needed)
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';

/*==============================================================================
1. TRANSLATION FUNCTIONS
==============================================================================*/

-- Basic translation example: German to English
SELECT 
    'Translation Demo' as function_type,
    'wie geht es dir heute?' as original_text,
    SNOWFLAKE.CORTEX.TRANSLATE('wie geht es dir heute?', 'de_DE', 'en_XX') as translated_text;

-- Multiple language translation examples
SELECT 
    original_language,
    original_text,
    target_language,
    SNOWFLAKE.CORTEX.TRANSLATE(original_text, source_lang, target_lang) as translated_text
FROM (
    SELECT 'German' as original_language, 'Guten Morgen! Wie kann ich Ihnen heute helfen?' as original_text, 'de_DE' as source_lang, 'English' as target_language, 'en_XX' as target_lang
    UNION ALL
    SELECT 'French', 'Bonjour! Comment allez-vous aujourd''hui?', 'fr_FR', 'English', 'en_XX'
    UNION ALL  
    SELECT 'Spanish', 'Hola! ¿Cómo está usted hoy?', 'es_ES', 'English', 'en_XX'
    UNION ALL
    SELECT 'English', 'Hello! How are you today?', 'en_XX', 'German', 'de_DE'
);

-- Business use case: Translate customer feedback
WITH sample_feedback AS (
    SELECT 'Das Produkt ist ausgezeichnet, aber der Versand war sehr langsam.' as feedback, 'de_DE' as lang, 'German' as language
    UNION ALL
    SELECT 'Le service client est fantastique, très professionnel.' as feedback, 'fr_FR' as lang, 'French' as language
    UNION ALL
    SELECT 'El precio es muy alto para la calidad del producto.' as feedback, 'es_ES' as lang, 'Spanish' as language
)
SELECT 
    language,
    feedback as original_feedback,
    SNOWFLAKE.CORTEX.TRANSLATE(feedback, lang, 'en_XX') as english_translation
FROM sample_feedback;

/*==============================================================================
2. SENTIMENT ANALYSIS FUNCTIONS  
==============================================================================*/

-- Basic sentiment analysis examples
-- Score range: -1 (most negative) to 1 (most positive), 0 = neutral
SELECT 
    'Sentiment Analysis Demo' as function_type,
    sample_text,
    SNOWFLAKE.CORTEX.SENTIMENT(sample_text) as sentiment_score,
    CASE 
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(sample_text) > 0.1 THEN 'Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(sample_text) < -0.1 THEN 'Negative'  
        ELSE 'Neutral'
    END as sentiment_category
FROM (
    SELECT 'I absolutely love this product! It exceeded all my expectations.' as sample_text
    UNION ALL
    SELECT 'The service was okay, nothing special but not bad either.'
    UNION ALL  
    SELECT 'This is the worst experience I have ever had. Completely disappointed.'
    UNION ALL
    SELECT 'Excellent quality and fast shipping. Highly recommended!'
    UNION ALL
    SELECT 'The product broke after one day. Very poor quality.'
);

-- Customer review sentiment analysis
WITH customer_reviews AS (
    SELECT 'Review #1001' as review_id, 'The delivery was fast and the product quality is outstanding!' as review_text
    UNION ALL
    SELECT 'Review #1002', 'Poor customer service. Nobody answered my calls for three days.'
    UNION ALL
    SELECT 'Review #1003', 'Average product. Works as expected but nothing impressive.'
    UNION ALL
    SELECT 'Review #1004', 'Amazing value for money! Will definitely buy again.'
    UNION ALL
    SELECT 'Review #1005', 'Defective item received. Requesting immediate refund.'
)
SELECT 
    review_id,
    review_text,
    ROUND(SNOWFLAKE.CORTEX.SENTIMENT(review_text), 3) as sentiment_score,
    CASE 
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(review_text) >= 0.3 THEN '😊 Positive'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(review_text) <= -0.3 THEN '😞 Negative'
        ELSE '😐 Neutral'
    END as sentiment_emoji
FROM customer_reviews
ORDER BY sentiment_score DESC;

/*==============================================================================
3. TEXT SUMMARIZATION FUNCTIONS
==============================================================================*/

-- Basic summarization example
WITH long_text AS (
    SELECT 'Customer called regarding order #68910 for XtremeX helmets. Jessica Turner from Mountain Ski Adventures reported that 10 helmets had broken buckles that wouldn''t secure properly, creating safety concerns for their customers. The customer service representative apologized for the manufacturing defect and offered either a full refund or replacement helmets. Jessica opted for replacements since they still needed the inventory for their ski season customers. The agent processed an expedited replacement order for 10 new XtremeX helmets with functioning buckles, which will be shipped priority overnight and should arrive within 2-3 business days. The customer was satisfied with the resolution and expressed appreciation for the prompt assistance and professional handling of the quality issue.' as customer_call_transcript
)
SELECT 
    'Summarization Demo' as function_type,
    LENGTH(customer_call_transcript) as original_length,
    customer_call_transcript as original_text,
    SNOWFLAKE.CORTEX.SUMMARIZE(customer_call_transcript) as summary,
    LENGTH(SNOWFLAKE.CORTEX.SUMMARIZE(customer_call_transcript)) as summary_length
FROM long_text;

-- Business document summarization
WITH business_documents AS (
    SELECT 'Q4 Sales Report' as document_type,
           'The fourth quarter sales performance exceeded expectations with total revenue reaching $2.4 million, representing a 15% increase compared to Q3 and 22% growth year-over-year. Electronics division led growth with 28% increase driven by holiday season demand and successful product launches. Clothing segment showed moderate 8% growth while Home Appliances achieved 18% growth. Regional performance varied with North region leading at 25% growth, followed by East at 20%, South at 15%, and West at 12%. Key success factors included improved inventory management, enhanced digital marketing campaigns, and strategic partnerships with major retailers. Customer satisfaction scores improved to 4.3/5.0 from 4.1 in previous quarter. Looking ahead to Q1, we anticipate continued growth momentum with new product launches scheduled and expansion into two additional markets.' as content
    
    UNION ALL
    
    SELECT 'Customer Feedback Analysis',
           'Analysis of 500 customer feedback responses collected over the past month reveals several key insights. Overall satisfaction rating averaged 4.2 out of 5.0 stars. Product quality received highest ratings (4.5/5.0) with customers particularly praising durability and design aesthetics. Shipping and delivery performance scored 4.1/5.0 with most customers satisfied with delivery times, though 15% requested faster options. Customer service rated 3.9/5.0 with room for improvement in response times and technical knowledge. Price satisfaction scored 3.8/5.0 indicating some price sensitivity concerns. Top compliments focused on product innovation, packaging quality, and website user experience. Main complaints centered on limited color options, occasional sizing issues, and desire for more detailed product specifications. Recommendations include expanding color palette, improving size guide accuracy, enhancing product descriptions, and reducing customer service response times.' as content
)
SELECT 
    document_type,
    CHAR_LENGTH(content) as original_character_count,
    SNOWFLAKE.CORTEX.SUMMARIZE(content) as executive_summary,
    CHAR_LENGTH(SNOWFLAKE.CORTEX.SUMMARIZE(content)) as summary_character_count,
    ROUND((CHAR_LENGTH(SNOWFLAKE.CORTEX.SUMMARIZE(content)) / CHAR_LENGTH(content)) * 100, 1) as compression_ratio_percent
FROM business_documents;

/*==============================================================================
4. CUSTOM LLM COMPLETIONS (COMPLETE FUNCTION)
==============================================================================*/

-- Basic completion with different models
SET prompt = 'Explain the benefits of cloud data warehousing in 100 words or less.';

SELECT 
    'llama3.1-70b' as model_name,
    SNOWFLAKE.CORTEX.COMPLETE('llama3.1-70b', $prompt) as response
    
UNION ALL

SELECT 
    'claude-4-sonnet' as model_name,
    SNOWFLAKE.CORTEX.COMPLETE('claude-4-sonnet', $prompt) as response

UNION ALL

SELECT 
    'mistral-8x7b' as model_name, 
    SNOWFLAKE.CORTEX.COMPLETE('mistral-8x7b', $prompt) as response;

-- Structured data extraction from customer calls
SET extraction_prompt = 
'### 
Extract the following information from this customer service transcript and format as JSON:
- customer_name
- order_number  
- product_name
- issue_type
- resolution_status
- sentiment (positive/negative/neutral)
###';

WITH customer_transcript AS (
    SELECT 'Customer: Hi, this is Sarah Johnson calling about order #45892. 
Agent: Hello Sarah, how can I help you today?
Customer: I received my DryTech jacket yesterday but the zipper is completely broken. It won''t zip up at all.
Agent: I''m so sorry to hear that Sarah. Let me process a replacement for you right away. 
Customer: That would be great, thank you so much for your help!
Agent: You''re welcome! Your replacement jacket will ship today and arrive by Friday.' as transcript
)
SELECT 
    SNOWFLAKE.CORTEX.COMPLETE(
        'claude-4-sonnet', 
        CONCAT('[INST]', $extraction_prompt, transcript, '[/INST]')
    ) as extracted_data
FROM customer_transcript;

-- Creative content generation
SET creative_prompt = 'Write a professional product description for "EcoSmart Water Bottle" that highlights sustainability features, capacity, and durability. Keep it under 150 words and include key selling points.';

SELECT 
    'Product Description Generation' as use_case,
    SNOWFLAKE.CORTEX.COMPLETE('claude-4-sonnet', $creative_prompt) as generated_content;

-- Code generation example
SET code_prompt = 'Write a SQL query to find the top 5 products by revenue for the current month, including product name, total revenue, and rank. Assume tables: products (id, name), orders (id, product_id, quantity, price, order_date).';

SELECT 
    'SQL Code Generation' as use_case,
    SNOWFLAKE.CORTEX.COMPLETE('claude-4-sonnet', $code_prompt) as generated_sql;

/*==============================================================================
5. TOKEN COUNTING FUNCTIONS
==============================================================================*/

-- Count tokens for different Cortex functions
WITH sample_texts AS (
    SELECT 'Short text example.' as text, 'short' as text_type
    UNION ALL  
    SELECT 'This is a medium-length text example that contains multiple sentences and provides more context for token counting analysis.' as text, 'medium'
    UNION ALL
    SELECT 'This is a very long text example that demonstrates how token counting works with larger content. It includes multiple sentences, various vocabulary, punctuation marks, and sufficient content to show meaningful token counts. This type of analysis is important for understanding costs and performance implications when using large language models for various natural language processing tasks such as summarization, translation, sentiment analysis, and custom completions.' as text, 'long'
)
SELECT 
    text_type,
    CHAR_LENGTH(text) as character_count,
    SNOWFLAKE.CORTEX.COUNT_TOKENS('translate', text) as translate_tokens,
    SNOWFLAKE.CORTEX.COUNT_TOKENS('summarize', text) as summarize_tokens,  
    SNOWFLAKE.CORTEX.COUNT_TOKENS('complete', text) as complete_tokens,
    text as sample_text
FROM sample_texts
ORDER BY character_count;

-- Token counting for cost estimation
WITH cost_analysis AS (
    SELECT 
        'Customer Survey Response' as content_type,
        'The new mobile app is fantastic! The user interface is intuitive and loading times are significantly faster than the previous version. I especially appreciate the offline mode feature and the improved search functionality. However, I would love to see more customization options for the dashboard and better integration with calendar apps. Overall, this update has greatly enhanced my productivity and user experience. Five stars!' as content
)
SELECT 
    content_type,
    content,
    SNOWFLAKE.CORTEX.COUNT_TOKENS('complete', content) as token_count,
    -- Estimated cost calculation (example rates - actual rates may vary)
    ROUND(SNOWFLAKE.CORTEX.COUNT_TOKENS('complete', content) * 0.002, 4) as estimated_cost_usd,
    CHAR_LENGTH(content) as character_count,
    ROUND(SNOWFLAKE.CORTEX.COUNT_TOKENS('complete', content) / CHAR_LENGTH(content) * 100, 2) as tokens_per_100_chars
FROM cost_analysis;

/*==============================================================================
6. COMBINED WORKFLOW EXAMPLE
==============================================================================*/

-- Complete workflow: Translation -> Sentiment -> Summarization
WITH multilingual_feedback AS (
    SELECT 
        'Customer #101' as customer_id,
        'Das Produkt ist wirklich ausgezeichnet und der Kundenservice war außergewöhnlich hilfsreich. Ich bin sehr zufrieden mit meinem Kauf und würde es definitiv weiterempfehlen. Die Lieferung war schnell und das Produkt kam in perfektem Zustand an. Einziger kleiner Kritikpunkt ist der etwas hohe Preis, aber die Qualität rechtfertigt die Kosten.' as original_feedback,
        'de_DE' as source_language,
        'German' as language_name
    
    UNION ALL
    
    SELECT 
        'Customer #102',
        'Le produit est correct mais le service client pourrait être amélioré. J''ai dû attendre longtemps au téléphone et la personne n''était pas très informée. Le produit fonctionne bien mais l''emballage était endommagé à l''arrivée. Je ne suis pas sûr si je commanderai à nouveau.' as original_feedback,
        'fr_FR' as source_language, 
        'French' as language_name
)
SELECT 
    customer_id,
    language_name,
    original_feedback,
    
    -- Step 1: Translate to English
    SNOWFLAKE.CORTEX.TRANSLATE(original_feedback, source_language, 'en_XX') as english_translation,
    
    -- Step 2: Analyze sentiment of translated text
    ROUND(SNOWFLAKE.CORTEX.SENTIMENT(
        SNOWFLAKE.CORTEX.TRANSLATE(original_feedback, source_language, 'en_XX')
    ), 3) as sentiment_score,
    
    -- Step 3: Summarize the feedback  
    SNOWFLAKE.CORTEX.SUMMARIZE(
        SNOWFLAKE.CORTEX.TRANSLATE(original_feedback, source_language, 'en_XX')
    ) as summary,
    
    -- Token count for cost estimation
    SNOWFLAKE.CORTEX.COUNT_TOKENS('complete', original_feedback) as token_count
    
FROM multilingual_feedback;

/*==============================================================================
7. PERFORMANCE COMPARISON BETWEEN MODELS
==============================================================================*/

-- Compare different models for the same task
SET comparison_prompt = 'Summarize the key benefits of using AI in customer service in exactly 3 bullet points.';

SELECT 
    model_name,
    SNOWFLAKE.CORTEX.COMPLETE(model_name, $comparison_prompt) as response,
    SNOWFLAKE.CORTEX.COUNT_TOKENS('complete', $comparison_prompt) as input_tokens
FROM (
    SELECT 'llama3.1-70b' as model_name
    UNION ALL
    SELECT 'claude-4-sonnet'
    UNION ALL  
    SELECT 'mistral-8x7b'
);

-- Show available models and their use cases
SELECT 'Model Comparison Summary' as info_type, '
Available Cortex AI Functions:
• TRANSLATE - Convert text between 15+ languages
• SENTIMENT - Analyze emotional tone (-1 to +1 scale)  
• SUMMARIZE - Create concise summaries of long text
• COMPLETE - Custom LLM completions with various models
• COUNT_TOKENS - Estimate processing costs

Supported Models for COMPLETE function:
• llama3.1-70b - Good for general tasks, fast responses
• claude-4-sonnet - Excellent for complex reasoning, structured output
• mistral-8x7b - Balanced performance and efficiency
• Additional models available depending on region

Best Practices:
• Use TRANSLATE for multilingual content processing
• Use SENTIMENT for customer feedback analysis  
• Use SUMMARIZE for document processing
• Use COMPLETE for custom tasks requiring specific instructions
• Always count tokens for cost estimation
' as summary;

/*==============================================================================
NOTES AND BEST PRACTICES
==============================================================================*/

/*
Cost Optimization Tips:
1. Use COUNT_TOKENS to estimate costs before processing large datasets
2. Choose the right model for your task (simpler models for simple tasks)
3. Batch process when possible rather than row-by-row operations
4. Use result caching for repeated queries
5. Set up resource monitors to control spending

Performance Tips:  
1. Use appropriate warehouse sizes (SMALL is usually sufficient for Cortex functions)
2. Process data in batches rather than individual rows when possible
3. Cache frequently used translations and summaries
4. Use TRANSLATE before SENTIMENT for non-English text
5. Consider preprocessing text to remove unnecessary content

Security Considerations:
1. Data never leaves Snowflake environment
2. Use appropriate roles and permissions (CORTEX_USER)
3. Apply data masking policies to sensitive fields before processing
4. Monitor usage for compliance and governance
5. Use secure views for limiting data access

Supported Languages for TRANSLATE:
- English (en_XX), German (de_DE), French (fr_FR), Spanish (es_ES)
- Italian (it_IT), Portuguese (pt_PT), Russian (ru_RU), Japanese (ja_JP)
- Korean (ko_KR), Chinese Simplified (zh_CN), Polish (pl_PL), Swedish (sv_SE)
- Dutch (nl_NL), Arabic (ar_AR), Hindi (hi_IN)
*/