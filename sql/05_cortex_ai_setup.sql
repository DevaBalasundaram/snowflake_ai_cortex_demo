/*--
Snowflake Cortex AI Demo Setup Script  
Sets up sample call transcripts data for demonstrating Cortex AI functions

This script creates:
- Demo database and schema for Cortex AI examples
- Call transcripts table with sample customer service data
- File format and stage for loading external data
- Sample data for testing all Cortex AI functions

Based on: https://quickstarts.snowflake.com/guide/getting-started-with-snowflake-cortex-ai/
--*/

-- Set up environment (use ACCOUNTADMIN for initial setup)
USE ROLE ACCOUNTADMIN;

-- Create demo database and schema
CREATE DATABASE IF NOT EXISTS CORTEX_AI_DEMO 
    COMMENT = 'Database for Snowflake Cortex AI function demonstrations';

CREATE SCHEMA IF NOT EXISTS CORTEX_AI_DEMO.DEMO_SCHEMA
    COMMENT = 'Schema containing sample data for Cortex AI functions';

-- Create warehouse for Cortex AI operations
CREATE OR REPLACE WAREHOUSE CORTEX_AI_WH 
    WAREHOUSE_SIZE = 'XSMALL'         -- XS is sufficient for LLM functions
    AUTO_SUSPEND = 60                 -- Suspend after 1 minute
    AUTO_RESUME = TRUE               -- Auto-resume when needed  
    INITIALLY_SUSPENDED = TRUE       -- Start suspended to save costs
    COMMENT = 'Warehouse for Cortex AI demo operations';

-- Set context
USE DATABASE CORTEX_AI_DEMO;
USE SCHEMA CORTEX_AI_DEMO.DEMO_SCHEMA;
USE WAREHOUSE CORTEX_AI_WH;

-- Enable cross-region access for Cortex functions (required for some accounts)
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';

-- Create file format for CSV data loading
CREATE OR REPLACE FILE FORMAT csvformat
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TYPE = 'CSV'
    COMMENT = 'CSV file format for loading call transcripts data';

-- Create stage for loading call transcripts data from external source
CREATE OR REPLACE STAGE call_transcripts_data_stage
    FILE_FORMAT = csvformat
    URL = 's3://sfquickstarts/misc/call_transcripts/'
    COMMENT = 'Stage for loading sample call transcripts from Snowflake quickstart data';

-- Create call transcripts table
CREATE OR REPLACE TABLE CALL_TRANSCRIPTS (
    date_created DATE COMMENT 'Date when the call transcript was created',
    language VARCHAR(60) COMMENT 'Language of the call transcript', 
    country VARCHAR(60) COMMENT 'Country where the call originated',
    product VARCHAR(60) COMMENT 'Product discussed in the call',
    category VARCHAR(60) COMMENT 'Product category',
    damage_type VARCHAR(90) COMMENT 'Type of damage or issue reported',
    transcript VARCHAR COMMENT 'Full transcript of the customer service call'
) COMMENT = 'Customer service call transcripts for AI analysis demonstrations';

-- Load data from external stage
COPY INTO CALL_TRANSCRIPTS
FROM @call_transcripts_data_stage;

-- Verify data loaded successfully
SELECT 'Data Loading Summary' as status, '' as details
UNION ALL
SELECT 'Total Records:', COUNT(*)::STRING FROM CALL_TRANSCRIPTS
UNION ALL  
SELECT 'Date Range:', CONCAT(MIN(date_created)::STRING, ' to ', MAX(date_created)::STRING) FROM CALL_TRANSCRIPTS
UNION ALL
SELECT 'Languages:', LISTAGG(DISTINCT language, ', ') FROM CALL_TRANSCRIPTS
UNION ALL
SELECT 'Countries:', LISTAGG(DISTINCT country, ', ') FROM CALL_TRANSCRIPTS;

-- Show sample records
SELECT 
    'Sample Call Transcripts:' as info,
    '' as date_created,
    '' as language, 
    '' as product,
    '' as transcript_preview
UNION ALL
SELECT 
    '',
    date_created::STRING,
    language,
    product,
    LEFT(transcript, 100) || '...' as transcript_preview
FROM CALL_TRANSCRIPTS
LIMIT 5;

