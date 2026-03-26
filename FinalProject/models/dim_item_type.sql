{{ config(materialized='table') }}
SELECT
    1 AS item_type_key,
    'product' AS item_type
UNION
SELECT
    2 AS item_type_key,
    'streaming_title' AS item_type