/*{{
  config(
    materialized='table'
  )
}}*/

SELECT 
    id as order_id,
    order_id as order_uuid,
    product_id as product_uuid,
    quantity as quantity_ordered
FROM {{ source('greenery_data_sources', 'order_items') }}