-- Create additional sample data for comprehensive demos
CREATE OR REPLACE TABLE SAMPLE_BUSINESS_CONTENT (
    content_id INT AUTOINCREMENT PRIMARY KEY,
    content_type VARCHAR(100) COMMENT 'Type of business content',
    title VARCHAR(200) COMMENT 'Title or subject of the content',
    language VARCHAR(20) COMMENT 'Language of the content',
    content TEXT COMMENT 'Full text content for AI processing'
) COMMENT = 'Sample business content for demonstrating various Cortex AI functions';

-- Insert diverse sample content
INSERT INTO SAMPLE_BUSINESS_CONTENT (content_type, title, language, content) VALUES
('Customer Feedback', 'Product Review - Premium Headphones', 'English', 
 'I purchased these headphones three months ago and I am absolutely thrilled with the quality. The sound clarity is exceptional, the noise cancellation works perfectly, and the battery life exceeds the advertised 30 hours. The build quality feels premium and the comfort level is outstanding even for extended listening sessions. My only minor complaint is that the carrying case could be more compact for travel. Overall, this is an excellent product that I would highly recommend to anyone looking for high-quality wireless headphones. The customer service was also very responsive when I had questions about the warranty.'),

('Meeting Notes', 'Q3 Sales Review Meeting', 'English',
 'Meeting held on August 15, 2025, with sales team leads from all regions. Key highlights: North region exceeded targets by 18%, South region met 95% of targets, East region achieved 112% of targets, and West region reached 87% of targets. Top-performing products were wireless earbuds (35% growth), smart watches (28% growth), and fitness trackers (22% growth). Main challenges identified include supply chain delays affecting 15% of orders and increased competition in the budget segment. Action items: implement new inventory management system by September 30th, expand marketing budget for West region by 20%, and negotiate better terms with suppliers for faster delivery. Next meeting scheduled for September 15th to review progress on action items.'),

('Customer Support', 'Technical Support Ticket Resolution', 'English',
 'Customer reported WiFi connectivity issues with smart home device. Initial troubleshooting steps included device restart, router reset, and checking for interference. Issue persisted despite basic troubleshooting. Advanced diagnostics revealed firmware version incompatibility with newer router models. Resolution involved updating device firmware to version 2.1.3 and providing configuration guidelines for optimal router settings. Customer confirmed successful connection after firmware update. Total resolution time: 45 minutes. Customer satisfaction rating: 5/5 stars. Device is now functioning normally with stable connectivity. Follow-up call scheduled for next week to ensure continued proper operation.'),

('German Feedback', 'Produktbewertung - Smartphone Hülle', 'German',
 'Das ist eine wirklich hochwertige Handyhülle, die sowohl stilvoll als auch funktional ist. Der Schutz ist ausgezeichnet - mein Handy ist bereits mehrmals heruntergefallen und hat keinen Schaden davongetragen. Das Material fühlt sich premium an und die Passform ist perfekt. Besonders gut gefällt mir die präzisen Aussparungen für Kameras und Anschlüsse. Die Lieferung war sehr schnell und die Verpackung war umweltfreundlich. Einziger kleiner Nachteil ist, dass die Hülle etwas dicker ist als erwartet, aber das ist ein akzeptabler Kompromiss für den hervorragenden Schutz. Würde ich definitiv wieder kaufen und weiterempfehlen.'),

('French Feedback', 'Avis Client - Service de Livraison', 'French', 
 'Je suis extrêmement satisfait du service de livraison rapide. La commande est arrivée un jour plus tôt que prévu et en parfait état. Le livreur était très professionnel et courtois. Le système de suivi en temps réel est fantastique et permet de savoir exactement où se trouve le colis. Les options de livraison flexibles sont très pratiques, surtout la possibilité de changer l''adresse de livraison même après avoir passé la commande. Le packaging était écologique et sécurisé. Le seul point d''amélioration serait d''avoir plus d''options de créneaux horaires le weekend. Dans l''ensemble, c''est un service exemplaire que je recommande vivement.'),

