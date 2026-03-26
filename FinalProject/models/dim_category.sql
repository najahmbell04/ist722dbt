{{ config(materialized='table') }}

WITH categories AS (

    SELECT DISTINCT
        product_department AS category_name,
        'retail' AS category_type
    FROM {{ source('fudgemart', 'fm_products') }}

    UNION ALL

    SELECT DISTINCT
        genre_name AS category_name,
        'streaming' AS category_type
    FROM {{ source('fudgeflix', 'ff_genres') }}

)

SELECT
    {{ dbt_utils.generate_surrogate_key(['category_name', 'category_type']) }} AS category_key,
    *
FROM categories
