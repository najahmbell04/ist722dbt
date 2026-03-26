{{ config(materialized='table') }}

WITH fudgemart_items AS (
    SELECT
        CAST(p.product_id AS VARCHAR) AS item_id,
        p.product_name AS item_name,
        p.product_description AS item_description,
        'fudgemart' AS source_system,
        c.category_key,
        it.item_type_key,
        ROW_NUMBER() OVER (PARTITION BY p.product_id ORDER BY p.product_id) AS rn
    FROM {{ source('fudgemart', 'fm_products') }} p
    LEFT JOIN {{ ref('dim_category') }} c
        ON p.product_department = c.category_name
    LEFT JOIN {{ ref('dim_item_type') }} it
        ON 'product' = it.item_type   
),

fudgeflix_items AS (
    SELECT
        CAST(t.title_id AS VARCHAR) AS item_id,
        t.title_name AS item_name,
        t.title_synopsis AS item_description,
        'fudgeflix' AS source_system,
        c.category_key,
        it.item_type_key,
        ROW_NUMBER() OVER (PARTITION BY t.title_id ORDER BY tg.tg_genre_name) AS rn
    FROM {{ source('fudgeflix', 'ff_titles') }} t
    LEFT JOIN {{ source('fudgeflix', 'ff_title_genres') }} tg
        ON t.title_id = tg.tg_title_id
    LEFT JOIN {{ ref('dim_category') }} c
        ON tg.tg_genre_name = c.category_name
    LEFT JOIN {{ ref('dim_item_type') }} it
        ON 'streaming_title' = it.item_type   
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['item_id', 'source_system']) }} AS item_key,
    item_id,
    item_name,
    item_description,
    source_system,
    category_key,
    item_type_key
FROM fudgemart_items
WHERE rn = 1

UNION ALL

SELECT
    {{ dbt_utils.generate_surrogate_key(['item_id', 'source_system']) }} AS item_key,
    item_id,
    item_name,
    item_description,
    source_system,
    category_key,
    item_type_key
FROM fudgeflix_items
WHERE rn = 1
