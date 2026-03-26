{{ config(materialized='table') }}

WITH fudgemart_ratings AS (
    SELECT
        CAST(r.product_id AS VARCHAR) AS item_id,
        CAST(r.customer_id AS VARCHAR) AS customer_id,
        CAST(r.review_date AS DATE) AS review_date,
        TRY_CAST(r.review_stars AS NUMBER) AS rating_value,
        1 AS rating_count
    FROM {{ source('fudgemart', 'fm_customer_product_reviews') }} r
),

fudgeflix_ratings AS (
    SELECT
        CAST(at.at_title_id AS VARCHAR) AS item_id,
        CAST(at.at_account_id AS VARCHAR) AS customer_id,
        CAST(at.at_queue_date AS DATE) AS review_date,
        TRY_CAST(at.at_rating AS NUMBER) AS rating_value,
        1 AS rating_count
    FROM {{ source('fudgeflix', 'ff_account_titles') }} at
),

combined_ratings AS (
    SELECT * FROM fudgemart_ratings
    UNION ALL
    SELECT * FROM fudgeflix_ratings
)

SELECT
    -- Resolved ambiguity using 'r.' prefix
    {{ dbt_utils.generate_surrogate_key(['r.customer_id', 'r.item_id', 'r.review_date']) }} AS rating_id,
    c.customer_key,
    i.item_key,
    i.category_key,
    i.category_key AS category_type_key,
    i.item_type_key,
    d.datekey AS date_key,
    r.rating_value,
    r.rating_count
FROM combined_ratings r
LEFT JOIN {{ ref('dim_customer') }} c
    ON r.customer_id = c.customer_id
LEFT JOIN {{ ref('dim_item') }} i
    ON r.item_id = i.item_id
LEFT JOIN {{ ref('dim_date') }} d
    ON r.review_date = d.date
