{{ config(materialized='table') }}

WITH customers AS (

    SELECT 
        customer_id AS customer_id,
        customer_firstname AS first_name,
        customer_lastname AS last_name,
        customer_email AS customer_email,
        NULL AS customer_segment,          
        'fudgemart' AS source_system
    FROM {{ source('fudgemart', 'fm_customers') }}

    UNION ALL

    SELECT 
        account_id AS customer_id,
        account_firstname AS first_name,
        account_lastname AS last_name,
        account_email AS customer_email,
        NULL AS customer_segment,          
        'fudgeflix' AS source_system
    FROM {{ source('fudgeflix', 'ff_accounts') }}

)

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'source_system']) }} AS customer_key,
    *
FROM customers
