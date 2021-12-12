/*{{
  config(
    materialized='table'
  )
}}*/

SELECT 
    id as product_id,
    product_id as product_uuid,
    name, 
    price,
    quantity as quantity_in_stock
FROM {{ source('greenery_data_sources', 'products') }}