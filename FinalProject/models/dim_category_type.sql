{{ config(materialized='table') }}

SELECT 1 AS category_type_key, 'retail' AS category_type
UNION ALL
SELECT 2, 'streaming'