('Spanish Feedback', 'Reseña de Producto - Cafetera Automática', 'Spanish',
 'Esta cafetera automática ha superado todas mis expectativas. La calidad del café es excepcional, comparable a la de las mejores cafeterías. La función de programación es muy conveniente para tener café fresco cada mañana. El diseño es elegante y se ve muy bien en mi cocina moderna. La limpieza automática es una característica fantástica que ahorra mucho tiempo. El servicio al cliente fue muy útil cuando tuve preguntas sobre las diferentes configuraciones. El único inconveniente menor es que es un poco ruidosa durante la molienda, pero es un precio pequeño a pagar por un café tan delicioso. Definitivamente la recomiendo a cualquiera que ame el buen café.');

-- Grant permissions to roles that will use this data
GRANT USAGE ON DATABASE CORTEX_AI_DEMO TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA CORTEX_AI_DEMO.DEMO_SCHEMA TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA CORTEX_AI_DEMO.DEMO_SCHEMA TO ROLE PUBLIC;
GRANT USAGE ON WAREHOUSE CORTEX_AI_WH TO ROLE PUBLIC;

-- Grant Cortex permissions (CORTEX_USER is granted to PUBLIC by default)
-- If you need to restrict access, uncomment and modify these lines:
-- REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE PUBLIC;
-- GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE <specific_role>;

-- Create view for easier access to multilingual content
CREATE OR REPLACE VIEW MULTILINGUAL_CONTENT AS
SELECT 
    content_id,
    content_type,
    title,
    language,
    content,
    CHAR_LENGTH(content) as content_length,
    CASE language
        WHEN 'English' THEN 'en_XX'
        WHEN 'German' THEN 'de_DE'  
        WHEN 'French' THEN 'fr_FR'
        WHEN 'Spanish' THEN 'es_ES'
        ELSE 'en_XX'
    END as language_code
FROM SAMPLE_BUSINESS_CONTENT;

-- Show setup summary
SELECT 'Cortex AI Demo Setup Complete!' as status, '' as details
UNION ALL
SELECT 'Database:', 'CORTEX_AI_DEMO'
UNION ALL
SELECT 'Schema:', 'DEMO_SCHEMA'  
UNION ALL
SELECT 'Warehouse:', 'CORTEX_AI_WH'
UNION ALL
SELECT 'Call Transcripts Records:', (SELECT COUNT(*)::STRING FROM CALL_TRANSCRIPTS)
UNION ALL
SELECT 'Sample Business Content Records:', (SELECT COUNT(*)::STRING FROM SAMPLE_BUSINESS_CONTENT)
UNION ALL  
SELECT 'Languages Available:', (SELECT LISTAGG(DISTINCT language, ', ') FROM MULTILINGUAL_CONTENT);

-- Provide quick test examples
SELECT 'Quick Test Examples - Copy and run these:' as info, '' as sql_command
UNION ALL
SELECT '', '-- Test Translation:'
UNION ALL
SELECT '', 'SELECT SNOWFLAKE.CORTEX.TRANSLATE(''Guten Tag!'', ''de_DE'', ''en_XX'');'
UNION ALL
SELECT '', ''  
UNION ALL
SELECT '', '-- Test Sentiment Analysis:'
UNION ALL
SELECT '', 'SELECT SNOWFLAKE.CORTEX.SENTIMENT(''I love this product!'');'
UNION ALL
SELECT '', ''
UNION ALL  
SELECT '', '-- Test Summarization:'
UNION ALL
SELECT '', 'SELECT SNOWFLAKE.CORTEX.SUMMARIZE(content) FROM SAMPLE_BUSINESS_CONTENT LIMIT 1;'
UNION ALL
SELECT '', ''
UNION ALL
SELECT '', '-- Test Custom Completion:'
UNION ALL
SELECT '', 'SELECT SNOWFLAKE.CORTEX.COMPLETE(''claude-4-sonnet'', ''Explain AI in 50 words'');';

/*--
Next Steps:
1. Run the Cortex AI functions demo script: 04_cortex_functions.sql
2. Explore the call transcripts data for realistic examples
3. Try the multilingual content for translation workflows
4. Experiment with different models and prompts
5. Use the sample business content for summarization examples

Files to run in order:
1. This file (05_cortex_ai_setup.sql) - Sets up data
2. 04_cortex_functions.sql - Demonstrates all Cortex AI functions
--*/